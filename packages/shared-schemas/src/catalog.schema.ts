import { z } from 'zod';

// --- Ingredient ---
export const IngredientSchema = z.object({
  key: z.string(),
  name: z.string(),
  costPerUnit: z.number(), // custo por unidade (kg, litro, unidade)
  unit: z.string().optional(),
});
export type Ingredient = z.infer<typeof IngredientSchema>;

// --- Flavor ---
export const FlavorSchema = z.object({
  id: z.string(),
  name: z.string(),
  linha: z.enum(['Gourmet', 'Refrescante']),
  preco: z.number(),
  rendimento: z.number(),
  custoUnit: z.number().optional(), // calculado dinamicamente
});
export type Flavor = z.infer<typeof FlavorSchema>;

// --- Update Flavor Price ---
export const UpdateFlavorPriceSchema = z.object({
  preco: z.number().positive('Preço deve ser positivo'),
});
export type UpdateFlavorPriceDto = z.infer<typeof UpdateFlavorPriceSchema>;

// --- Dashboard Stats ---
export const DashboardStatsSchema = z.object({
  faturamentoHoje: z.number(),
  lucroHoje: z.number(),
  vendasHoje: z.number(),
  estoqueTotal: z.number(),
  estoqueBaixo: z.number(),
  faturamentoTotal: z.number(),
});
export type DashboardStats = z.infer<typeof DashboardStatsSchema>;
