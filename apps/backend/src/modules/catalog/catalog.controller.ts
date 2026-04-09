import { Controller, Get, Param, Patch, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { CatalogService } from './catalog.service';
import { MockAuthGuard } from '../../common/guards';

@ApiTags('Catálogo')
@ApiBearerAuth()
@UseGuards(MockAuthGuard)
@Controller('catalog')
export class CatalogController {
  constructor(private readonly catalogService: CatalogService) {}

  @Get()
  findAll() {
    return this.catalogService.findAll();
  }

  @Get('dashboard')
  getDashboard() {
    return this.catalogService.getDashboardStats();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.catalogService.findOne(id);
  }

  @Patch(':id/price')
  updatePrice(@Param('id') id: string, @Body() body: { preco: number }) {
    return this.catalogService.updatePrice(id, body.preco);
  }
}
