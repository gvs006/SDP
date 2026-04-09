import { createZodDto } from 'nestjs-zod';
import { UpdateCustomerSchema } from '@mei/shared-schemas';

export class UpdateCustomerDto extends createZodDto(UpdateCustomerSchema) {}
