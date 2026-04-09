import { z } from 'zod';

export const CreateCustomerSchema = z.object({
  name: z.string().min(2),
  document: z.string().optional(),
  email: z.string().email().optional(),
  phone: z.string().optional(),
});

export type CreateCustomerDto = z.infer<typeof CreateCustomerSchema>;
