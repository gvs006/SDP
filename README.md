<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.41-02569B?logo=flutter" />
  <img src="https://img.shields.io/badge/NestJS-10-E0234E?logo=nestjs" />
  <img src="https://img.shields.io/badge/Next.js-15-000?logo=next.js" />
  <img src="https://img.shields.io/badge/Supabase-PostgreSQL-3ECF8E?logo=supabase" />
  <img src="https://img.shields.io/badge/Prisma-ORM-2D3748?logo=prisma" />
  <img src="https://img.shields.io/badge/Turborepo-Monorepo-EF4444?logo=turborepo" />
</p>

# 🧊 Sabor do Parque

> Sistema de gestão completo para Microempreendedores Individuais (MEI), nascido da necessidade real de controlar custos, vendas e estoque de uma sorveteria artesanal.

---

## 📋 Visão Geral

O **Sabor do Parque** é uma plataforma multi-app que unifica a gestão de negócios para MEIs brasileiros. O sistema calcula custos de produção dinamicamente a partir dos ingredientes reais, controla estoque, registra vendas e oferece dashboards analíticos — tudo em tempo real.

O projeto nasceu como uma planilha Excel + app HTML local (legado "Sabor do Parque") e está sendo migrado para uma arquitetura moderna e escalável em monorepo.

---

## 🏗️ Arquitetura

```
SDP/
├── apps/
│   ├── mobile/          → 📱 Flutter (Android/iOS/Web)
│   ├── backend/         → ⚙️  NestJS API (REST + Swagger)
│   └── web/             → 🌐 Next.js (futuro)
├── packages/
│   ├── shared-schemas/  → 📦 Zod schemas compartilhados
│   └── design-tokens/   → 🎨 Tokens de design (Flutter)
├── scripts/
│   └── sync-env.js      → 🔄 Sincronização de .env entre apps
├── turbo.json            → ⚡ Turborepo config
├── pnpm-workspace.yaml   → 📦 pnpm workspaces
└── .env                  → 🔒 Variáveis de ambiente (gitignored)
```

### Stack Tecnológica

| Camada | Tecnologia | Propósito |
|--------|-----------|-----------|
| **Mobile** | Flutter 3.41 + Dart 3.11 | App nativo Android/iOS + Web |
| **State** | Riverpod 3 | Gerenciamento de estado reativo |
| **HTTP** | Dio + Retrofit | Comunicação com API (code-gen) |
| **Models** | Freezed + json_serializable | Modelos imutáveis com serialização |
| **Routing** | GoRouter | Navegação declarativa |
| **Backend** | NestJS 10 + TypeScript | API REST com Swagger auto-documentada |
| **Validação** | Zod + nestjs-zod | Schemas compartilhados front↔back |
| **ORM** | Prisma | Type-safe database access |
| **Banco** | Supabase (PostgreSQL 17) | Auth + DB + Storage + Realtime |
| **Monorepo** | pnpm + Turborepo | Build system com cache inteligente |

---

## ✨ Features Implementadas

### 📊 Dashboard
- KPI cards: faturamento, lucro, estoque total, alertas de estoque baixo
- Ações rápidas: Cardápio, Clientes, PDV, Custos
- Bottom navigation com Material 3
- Cálculo de dados em tempo real via API

### 🍦 Catálogo de Produtos
- **18 sabores** organizados por linha (Gourmet / Refrescante)
- **28 ingredientes** com custos unitários granulares
- **Cálculo dinâmico de custo**: `custoUnit = Σ(ingrediente × quantidade) / rendimento`
- Visualização de margem de lucro por sabor (%)
- Alertas visuais de estoque por produto

### 👥 Gestão de Clientes
- CRUD completo (criar, listar, editar, excluir)
- Filtro por `userId` — isolamento multi-tenant
- Formulário com validação (nome, CPF/CNPJ, email, telefone)

### 🔐 Autenticação (Mock)
- `MockAuthGuard` para desenvolvimento local
- Decorator `@CurrentUser()` para injeção do usuário no request
- Preparado para integração com Supabase Auth (JWT)

### 🛡️ Segurança & LGPD
- `.env` com credenciais **nunca** commitado (`.gitignore` configurado)
- `.env.example` com placeholders para onboarding
- Isolamento de dados por `userId` em todas as queries
- Keystores Android e propriedades sensíveis ignoradas

---

## 🔢 Análise de Custos — Correções Identificadas

O sistema revelou discrepâncias significativas entre os custos declarados no legado e os custos reais calculados:

| Sabor | Custo Legado | Custo Real | Status |
|-------|-------------|------------|--------|
| Ninho c/ Morango | R$ 2,22 | R$ 15,17 | ❌ Subestimado |
| Pudim | R$ 2,34 | R$ 28,23 | ❌ Subestimado |
| Ferrero (Avelã) | R$ 2,89 | R$ 15,83 | ❌ Subestimado |
| Manga (Refrescante) | R$ 0,48 | R$ 0,48 | ✅ Correto |
| Maracujá (Refrescante) | R$ 0,42 | R$ 0,42 | ✅ Correto |

> **Causa raiz**: O legado não somava o custo da base (leite condensado R$7,15 + creme de leite R$1,70) no cálculo unitário dos sabores Gourmet. Os Refrescantes estão corretos porque usam uma base barata (apenas açúcar + liga neutra).

---

## 🚀 Setup & Desenvolvimento

### Pré-requisitos
- [Node.js](https://nodejs.org/) 20+
- [pnpm](https://pnpm.io/) 9+
- [Flutter SDK](https://flutter.dev/) 3.41+
- Conta no [Supabase](https://supabase.com/)

### Instalação

```bash
# 1. Clone o repositório
git clone https://github.com/gvs006/SDP.git
cd SDP

# 2. Copie o .env e preencha suas credenciais
cp .env.example .env

# 3. Instale dependências Node (backend + schemas)
pnpm install

# 4. Gere o Prisma Client
cd apps/backend && npx prisma generate && cd ../..

# 5. Instale dependências Flutter
cd apps/mobile && flutter pub get

# 6. Gere código (Freezed + Retrofit)
dart run build_runner build --delete-conflicting-outputs
cd ../..
```

### Rodando

```bash
# Backend (NestJS) — porta 3000
cd apps/backend && pnpm run start:dev

# Mobile (Flutter) — navegador ou dispositivo
cd apps/mobile && flutter run

# Ou via Turborepo (Node apps)
pnpm dev
```

### Debug (VS Code)

O projeto inclui `.vscode/launch.json` e `.vscode/settings.json` pré-configurados:
- **Run and Debug (F5)** → "📱 Run Flutter App" inicia o app mobile
- O SDK do Flutter é detectado automaticamente via `dart.flutterSdkPath`

---

## 📁 Endpoints da API

Base URL: `http://localhost:3000`

| Método | Rota | Descrição |
|--------|------|-----------|
| `GET` | `/catalog` | Lista todos os sabores com custo dinâmico |
| `GET` | `/catalog/dashboard` | Stats do dashboard (estoque, vendas) |
| `GET` | `/catalog/:id` | Detalhe de um sabor com breakdown de ingredientes |
| `PATCH` | `/catalog/:id/price` | Atualizar preço de venda |
| `GET` | `/customers` | Listar clientes do MEI |
| `POST` | `/customers` | Criar cliente |
| `GET` | `/customers/:id` | Detalhe de um cliente |
| `PATCH` | `/customers/:id` | Atualizar cliente |
| `DELETE` | `/customers/:id` | Remover cliente |

> 📖 Swagger UI disponível em `/api/docs` quando o backend está rodando.

---

## 🗺️ Roadmap

### ✅ Fase 1 — Fundação
- [x] Monorepo (pnpm + Turborepo)
- [x] Scaffolding NestJS + Flutter
- [x] Prisma + Supabase PostgreSQL
- [x] Gerenciamento unificado de `.env`
- [x] `.gitignore` para toda a stack

### ✅ Fase 2 — Módulo de Clientes
- [x] CRUD completo (NestJS + Flutter)
- [x] Zod DTOs compartilhados
- [x] MockAuthGuard para dev

### ✅ Fase 3 — Dashboard & Catálogo
- [x] Migração dos 18 sabores e 28 ingredientes do legado
- [x] Cálculo dinâmico de custos (corrigindo o CSV legado)
- [x] Dashboard com KPI cards (Material 3)
- [x] Catálogo com separação por linhas e alertas de estoque

### 🔜 Fase 4 — Operações (Em Breve)
- [ ] PDV (Ponto de Venda com carrinho)
- [ ] Registro de Vendas (histórico + filtros)
- [ ] Controle de Estoque (alertas + ajustes)
- [ ] Registro de Compras/Despesas

### 🔮 Fase 5 — Inteligência
- [ ] Autenticação real (Supabase Auth + JWT)
- [ ] Análise de preços com IA (APIs de mercado)
- [ ] Relatórios e gráficos avançados
- [ ] Export CSV/PDF
- [ ] Next.js Web App

---

## 📄 Licença

Projeto privado — © 2026 Sabor do Parque / GVS006. Todos os direitos reservados.
