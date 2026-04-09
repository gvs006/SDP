import { createParamDecorator, ExecutionContext } from '@nestjs/common';

/**
 * Decorator que extrai o user autenticado do request.
 * Uso: @CurrentUser() user: { id: string }
 */
export const CurrentUser = createParamDecorator(
  (data: unknown, ctx: ExecutionContext) => {
    const request = ctx.switchToHttp().getRequest();
    return request.user;
  },
);
