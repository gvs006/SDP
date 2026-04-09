import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

// ═══════════════════════════════════════════════════
// Dados do legado products.json — com custos REAIS
// ═══════════════════════════════════════════════════

const INGREDIENT_COSTS: Record<string, { name: string; cost: number; unit: string }> = {
  leiteCondensado: { name: 'Leite Condensado', cost: 7.15, unit: 'un' },
  cremeleite:      { name: 'Creme de Leite', cost: 1.70, unit: 'un' },
  leite:           { name: 'Leite', cost: 0.00449, unit: 'ml' },
  leitePo:         { name: 'Leite em Pó', cost: 0.0392, unit: 'g' },
  leiteNinho:      { name: 'Leite Ninho', cost: 0.052, unit: 'g' },
  morango:         { name: 'Morango', cost: 0.01252, unit: 'g' },
  maracuja:        { name: 'Maracujá', cost: 0.012, unit: 'g' },
  manga:           { name: 'Manga', cost: 0.015, unit: 'g' },
  goiaba:          { name: 'Goiaba', cost: 0.0125, unit: 'g' },
  abacaxi:         { name: 'Abacaxi', cost: 7.00, unit: 'un' },
  uva:             { name: 'Uva', cost: 15.00, unit: 'un' },
  limao:           { name: 'Limão', cost: 0.60, unit: 'un' },
  nutela:          { name: 'Nutella', cost: 0.0506, unit: 'g' },
  ligaNeutra:      { name: 'Liga Neutra', cost: 0.0335, unit: 'g' },
  acucar:          { name: 'Açúcar', cost: 0.005, unit: 'g' },
  bolacha:         { name: 'Bolacha', cost: 1.85, unit: 'un' },
  ovos:            { name: 'Ovos', cost: 0.80, unit: 'un' },
  essBaunilha:     { name: 'Essência de Baunilha', cost: 0.27, unit: 'ml' },
  essAvela:        { name: 'Essência de Avelã', cost: 0.34967, unit: 'ml' },
  ovoCreme:        { name: 'Ovomaltine Creme', cost: 0.0074, unit: 'g' },
  ovoPo:           { name: 'Ovomaltine Pó', cost: 0.00772, unit: 'g' },
  amendoim:        { name: 'Amendoim', cost: 0.01572, unit: 'g' },
  cacau:           { name: 'Cacau em Pó', cost: 0.03547, unit: 'g' },
  saqG:            { name: 'Saquinho Gourmet', cost: 0.0767, unit: 'un' },
  saqN:            { name: 'Saquinho Normal', cost: 0.098, unit: 'un' },
  embG:            { name: 'Embalagem Gourmet', cost: 0.185, unit: 'un' },
  adesivo:         { name: 'Adesivo', cost: 0.040, unit: 'un' },
};

// Bases (ingredientes compartilhados por batelada)
const BASES: Record<string, [string, number][]> = {
  baseG: [
    ['leiteCondensado', 1], ['cremeleite', 100], ['leite', 1000],
    ['leitePo', 50], ['ligaNeutra', 20],
  ],
  baseGN: [
    ['leiteCondensado', 1], ['cremeleite', 100], ['leite', 1000],
    ['leitePo', 50], ['leiteNinho', 100], ['ligaNeutra', 20],
  ],
  baseR: [
    ['acucar', 50], ['ligaNeutra', 10],
  ],
};

// Embalagem por linha (custo por unidade = custo * rendimento)
const EMBALAGENS: Record<string, [string, number][]> = {
  embG: [['saqG', 1], ['embG', 1], ['adesivo', 1]],
  embR: [['saqN', 1], ['adesivo', 1]],
};

interface FlavorDef {
  externalId: string;
  name: string;
  linha: string;
  preco: number;
  rendimento: number;
  base: string | null;
  extras: [string, number][];
  embalagem: string;
}

const FLAVORS: FlavorDef[] = [
  { externalId: 'ninho-morango', name: 'Ninho c/ Morango', linha: 'Gourmet', preco: 12, rendimento: 13, base: 'baseGN', extras: [['morango', 300]], embalagem: 'embG' },
  { externalId: 'ninho-nutella', name: 'Ninho c/ Nutella', linha: 'Gourmet', preco: 12, rendimento: 13, base: 'baseGN', extras: [['nutela', 100]], embalagem: 'embG' },
  { externalId: 'maracuja-nutella', name: 'Maracujá c/ Nutella', linha: 'Gourmet', preco: 12, rendimento: 13, base: 'baseG', extras: [['maracuja', 200], ['nutela', 100]], embalagem: 'embG' },
  { externalId: 'morango-nutella', name: 'Morango c/ Nutella', linha: 'Gourmet', preco: 12, rendimento: 13, base: 'baseG', extras: [['morango', 200], ['nutela', 100]], embalagem: 'embG' },
  { externalId: 'morango-geleia', name: 'Morango c/ Geleia de Morango', linha: 'Gourmet', preco: 12, rendimento: 13, base: 'baseG', extras: [['morango', 400], ['acucar', 50]], embalagem: 'embG' },
  { externalId: 'maracuja-geleia', name: 'Maracujá c/ Geleia', linha: 'Gourmet', preco: 12, rendimento: 13, base: 'baseG', extras: [['maracuja', 300], ['acucar', 50]], embalagem: 'embG' },
  { externalId: 'uva-geleia', name: 'Uva c/ Geleia de Uva', linha: 'Gourmet', preco: 12, rendimento: 13, base: 'baseG', extras: [['uva', 1], ['acucar', 50]], embalagem: 'embG' },
  { externalId: 'tortinha-limao', name: 'Tortinha de Limão', linha: 'Gourmet', preco: 12, rendimento: 13, base: 'baseG', extras: [['limao', 3], ['acucar', 40], ['bolacha', 1]], embalagem: 'embG' },
  { externalId: 'ovomaltine', name: 'Ovomaltine', linha: 'Gourmet', preco: 12, rendimento: 13, base: 'baseG', extras: [['ovoPo', 50], ['ovoCreme', 260]], embalagem: 'embG' },
  { externalId: 'ferrero', name: 'Ferrero (Avelã)', linha: 'Gourmet', preco: 12, rendimento: 13, base: 'baseG', extras: [['nutela', 200], ['amendoim', 55], ['cacau', 40], ['essAvela', 15]], embalagem: 'embG' },
  { externalId: 'manga-cremosa', name: 'Manga Cremosa', linha: 'Gourmet', preco: 12, rendimento: 13, base: 'baseG', extras: [['manga', 300]], embalagem: 'embG' },
  { externalId: 'pudim', name: 'Pudim', linha: 'Gourmet', preco: 12, rendimento: 13, base: null, extras: [['leiteCondensado', 2], ['cremeleite', 200], ['leite', 500], ['ovos', 6], ['acucar', 100], ['essBaunilha', 2], ['ligaNeutra', 20]], embalagem: 'embG' },
  { externalId: 'manga-r', name: 'Manga', linha: 'Refrescante', preco: 8, rendimento: 15, base: 'baseR', extras: [['manga', 300]], embalagem: 'embR' },
  { externalId: 'abacaxi-r', name: 'Abacaxi', linha: 'Refrescante', preco: 8, rendimento: 15, base: 'baseR', extras: [['abacaxi', 1]], embalagem: 'embR' },
  { externalId: 'morango-r', name: 'Morango', linha: 'Refrescante', preco: 8, rendimento: 15, base: 'baseR', extras: [['morango', 300]], embalagem: 'embR' },
  { externalId: 'maracuja-r', name: 'Maracujá', linha: 'Refrescante', preco: 8, rendimento: 15, base: 'baseR', extras: [['maracuja', 300]], embalagem: 'embR' },
  { externalId: 'goiaba-r', name: 'Goiaba', linha: 'Refrescante', preco: 8, rendimento: 15, base: 'baseR', extras: [['goiaba', 300]], embalagem: 'embR' },
  { externalId: 'uva-r', name: 'Uva', linha: 'Refrescante', preco: 8, rendimento: 15, base: 'baseR', extras: [['uva', 1]], embalagem: 'embR' },
];

async function main() {
  console.log('🌱 Seeding database...');

  // 1. Create all ingredients
  const ingredientMap: Record<string, string> = {};
  for (const [key, data] of Object.entries(INGREDIENT_COSTS)) {
    const ing = await prisma.ingredient.upsert({
      where: { key },
      update: { costPerUnit: data.cost, name: data.name, unit: data.unit },
      create: { key, name: data.name, costPerUnit: data.cost, unit: data.unit },
    });
    ingredientMap[key] = ing.id;
  }
  console.log(`  ✅ ${Object.keys(ingredientMap).length} ingredientes carregados`);

  // 2. Create all flavors with their ingredients
  for (const flavorDef of FLAVORS) {
    const flavor = await prisma.flavor.upsert({
      where: { externalId: flavorDef.externalId },
      update: { name: flavorDef.name, linha: flavorDef.linha, preco: flavorDef.preco, rendimento: flavorDef.rendimento },
      create: { externalId: flavorDef.externalId, name: flavorDef.name, linha: flavorDef.linha, preco: flavorDef.preco, rendimento: flavorDef.rendimento },
    });

    // Clear existing ingredients for this flavor (upsert approach)
    await prisma.flavorIngredient.deleteMany({ where: { flavorId: flavor.id } });

    // Build full recipe: base + extras + embalagem
    const recipe: { key: string; qty: number; source: string }[] = [];

    // Base ingredients (per batch)
    if (flavorDef.base && BASES[flavorDef.base]) {
      for (const [key, qty] of BASES[flavorDef.base]) {
        recipe.push({ key, qty, source: 'base' });
      }
    }

    // Extra ingredients (per batch)
    for (const [key, qty] of flavorDef.extras) {
      recipe.push({ key, qty, source: 'extra' });
    }

    // Embalagem (per unit × rendimento = per batch)
    if (EMBALAGENS[flavorDef.embalagem]) {
      for (const [key, perUnit] of EMBALAGENS[flavorDef.embalagem]) {
        recipe.push({ key, qty: perUnit * flavorDef.rendimento, source: 'embalagem' });
      }
    }

    // Insert all recipe ingredients
    for (const item of recipe) {
      if (!ingredientMap[item.key]) {
        console.warn(`  ⚠ Ingrediente "${item.key}" não encontrado, pulando...`);
        continue;
      }
      await prisma.flavorIngredient.create({
        data: {
          flavorId: flavor.id,
          ingredientId: ingredientMap[item.key],
          quantity: item.qty,
          source: item.source,
        },
      });
    }

    // Create stock entry (starting at 0)
    await prisma.stockEntry.upsert({
      where: { flavorId: flavor.id },
      update: {},
      create: {
        flavorId: flavor.id,
        quantity: 0,
        minStock: flavorDef.linha === 'Gourmet' ? 5 : 8,
      },
    });
  }

  console.log(`  ✅ ${FLAVORS.length} sabores carregados com receitas`);
  console.log('🎉 Seed complete!');
}

main()
  .catch((e) => {
    console.error('❌ Seed error:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
