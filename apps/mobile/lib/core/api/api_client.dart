import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configura e retorna a instância global do Dio.
/// Injeta o API_BASE_URL do .env e intercepta requests
/// para adicionar o token de autenticação (quando disponível).
Dio createDioClient() {
  final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';

  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Interceptor de logging para debug
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
  ));

  // TODO: Adicionar interceptor de Auth (Supabase JWT)
  // dio.interceptors.add(AuthInterceptor());

  return dio;
}
