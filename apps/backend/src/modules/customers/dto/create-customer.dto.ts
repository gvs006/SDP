import { createZodDto } from 'nestjs-zod';
import { CreateCustomerSchema } from '@mei/shared-schemas';

export class CreateCustomerDto extends createZodDto(CreateCustomerSchema) {}
