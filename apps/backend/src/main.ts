import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { patchNestJsSwagger, ZodValidationPipe } from 'nestjs-zod';

async function bootstrap() {
  patchNestJsSwagger(); // Ensure Zod types are extracted correctly

  const app = await NestFactory.create(AppModule);
  
  app.enableCors();
  
  // Use Zod globally for validation
  app.useGlobalPipes(new ZodValidationPipe());

  const config = new DocumentBuilder()
    .setTitle('MEI Manager API')
    .setDescription('The API for Sabor do Parque backend')
    .setVersion('1.0')
    .addBearerAuth()
    .build();
    
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api/docs', app, document);

  await app.listen(process.env.PORT ?? 3000);
}
bootstrap();
