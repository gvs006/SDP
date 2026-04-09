import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../data/models/customer_model.dart';
import '../../data/datasources/customer_api.dart';
import '../../data/repositories/customer_repository.dart';
import '../../../../core/api/api_client.dart';

// --- Dio provider ---
final dioProvider = Provider<Dio>((ref) => createDioClient());

// --- API provider ---
final customerApiProvider = Provider<CustomerApi>((ref) {
  final dio = ref.watch(dioProvider);
  return CustomerApi(dio);
});

// --- Repository provider ---
final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  final api = ref.watch(customerApiProvider);
  return CustomerRepository(api);
});

// --- Lista de clientes (async) ---
final customersListProvider =
    FutureProvider.autoDispose<List<CustomerModel>>((ref) async {
  final repo = ref.watch(customerRepositoryProvider);
  return repo.getAll();
});

// --- Cliente individual ---
final customerByIdProvider =
    FutureProvider.autoDispose.family<CustomerModel, String>((ref, id) async {
  final repo = ref.watch(customerRepositoryProvider);
  return repo.getById(id);
});
