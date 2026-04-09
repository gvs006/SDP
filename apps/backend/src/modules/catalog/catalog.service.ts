import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../../common/prisma';
import { Decimal } from '@prisma/client/runtime/library';

@Injectable()
export class CatalogService {
  private readonly logger = new Logger(CatalogService.name);

  constructor(private readonly prisma: PrismaService) {}

  /**
   * Retorna todos os sabores com custo unitário CALCULADO dinamicamente
   * a partir dos ingredientes reais.
   */
  async findAll() {
    const flavors = await this.prisma.flavor.findMany({
      include: {
        ingredients: {
          include: { ingredient: true },
        },
        stock: true,
      },
      orderBy: [{ linha: 'asc' }, { name: 'asc' }],
    });

    return flavors.map((f) => ({
      id: f.id,
      externalId: f.externalId,
      name: f.name,
      linha: f.linha,
      preco: Number(f.preco),
      rendimento: f.rendimento,
      custoUnit: this.calcCustoUnit(f),
      margem: this.calcMargem(f),
      estoque: f.stock?.quantity ?? 0,
      minStock: f.stock?.minStock ?? 5,
    }));
  }

  async findOne(id: string) {
    const f = await this.prisma.flavor.findUniqueOrThrow({
      where: { id },
      include: {
        ingredients: {
          include: { ingredient: true },
        },
        stock: true,
      },
    });

    return {
      ...f,
      preco: Number(f.preco),
      custoUnit: this.calcCustoUnit(f),
      margem: this.calcMargem(f),
      ingredients: f.ingredients.map((fi) => ({
        name: fi.ingredient.name,
        key: fi.ingredient.key,
        quantity: Number(fi.quantity),
        costPerUnit: Number(fi.ingredient.costPerUnit),
        subtotal: Number(fi.quantity) * Number(fi.ingredient.costPerUnit),
        source: fi.source,
      })),
    };
  }

  async updatePrice(id: string, preco: number) {
    return this.prisma.flavor.update({
      where: { id },
      data: { preco },
    });
  }

  /**
   * Calcula custo unitário: soma(ingrediente.cost * quantidade) / rendimento
   */
  private calcCustoUnit(flavor: {
    rendimento: number;
    ingredients: Array<{
      quantity: Decimal;
      ingredient: { costPerUnit: Decimal };
    }>;
  }): number {
    const batchCost = flavor.ingredients.reduce(
      (sum, fi) =>
        sum + Number(fi.quantity) * Number(fi.ingredient.costPerUnit),
      0,
    );
    return Math.round((batchCost / flavor.rendimento) * 100) / 100;
  }

  private calcMargem(flavor: {
    preco: Decimal;
    rendimento: number;
    ingredients: Array<{
      quantity: Decimal;
      ingredient: { costPerUnit: Decimal };
    }>;
  }): number {
    const custoUnit = this.calcCustoUnit(flavor);
    const preco = Number(flavor.preco);
    if (preco === 0) return 0;
    return Math.round(((preco - custoUnit) / preco) * 1000) / 10;
  }

  /**
   * Dashboard stats — resumo do negócio
   */
  async getDashboardStats() {
    const [estoqueData, totalFlavors] = await Promise.all([
      this.prisma.stockEntry.findMany(),
      this.prisma.flavor.count(),
    ]);

    const estoqueTotal = estoqueData.reduce((s, e) => s + e.quantity, 0);
    const estoqueBaixo = estoqueData.filter(
      (e) => e.quantity < e.minStock,
    ).length;

    // TODO: Integrate real sales data when Sales module is built
    return {
      faturamentoHoje: 0,
      lucroHoje: 0,
      vendasHoje: 0,
      estoqueTotal,
      estoqueBaixo,
      totalFlavors,
      faturamentoTotal: 0,
    };
  }
}
