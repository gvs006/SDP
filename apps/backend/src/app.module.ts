import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PrismaModule } from './common/prisma';
import { CustomersModule } from './modules/customers/customers.module';
import { CatalogModule } from './modules/catalog/catalog.module';

@Module({
  imports: [PrismaModule, CustomersModule, CatalogModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
