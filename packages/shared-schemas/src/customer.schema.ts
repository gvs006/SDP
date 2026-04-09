import { z } from 'zod';

// --- Create ---
export const CreateCustomerSchema = z.object({
  name: z.string().min(2, 'Nome deve ter pelo menos 2 caracteres'),
  document: z.string().optional(),
  email: z.string().email('Email inválido').optional(),
  phone: z.string().optional(),
});
export type CreateCustomerDto = z.infer<typeof CreateCustomerSchema>;

// --- Update ---
export const UpdateCustomerSchema = CreateCustomerSchema.partial();
export type UpdateCustomerDto = z.infer<typeof UpdateCustomerSchema>;

// --- Response ---
export const CustomerResponseSchema = z.object({
  id: z.string().uuid(),
  userId: z.string().uuid(),
  name: z.string(),
  document: z.string().nullable(),
  email: z.string().nullable(),
  phone: z.string().nullable(),
  createdAt: z.string().datetime(),
});
export type CustomerResponse = z.infer<typeof CustomerResponseSchema>;
