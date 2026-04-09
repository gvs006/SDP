# 🧠 PROJECT PROMPT — MEI Manager (Portfolio + Treinamento de Stack Expatier)

> **Contexto:** Este projeto é um **portfólio de estudos** que replica a stack do Expatier (Next.js + Flutter + NestJS + Supabase) em escopo reduzido para um MEI brasileiro. Coloque este arquivo na raiz do monorepo junto ao MVP existente e referencie-o em qualquer AI coding assistant (Cursor, Claude, etc.).

---

## 📌 Visão Geral

**Nome do projeto:** `mei-manager`

**Objetivo principal:** App de gestão simples para um MEI (Microempreendedor Individual) brasileiro, com painel web e app mobile. O escopo é deliberadamente simples para focar no **aprendizado da stack** — a arquitetura é mais robusta do que o necessário, e isso é intencional.

**Usuários:** 1 usuário (o próprio MEI) — sem multitenancy, auth simples.

**Clientes:**
- `apps/web` → painel administrativo (Next.js) — usado no desktop
- `apps/mobile` → app no celular (Flutter) — usado em campo
- `apps/backend` → única fonte de verdade da lógica de negócio (NestJS)

---

## 🗂️ Estrutura do Monorepo

```
/                            ← raiz (onde o MVP já existe)
├── apps/
│   ├── web/                 ← Next.js 15 (App Router)
│   ├── mobile/              ← Flutter 3.x
│   └── backend/             ← NestJS
├── packages/
│   ├── shared-schemas/      ← Zod schemas (fonte única de validação)
│   └── design-tokens/       ← tokens.css (Next.js) + tokens.dart (Flutter)
├── supabase/
│   ├── migrations/          ← SQL migrations versionadas
│   └── seed.sql
├── PROMPT.md
├── turbo.json               ← Turborepo
├── docker-compose.yml
└── README.md
```

> ⚠️ **Ao iniciar qualquer tarefa:** leia os arquivos existentes na pasta, identifique entidades, rotas e modelos já implementados no MVP. Não apague nem quebre o que já existe.

---

## 🛠️ Stack Técnica

### `packages/shared-schemas` — Zod (fonte única de verdade)

- **Zod** define todos os schemas de validação
- Os tipos TypeScript são **inferidos** dos schemas (`z.infer<typeof Schema>`) — nunca declarados manualmente
- Consumido tanto pelo **NestJS** (DTOs) quanto pelo **Next.js** (validação de formulários)
- O Flutter **não** consome — tem seus próprios models Dart

```typescript
// packages/shared-schemas/src/customer.schema.ts
import { z } from 'zod';

export const CreateCustomerSchema = z.object({
  name: z.string().min(2),
  document: z.string().optional(),   // CPF ou CNPJ
  email: z.string().email().optional(),
  phone: z.string().optional(),
});

export type CreateCustomerDto = z.infer<typeof CreateCustomerSchema>;
```

---

### `apps/backend` — NestJS

- **Runtime:** Node.js 20+ com TypeScript strict
- **Framework:** NestJS com arquitetura modular
- **ORM:** Prisma (conectado ao Supabase PostgreSQL)
- **Validação:** `nestjs-zod` — converte Zod schemas em DTOs + gera Swagger automaticamente
- **Auth:** Supabase Auth — JWT validado via guard no NestJS
- **Docs:** Swagger via `@nestjs/swagger` + `patchNestJsSwagger()` do nestjs-zod
- **Testes:** Jest (unit) + Supertest (e2e)

```typescript
// apps/backend/src/modules/customers/dto/create-customer.dto.ts
import { createZodDto } from 'nestjs-zod';
import { CreateCustomerSchema } from '@mei/shared-schemas';

export class CreateCustomerDto extends createZodDto(CreateCustomerSchema) {}
```

```typescript
// apps/backend/src/main.ts
import { patchNestJsSwagger } from 'nestjs-zod';
patchNestJsSwagger(); // antes de NestFactory.create()

app.useGlobalPipes(new ZodValidationPipe());
```

**Estrutura de módulo:**
```
src/modules/{nome}/
├── {nome}.controller.ts
├── {nome}.service.ts
├── dto/
│   ├── create-{nome}.dto.ts   ← extends createZodDto(Schema)
│   └── update-{nome}.dto.ts
└── {nome}.module.ts
```

---

### `apps/web` — Next.js 15

- **Framework:** Next.js 15 com App Router
- **Linguagem:** TypeScript strict
- **Validação de forms:** `react-hook-form` + `@hookform/resolvers/zod` + schemas do `shared-schemas`
- **HTTP client:** `fetch` nativo (server components) / `axios` ou `ky` (client components)
- **Auth:** `supabase-js` para sessão — token passado ao NestJS via header
- **Estilo:** Tailwind CSS v4 + design tokens do `packages/design-tokens`
- **UI components:** shadcn/ui (base) customizado com os tokens

```typescript
// apps/web/src/features/customers/components/customer-form.tsx
import { zodResolver } from '@hookform/resolvers/zod';
import { CreateCustomerSchema } from '@mei/shared-schemas';

const form = useForm({
  resolver: zodResolver(CreateCustomerSchema), // mesmo schema do backend
});
```

---

### `apps/mobile` — Flutter

- **Flutter:** 3.x (stable), Dart 3
- **Estado:** Riverpod (riverpod_annotation + code generation)
- **Navegação:** GoRouter
- **HTTP:** Dio + Retrofit (dio_generator)
- **Auth:** `supabase_flutter` para sessão, JWT enviado ao NestJS
- **Models:** `freezed` + `json_serializable` (não usa Zod — é Dart)
- **UI:** Material 3 com tema baseado nos design tokens (tokens.dart)
- **Arquitetura:** Feature-first + Clean Architecture leve

```
lib/
├── core/              ← theme, router, di, constants
├── shared/            ← widgets globais, extensions, utils
└── features/
    └── {feature}/
        ├── data/      ← repositories impl, datasources, models (freezed)
        ├── domain/    ← entities, interfaces, use_cases
        └── presentation/ ← screens, widgets, providers (riverpod)
```

---

### `packages/design-tokens`

Fonte única de design (Figma → tokens.json):
- `tokens.css` → consumido pelo Next.js (Tailwind custom properties)
- `tokens.dart` → consumido pelo Flutter (ThemeData)

Nunca hardcode cores, tamanhos ou espaçamentos fora dos tokens.

---

### Banco de Dados — Supabase

- **Local:** Supabase self-hosted via Docker para desenvolvimento
- **Produção:** Supabase Cloud (free tier suficiente para MEI)
- **Auth:** Email/senha via Supabase Auth
- **Storage:** Supabase Storage para uploads (comprovantes, logo)
- **RLS:** Ativado em todas as tabelas
  - NestJS usa `service_role` key (acesso total, aplica regras via Prisma/userId)
  - Flutter/Next.js usam `anon` key apenas para auth

---

## 🔐 Auth Flow

```
[Next.js / Flutter]
  └─► Supabase Auth → login → JWT
        └─► Header: Authorization: Bearer <JWT>
              └─► NestJS AuthGuard valida JWT com Supabase Admin SDK
                    └─► Extrai user_id → injeta em todos os services
                          └─► Prisma filtra por userId em todas as queries
```

---

## 🗄️ Schema do Banco (Supabase / PostgreSQL)

```sql
CREATE TABLE profiles (
  id UUID REFERENCES auth.users PRIMARY KEY,
  full_name TEXT,
  cnpj TEXT,
  business_name TEXT,
  phone TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE customers (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users NOT NULL,
  name TEXT NOT NULL,
  document TEXT,
  phone TEXT,
  email TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE service_catalog (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  default_price NUMERIC(10,2),
  category TEXT
);

CREATE TABLE service_orders (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users NOT NULL,
  customer_id UUID REFERENCES customers,
  status TEXT DEFAULT 'rascunho', -- rascunho|aberta|concluida|cancelada
  total_amount NUMERIC(10,2),
  notes TEXT,
  due_date DATE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE order_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  order_id UUID REFERENCES service_orders ON DELETE CASCADE,
  service_id UUID REFERENCES service_catalog,
  description TEXT,
  quantity INTEGER DEFAULT 1,
  unit_price NUMERIC(10,2),
  total_price NUMERIC(10,2)
);

CREATE TABLE financial_entries (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users NOT NULL,
  type TEXT NOT NULL,   -- receita|despesa
  category TEXT,
  amount NUMERIC(10,2) NOT NULL,
  description TEXT,
  date DATE NOT NULL,
  order_id UUID REFERENCES service_orders,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## 📋 Funcionalidades do MEI (Escopo)

> Analise o MVP existente e marque o que já está implementado antes de começar.

### Módulo: Auth
- [ ] Login email/senha via Supabase Auth
- [ ] Perfil do MEI (nome, CNPJ, razão social)

### Módulo: Clientes
- [ ] CRUD de clientes
- [ ] Busca e filtro
- [ ] Histórico de OS por cliente

### Módulo: Catálogo de Serviços/Produtos
- [ ] CRUD com categorias e preço padrão

### Módulo: Ordens de Serviço
- [ ] Criação de OS (cliente + itens do catálogo)
- [ ] Status: rascunho → aberta → concluída → cancelada
- [ ] Cálculo automático de total

### Módulo: Financeiro
- [ ] Lançamentos de receita e despesa
- [ ] Controle do DAS mensal (vence todo dia 20)
- [ ] Saldo por período

### Módulo: Dashboard
- [ ] Resumo do mês (receita, despesa, saldo)
- [ ] Últimas OS
- [ ] Alertas (DAS vencendo, OS em aberto)

---

## 🧪 Regras para o AI Assistant

1. **Leia o MVP existente primeiro** — liste arquivos, entenda modelos e rotas antes de criar qualquer coisa.
2. **Schemas Zod no `packages/shared-schemas`** — nunca crie validação inline no controller ou no form.
3. **Tipos TypeScript sempre inferidos** via `z.infer<>` — nunca declare interfaces/types duplicados.
4. **DTOs no NestJS** sempre via `createZodDto()` do nestjs-zod.
5. **Forms no Next.js** sempre com `zodResolver` apontando pro schema compartilhado.
6. **Models no Flutter** com `freezed` + `json_serializable` — não tente usar Zod em Dart.
7. **Migrations versionadas** em `supabase/migrations/YYYYMMDD_descricao.sql`.
8. **Nenhum `print()`/`console.log()`** em produção — use `Logger` (NestJS) e `logger` package (Flutter).
9. **Design tokens** são a única fonte de cores, espaçamentos e tipografia — nunca hardcode valores.
10. **Pergunte antes de criar** qualquer tabela nova — valide contra o schema acima.
11. **Commits semânticos:** `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`.

---

## 🚀 Setup Local (Dev)

```bash
# 1. Instalar dependências (Turborepo)
npm install

# 2. Subir Supabase local + API
docker-compose up -d

# 3. Rodar migrations
npx supabase db push

# 4. Rodar tudo junto (Turborepo)
npx turbo dev

# Ou individualmente:
cd apps/backend && npm run start:dev
cd apps/web && npm run dev
cd apps/mobile && flutter run
```

---

## 📦 Variáveis de Ambiente

```env
# apps/backend/.env
DATABASE_URL=postgresql://postgres:postgres@localhost:54322/postgres
SUPABASE_URL=http://localhost:54321
SUPABASE_SERVICE_ROLE_KEY=...
SUPABASE_JWT_SECRET=...
PORT=3000

# apps/web/.env.local
NEXT_PUBLIC_SUPABASE_URL=http://localhost:54321
NEXT_PUBLIC_SUPABASE_ANON_KEY=...
NEXT_PUBLIC_API_URL=http://localhost:3000

# apps/mobile — lib/core/constants/env.dart
SUPABASE_URL=http://localhost:54321
SUPABASE_ANON_KEY=...
API_BASE_URL=http://localhost:3000
```

---

*Projeto de portfólio e estudo da stack Expatier (Next.js + Flutter + NestJS + Supabase + Zod). Escopo simples, arquitetura profissional.*
