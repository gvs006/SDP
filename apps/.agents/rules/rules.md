# mei-manager — Agent Rules

## Stack
- **Monorepo:** Turborepo — `apps/web` (Next.js 15), `apps/mobile` (Flutter 3), `apps/backend` (NestJS), `packages/shared-schemas` (Zod), `packages/design-tokens`
- **DB:** Supabase (Postgres + Auth + Storage) via Prisma no backend
- **Validação:** Zod em `shared-schemas` → `nestjs-zod` no backend → `zodResolver` no web. Flutter usa `freezed`+`json_serializable`
- **Auth:** Supabase Auth → JWT → NestJS AuthGuard → `user_id` injetado em todas as queries Prisma

## Regras Absolutas
1. Leia os arquivos existentes antes de criar qualquer coisa — não quebre o MVP
2. Schemas de validação sempre em `packages/shared-schemas`, nunca inline
3. Tipos TypeScript sempre via `z.infer<>` — nunca declare interfaces duplicadas
4. DTOs no NestJS sempre via `createZodDto()` do `nestjs-zod`
5. Forms no Next.js sempre com `zodResolver` + schema do `shared-schemas`
6. Models Flutter com `freezed` — não use Zod em Dart
7. Migrations em `supabase/migrations/YYYYMMDD_descricao.sql`
8. Sem `console.log()`/`print()` em produção — use `Logger` (NestJS) / `logger` pkg (Flutter)
9. Design tokens são a única fonte de cores, espaçamentos e tipografia
10. Pergunte antes de criar nova tabela — valide contra o schema existente
11. Commits semânticos: `feat:` `fix:` `chore:` `docs:` `refactor:`

## Estrutura de Módulo NestJS
```
src/modules/{nome}/
├── {nome}.controller.ts
├── {nome}.service.ts
├── dto/create-{nome}.dto.ts  ← createZodDto(Schema)
└── {nome}.module.ts
```

## Estrutura de Feature Flutter
```
features/{nome}/
├── data/       ← repository impl, datasources, models (freezed)
├── domain/     ← entities, interfaces, use_cases
└── presentation/ ← screens, widgets, providers (riverpod)
```

## Auth Flow
`[Web/Mobile]` → Supabase Auth → JWT → `Authorization: Bearer` → NestJS AuthGuard → `user_id` → Prisma (filtra por `userId` em tudo)

## DB Schema (tabelas existentes)
`profiles`, `customers`, `service_catalog`, `service_orders`, `order_items`, `financial_entries` — todas com `user_id UUID REFERENCES auth.users`

## Env Keys
| App | Vars |
|---|---|
| backend | `DATABASE_URL`, `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`, `SUPABASE_JWT_SECRET` |
| web | `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY`, `NEXT_PUBLIC_API_URL` |
| mobile | `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `API_BASE_URL` |
