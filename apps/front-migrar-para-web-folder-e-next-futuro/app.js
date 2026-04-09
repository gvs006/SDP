/* ═══════════════════════════════════════════════════════════════════════════
   Sabor do Parque — App Logic
   ═══════════════════════════════════════════════════════════════════════════ */

// ── DATA (loaded from products.json) ─────────────────────────────────────
let ING_COSTS = {};
let BASES = {};
let EMBALAGENS = {};
let FLAVORS = [];

// ── STATE ────────────────────────────────────────────────────────────────
const KEY_VENDAS = 'sdp_vendas';
const KEY_ESTOQUE = 'sdp_estoque';
const KEY_COMPRAS = 'sdp_compras';

function load(k, def) {
  try {
    const v = localStorage.getItem(k);
    return v ? JSON.parse(v) : def;
  } catch { return def; }
}

function save(k, v) {
  localStorage.setItem(k, JSON.stringify(v));
}

let vendas = [];
let estoque = {};
let compras = [];
let cart = [];
let payMethod = 'Pix';

// ── COST CALCULATION ─────────────────────────────────────────────────────
function ic(key, qty) {
  return (ING_COSTS[key] || 0) * qty;
}

function buildRecipe(flavor) {
  const recipe = [];
  if (flavor.base && BASES[flavor.base]) {
    recipe.push(...BASES[flavor.base]);
  }
  if (flavor.extras) {
    recipe.push(...flavor.extras);
  }
  if (flavor.embalagem && EMBALAGENS[flavor.embalagem]) {
    EMBALAGENS[flavor.embalagem].forEach(([key, perUnit]) => {
      recipe.push([key, perUnit * flavor.rendimento]);
    });
  }
  return recipe;
}

function calcBatchCost(recipe) {
  return recipe.reduce((s, [k, q]) => s + ic(k, q), 0);
}

// ── INIT ─────────────────────────────────────────────────────────────────
async function loadProductData() {
  try {
    const response = await fetch('./products.json');
    const data = await response.json();

    ING_COSTS = data.ingredientCosts;
    BASES = data.bases;
    EMBALAGENS = data.embalagens;

    FLAVORS = data.flavors.map(f => {
      const recipe = buildRecipe(f);
      // Use custoUnit from JSON (real CSV data) if available, otherwise calculate
      const custoUnit = f.custoUnit != null ? f.custoUnit : calcBatchCost(recipe) / f.rendimento;
      return { ...f, recipe, custoUnit };
    });

    // Load state from localStorage
    vendas = load(KEY_VENDAS, []);
    estoque = load(KEY_ESTOQUE, Object.fromEntries(FLAVORS.map(f => [f.id, 0])));
    compras = load(KEY_COMPRAS, []);

    // Ensure all flavors exist in estoque
    FLAVORS.forEach(f => {
      if (estoque[f.id] == null) estoque[f.id] = 0;
    });

  } catch (err) {
    console.error('Erro ao carregar dados dos produtos:', err);
    showToast('Erro ao carregar dados. Verifique o arquivo products.json');
  }
}

// ── AUTH ──────────────────────────────────────────────────────────────────
const USERS = { admin: 'sabor2024', gerente: 'parque123' };

function doLogin() {
  const u = document.getElementById('login-user').value.trim();
  const p = document.getElementById('login-pass').value;
  if (USERS[u] && USERS[u] === p) {
    document.getElementById('login-screen').style.display = 'none';
    document.getElementById('app').style.display = 'block';
    initApp();
  } else {
    const err = document.getElementById('login-err');
    err.style.display = 'block';
    // Shake animation
    const box = document.querySelector('.login-box');
    box.style.animation = 'none';
    box.offsetHeight; // reflow
    box.style.animation = 'scaleIn 0.3s var(--ease)';
  }
}

function doLogout() {
  document.getElementById('app').style.display = 'none';
  document.getElementById('login-screen').style.display = 'flex';
  document.getElementById('login-user').value = '';
  document.getElementById('login-pass').value = '';
  document.getElementById('login-err').style.display = 'none';
}

// ── NAV ──────────────────────────────────────────────────────────────────
function navTo(page) {
  document.querySelectorAll('.nav-item').forEach(n => n.classList.remove('active'));
  document.querySelectorAll('.page').forEach(p => p.classList.remove('active'));
  document.querySelector(`[onclick="navTo('${page}')"]`).classList.add('active');
  const pageEl = document.getElementById('page-' + page);
  pageEl.classList.add('active');

  if (page === 'dashboard') renderDashboard();
  if (page === 'estoque') renderEstoque();
  if (page === 'vendas') renderVendas();
  if (page === 'compras') renderCompras();
  if (page === 'custos') renderCustos();
}

// ── INIT APP ─────────────────────────────────────────────────────────────
function initApp() {
  buildPDV();
  populateAdjFlavor();
  renderDashboard();
  document.getElementById('comp-data').valueAsDate = new Date();
  document.getElementById('dash-date').textContent =
    new Date().toLocaleDateString('pt-BR', {
      weekday: 'long', day: 'numeric', month: 'long', year: 'numeric'
    });
}

// ── PDV ──────────────────────────────────────────────────────────────────
function buildPDV() {
  ['gourmet', 'refres'].forEach(type => {
    const el = document.getElementById('pdv-' + type);
    el.innerHTML = '';
    FLAVORS.filter(f => type === 'gourmet' ? f.linha === 'Gourmet' : f.linha === 'Refrescante')
      .forEach(f => {
        const btn = document.createElement('div');
        btn.className = 'flavor-btn ' + (f.linha === 'Gourmet' ? 'gourmet' : 'refrescante');
        btn.innerHTML = `
          <div class="fname">${f.name}</div>
          <div class="fprice">R$ ${f.preco.toFixed(2).replace('.', ',')}</div>
          <div class="fline">${f.linha}</div>`;
        btn.onclick = () => addToCart(f);
        el.appendChild(btn);
      });
  });
}

function addToCart(f) {
  const existing = cart.find(i => i.id === f.id);
  if (existing) existing.qty++;
  else cart.push({ ...f, qty: 1 });
  renderCart();
}

function renderCart() {
  const el = document.getElementById('cart-items');
  if (!cart.length) {
    el.innerHTML = '<p class="empty-state">Nenhum item adicionado</p>';
    document.getElementById('cart-total').textContent = 'R$ 0,00';
    return;
  }
  el.innerHTML = cart.map((item, i) => `
    <div class="cart-item">
      <span class="ci-name">${item.name}</span>
      <div class="ci-qty">
        <button class="qty-btn" onclick="changeQty(${i},-1)">−</button>
        <span style="font-size:13px;font-weight:700;min-width:22px;text-align:center">${item.qty}</span>
        <button class="qty-btn" onclick="changeQty(${i},1)">+</button>
      </div>
      <span class="ci-price">R$ ${(item.preco * item.qty).toFixed(2).replace('.', ',')}</span>
    </div>`).join('');
  const total = cart.reduce((s, i) => s + i.preco * i.qty, 0);
  document.getElementById('cart-total').textContent = 'R$ ' + total.toFixed(2).replace('.', ',');
}

function changeQty(i, d) {
  cart[i].qty += d;
  if (cart[i].qty <= 0) cart.splice(i, 1);
  renderCart();
}

function clearCart() {
  cart = [];
  renderCart();
}

function selPay(btn, method) {
  document.querySelectorAll('.pay-btn').forEach(b => b.classList.remove('active'));
  btn.classList.add('active');
  payMethod = method;
}

function finalizeSale() {
  if (!cart.length) { showToast('⚠ Carrinho vazio!'); return; }
  const total = cart.reduce((s, i) => s + i.preco * i.qty, 0);
  const lucro = cart.reduce((s, i) => s + (i.preco - i.custoUnit) * i.qty, 0);
  const venda = {
    id: Date.now(),
    data: new Date().toISOString(),
    itens: cart.map(i => ({ id: i.id, name: i.name, qty: i.qty, preco: i.preco, custoUnit: i.custoUnit })),
    pagamento: payMethod, total, lucro
  };
  // Descontar estoque
  cart.forEach(item => {
    if (estoque[item.id] != null) estoque[item.id] = Math.max(0, estoque[item.id] - item.qty);
  });
  vendas.unshift(venda);
  save(KEY_VENDAS, vendas);
  save(KEY_ESTOQUE, estoque);
  showToast(`✔ Venda de R$ ${total.toFixed(2).replace('.', ',')} registrada!`);
  clearCart();
}

// ── ESTOQUE ──────────────────────────────────────────────────────────────
function renderEstoque() {
  const tbody = document.getElementById('stock-tbody');
  tbody.innerHTML = '';
  let total = 0, baixo = 0;
  FLAVORS.forEach(f => {
    const qty = estoque[f.id] || 0;
    total += qty;
    const min = f.linha === 'Gourmet' ? 5 : 8;
    const status = qty === 0 ? 'Sem estoque' : qty < min ? 'Baixo' : 'OK';
    const sc = qty === 0 ? 'stock-low' : qty < min ? 'stock-med' : 'stock-ok';
    if (qty < min) baixo++;
    const tr = document.createElement('tr');
    tr.innerHTML = `
      <td>${f.name}</td>
      <td><span class="badge ${f.linha === 'Gourmet' ? 'badge-gold' : 'badge-green'}">${f.linha}</span></td>
      <td><strong class="${sc}">${qty}</strong></td>
      <td>${min}</td>
      <td><span class="badge ${qty === 0 ? 'badge-red' : qty < min ? 'badge-amber' : 'badge-green'}">${status}</span></td>
      <td>
        <button class="btn btn-primary btn-sm" onclick="quickAdj('${f.id}',1)">+1</button>
        <button class="btn btn-outline btn-sm" onclick="quickAdj('${f.id}',-1)">-1</button>
      </td>`;
    tbody.appendChild(tr);
  });
  document.getElementById('stock-total-badge').textContent = total + ' unidades em estoque';
  document.getElementById('stock-metrics').innerHTML = `
    <div class="metric-card blue"><div class="label">Total em estoque</div><div class="value">${total}</div><div class="sub">unidades</div></div>
    <div class="metric-card red"><div class="label">Sabores com estoque baixo</div><div class="value">${baixo}</div><div class="sub">precisam reposição</div></div>
    <div class="metric-card gold"><div class="label">Total de sabores</div><div class="value">${FLAVORS.length}</div><div class="sub">no cardápio</div></div>`;
}

function quickAdj(id, d) {
  estoque[id] = Math.max(0, (estoque[id] || 0) + d);
  save(KEY_ESTOQUE, estoque);
  renderEstoque();
}

function populateAdjFlavor() {
  const sel = document.getElementById('adj-flavor');
  sel.innerHTML = FLAVORS.map(f => `<option value="${f.id}">${f.name}</option>`).join('');
}

function saveAdjuste() {
  const id = document.getElementById('adj-flavor').value;
  const type = document.getElementById('adj-type').value;
  const qty = parseInt(document.getElementById('adj-qty').value) || 0;
  if (type === 'set') estoque[id] = qty;
  else if (type === 'add') estoque[id] = (estoque[id] || 0) + qty;
  else estoque[id] = Math.max(0, (estoque[id] || 0) - qty);
  save(KEY_ESTOQUE, estoque);
  closeModal('modal-ajuste');
  renderEstoque();
  showToast('✔ Estoque atualizado!');
}

// ── VENDAS ───────────────────────────────────────────────────────────────
function renderVendas() {
  const filtro = document.getElementById('filtro-pagamento').value;
  const filtered = filtro ? vendas.filter(v => v.pagamento === filtro) : vendas;
  const tbody = document.getElementById('vendas-tbody');
  if (!filtered.length) {
    tbody.innerHTML = '<tr><td colspan="6" class="empty-state">Nenhuma venda registrada</td></tr>';
  } else {
    tbody.innerHTML = filtered.map((v, i) => {
      const d = new Date(v.data);
      const dateStr = d.toLocaleDateString('pt-BR') + ' ' +
        d.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' });
      const itens = v.itens.map(i => `${i.name} ×${i.qty}`).join(', ');
      const lClass = v.lucro >= 0 ? 'text-green' : 'text-red';
      return `<tr>
        <td>#${filtered.length - i}</td>
        <td>${dateStr}</td>
        <td style="max-width:200px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis" title="${itens}">${itens}</td>
        <td><span class="badge badge-primary">${v.pagamento}</span></td>
        <td><strong>R$ ${v.total.toFixed(2).replace('.', ',')}</strong></td>
        <td class="${lClass}">R$ ${v.lucro.toFixed(2).replace('.', ',')}</td>
      </tr>`;
    }).join('');
  }
  const totalVendas = vendas.reduce((s, v) => s + v.total, 0);
  const totalLucro = vendas.reduce((s, v) => s + v.lucro, 0);
  const hoje = new Date().toDateString();
  const vendasHoje = vendas.filter(v => new Date(v.data).toDateString() === hoje);
  const totalHoje = vendasHoje.reduce((s, v) => s + v.total, 0);
  document.getElementById('vendas-metrics').innerHTML = `
    <div class="metric-card blue"><div class="label">Total em vendas</div><div class="value">R$ ${totalVendas.toFixed(2).replace('.', ',')}</div><div class="sub">${vendas.length} transações</div></div>
    <div class="metric-card green"><div class="label">Lucro total</div><div class="value">R$ ${totalLucro.toFixed(2).replace('.', ',')}</div><div class="sub">margem ${totalVendas > 0 ? (totalLucro / totalVendas * 100).toFixed(1) : 0}%</div></div>
    <div class="metric-card gold"><div class="label">Vendas hoje</div><div class="value">R$ ${totalHoje.toFixed(2).replace('.', ',')}</div><div class="sub">${vendasHoje.length} transações</div></div>`;
}

// ── COMPRAS ──────────────────────────────────────────────────────────────
function renderCompras() {
  const tbody = document.getElementById('compras-tbody');
  if (!compras.length) {
    tbody.innerHTML = '<tr><td colspan="6" class="empty-state">Nenhuma compra registrada</td></tr>';
  } else {
    tbody.innerHTML = compras.map((c, i) => `<tr>
      <td>${new Date(c.data + 'T12:00:00').toLocaleDateString('pt-BR')}</td>
      <td>${c.desc}</td>
      <td><span class="badge badge-primary">${c.cat}</span></td>
      <td>${c.forn || '—'}</td>
      <td><strong>R$ ${parseFloat(c.valor).toFixed(2).replace('.', ',')}</strong></td>
      <td><button class="btn btn-danger btn-sm" onclick="deleteCompra(${i})">✕</button></td>
    </tr>`).join('');
  }
  const totalComp = compras.reduce((s, c) => s + parseFloat(c.valor), 0);
  const mesAtual = new Date().getMonth();
  const compMes = compras.filter(c => new Date(c.data + 'T12:00:00').getMonth() === mesAtual);
  const totalMes = compMes.reduce((s, c) => s + parseFloat(c.valor), 0);
  document.getElementById('compras-metrics').innerHTML = `
    <div class="metric-card red"><div class="label">Total em compras</div><div class="value">R$ ${totalComp.toFixed(2).replace('.', ',')}</div><div class="sub">${compras.length} registros</div></div>
    <div class="metric-card amber"><div class="label">Gastos este mês</div><div class="value">R$ ${totalMes.toFixed(2).replace('.', ',')}</div><div class="sub">${compMes.length} compras</div></div>`;
}

function saveCompra() {
  const desc = document.getElementById('comp-desc').value.trim();
  const cat = document.getElementById('comp-cat').value;
  const forn = document.getElementById('comp-forn').value.trim();
  const valor = document.getElementById('comp-valor').value;
  const data = document.getElementById('comp-data').value;
  if (!desc || !valor) { showToast('⚠ Preencha descrição e valor'); return; }
  compras.unshift({ desc, cat, forn, valor: parseFloat(valor), data });
  save(KEY_COMPRAS, compras);
  closeModal('modal-compra');
  document.getElementById('comp-desc').value = '';
  document.getElementById('comp-valor').value = '';
  renderCompras();
  showToast('✔ Compra registrada!');
}

function deleteCompra(i) {
  if (!confirm('Remover esta compra?')) return;
  compras.splice(i, 1);
  save(KEY_COMPRAS, compras);
  renderCompras();
}

// ── CUSTOS ───────────────────────────────────────────────────────────────
function renderCustos() {
  ['g', 'r'].forEach(t => {
    const tbody = document.getElementById('custo-tbody-' + t);
    const line = t === 'g' ? 'Gourmet' : 'Refrescante';
    tbody.innerHTML = FLAVORS.filter(f => f.linha === line).map(f => {
      const lucro = f.preco - f.custoUnit;
      const margem = (lucro / f.preco * 100);
      const lc = lucro >= 0 ? 'text-green' : 'text-red';
      return `<tr>
        <td>${f.name}</td>
        <td>R$ ${f.custoUnit.toFixed(2).replace('.', ',')}</td>
        <td>R$ ${f.preco.toFixed(2).replace('.', ',')}</td>
        <td class="${lc}">R$ ${lucro.toFixed(2).replace('.', ',')}</td>
        <td class="${lc}">${margem.toFixed(1)}%</td>
      </tr>`;
    }).join('');
  });
}

function custoTab(tab, el) {
  document.querySelectorAll('.page-tab').forEach(t => t.classList.remove('active'));
  el.classList.add('active');
  document.getElementById('custo-gourmet').style.display = tab === 'gourmet' ? 'block' : 'none';
  document.getElementById('custo-refrescante').style.display = tab === 'refrescante' ? 'block' : 'none';
}

function exportCustosCSV() {
  const BOM = '\uFEFF'; // UTF-8 BOM for Excel
  const sep = ',';
  let csv = BOM;

  csv += `Sabor do Parque — Resumo de Custos e Margens${sep}${sep}${sep}${sep}\n`;
  csv += `Sabor${sep}Custo/unid (R$)${sep}Preço venda (R$)${sep}Lucro/unid (R$)${sep}Margem (%)\n`;

  // Linha Gourmet
  csv += `Linha Gourmet${sep}${sep}${sep}${sep}\n`;
  FLAVORS.filter(f => f.linha === 'Gourmet').forEach(f => {
    const lucro = f.preco - f.custoUnit;
    const margem = (lucro / f.preco * 100);
    csv += `${f.name}${sep}"R$ ${f.custoUnit.toFixed(2).replace('.', ',')}"${sep}"R$ ${f.preco.toFixed(2).replace('.', ',')}"${sep}"R$ ${lucro.toFixed(2).replace('.', ',')}"${sep}"${margem.toFixed(1).replace('.', ',')}%"\n`;
  });

  csv += `${sep}${sep}${sep}${sep}\n`;

  // Linha Refrescante
  csv += `Linha Refrescante${sep}${sep}${sep}${sep}\n`;
  FLAVORS.filter(f => f.linha === 'Refrescante').forEach(f => {
    const lucro = f.preco - f.custoUnit;
    const margem = (lucro / f.preco * 100);
    csv += `${f.name}${sep}"R$ ${f.custoUnit.toFixed(2).replace('.', ',')}"${sep}"R$ ${f.preco.toFixed(2).replace('.', ',')}"${sep}"R$ ${lucro.toFixed(2).replace('.', ',')}"${sep}"${margem.toFixed(1).replace('.', ',')}%"\n`;
  });

  // Download
  const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  const now = new Date();
  const dateStr = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`;
  a.download = `Sabor_do_Parque_Custos_${dateStr}.csv`;
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  URL.revokeObjectURL(url);
  showToast('📥 CSV exportado com sucesso!');
}

// ── DASHBOARD ────────────────────────────────────────────────────────────
function renderDashboard() {
  const hoje = new Date().toDateString();
  const vendasHoje = vendas.filter(v => new Date(v.data).toDateString() === hoje);
  const totalHoje = vendasHoje.reduce((s, v) => s + v.total, 0);
  const lucroHoje = vendasHoje.reduce((s, v) => s + v.lucro, 0);
  const unidsHoje = vendasHoje.reduce((s, v) => s + v.itens.reduce((a, i) => a + i.qty, 0), 0);
  const totalEstoque = Object.values(estoque).reduce((s, v) => s + v, 0);

  document.getElementById('dash-metrics').innerHTML = `
    <div class="metric-card blue"><div class="label">Faturamento hoje</div><div class="value">R$ ${totalHoje.toFixed(2).replace('.', ',')}</div><div class="sub">${vendasHoje.length} vendas</div></div>
    <div class="metric-card green"><div class="label">Lucro hoje</div><div class="value">R$ ${lucroHoje.toFixed(2).replace('.', ',')}</div><div class="sub">${unidsHoje} unidades</div></div>
    <div class="metric-card gold"><div class="label">Estoque total</div><div class="value">${totalEstoque}</div><div class="sub">unidades disponíveis</div></div>
    <div class="metric-card amber"><div class="label">Total vendas (geral)</div><div class="value">R$ ${vendas.reduce((s, v) => s + v.total, 0).toFixed(2).replace('.', ',')}</div><div class="sub">desde o início</div></div>`;

  // Top flavors today
  const flavorCount = {};
  vendasHoje.forEach(v => v.itens.forEach(i => {
    flavorCount[i.name] = (flavorCount[i.name] || 0) + i.qty;
  }));
  const sorted = Object.entries(flavorCount).sort((a, b) => b[1] - a[1]).slice(0, 5);
  const tf = document.getElementById('dash-top-flavors');
  if (!sorted.length) {
    tf.innerHTML = '<p class="empty-state">Nenhuma venda hoje ainda</p>';
  } else {
    tf.innerHTML = sorted.map(([name, qty]) => `
      <div class="dash-list-item">
        <span class="item-name">${name}</span>
        <span class="item-value">${qty} und</span>
      </div>`).join('');
  }

  // Low stock
  const ls = document.getElementById('dash-low-stock');
  const baixoList = FLAVORS.filter(f => (estoque[f.id] || 0) < (f.linha === 'Gourmet' ? 5 : 8));
  if (!baixoList.length) {
    ls.innerHTML = '<p style="color:#16a34a;font-size:14px;font-weight:700;padding:12px 0">✔ Estoque OK em todos os sabores</p>';
  } else {
    ls.innerHTML = baixoList.map(f => `
      <div class="dash-list-item">
        <span class="item-name">${f.name}</span>
        <span class="badge badge-${(estoque[f.id] || 0) === 0 ? 'red' : 'amber'}">${estoque[f.id] || 0} und</span>
      </div>`).join('');
  }

  // Recent sales
  const rs = document.getElementById('dash-recent-sales');
  if (!vendas.length) {
    rs.innerHTML = '<p class="empty-state">Nenhuma venda registrada</p>';
    return;
  }
  rs.innerHTML = `<table><thead><tr><th>Horário</th><th>Itens</th><th>Pagamento</th><th>Total</th></tr></thead><tbody>` +
    vendas.slice(0, 8).map(v => {
      const d = new Date(v.data);
      const itens = v.itens.map(i => `${i.name} ×${i.qty}`).join(', ');
      return `<tr>
        <td>${d.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' })}</td>
        <td style="max-width:220px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis">${itens}</td>
        <td><span class="badge badge-primary">${v.pagamento}</span></td>
        <td><strong>R$ ${v.total.toFixed(2).replace('.', ',')}</strong></td>
      </tr>`;
    }).join('') + '</tbody></table>';
}

// ── MODAL / TOAST ────────────────────────────────────────────────────────
function openModal(id) {
  document.getElementById(id).classList.add('open');
}

function closeModal(id) {
  document.getElementById(id).classList.remove('open');
}

let toastTimer = null;
function showToast(msg) {
  const t = document.getElementById('toast');
  if (toastTimer) clearTimeout(toastTimer);
  t.classList.remove('show', 'hide');
  t.textContent = msg;
  // Force reflow
  t.offsetHeight;
  t.classList.add('show');
  toastTimer = setTimeout(() => {
    t.classList.remove('show');
    t.classList.add('hide');
  }, 2800);
}

// ── BOOT ─────────────────────────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', async () => {
  await loadProductData();

  // Login enter key
  document.getElementById('login-pass').addEventListener('keydown', e => {
    if (e.key === 'Enter') doLogin();
  });
  document.getElementById('login-user').addEventListener('keydown', e => {
    if (e.key === 'Enter') document.getElementById('login-pass').focus();
  });

  // Modal close on backdrop click
  document.querySelectorAll('.modal-overlay').forEach(m => {
    m.addEventListener('click', e => {
      if (e.target === m) m.classList.remove('open');
    });
  });
});
