import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../common/prisma';
import { CreateCustomerDto, UpdateCustomerDto } from './dto';

@Injectable()
export class CustomersService {
  private readonly logger = new Logger(CustomersService.name);

  constructor(private readonly prisma: PrismaService) {}

  async create(userId: string, dto: CreateCustomerDto) {
    this.logger.log(`Criando cliente para user ${userId}`);
    return this.prisma.customer.create({
      data: {
        userId,
        ...dto,
      },
    });
  }

  async findAll(userId: string) {
    return this.prisma.customer.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });
  }

  async findOne(userId: string, id: string) {
    const customer = await this.prisma.customer.findFirst({
      where: { id, userId },
    });
    if (!customer) {
      throw new NotFoundException(`Cliente ${id} não encontrado`);
    }
    return customer;
  }

  async update(userId: string, id: string, dto: UpdateCustomerDto) {
    await this.findOne(userId, id); // garante que pertence ao user
    return this.prisma.customer.update({
      where: { id },
      data: dto,
    });
  }

  async remove(userId: string, id: string) {
    await this.findOne(userId, id);
    return this.prisma.customer.delete({ where: { id } });
  }
}
