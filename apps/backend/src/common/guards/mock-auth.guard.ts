import {
  Injectable,
  CanActivate,
  ExecutionContext,
  Logger,
} from '@nestjs/common';

/**
 * MockAuthGuard — Bypass de autenticação para desenvolvimento.
 *
 * Injeta um user_id fixo no request para simular um MEI logado.
 * TODO: Substituir por SupabaseAuthGuard real que valida o JWT
 *       com Supabase Admin SDK antes de ir para produção.
 */
const MOCK_USER_ID = '00000000-0000-0000-0000-000000000001';

@Injectable()
export class MockAuthGuard implements CanActivate {
  private readonly logger = new Logger(MockAuthGuard.name);

  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest();
    request.user = { id: MOCK_USER_ID };
    this.logger.warn(
      `[DEV] MockAuthGuard ativo — user_id fixo: ${MOCK_USER_ID}`,
    );
    return true;
  }
}
