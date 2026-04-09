import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/flavor_model.dart';
import '../../data/datasources/catalog_api.dart';
import '../../../customers/presentation/providers/customer_providers.dart';

final catalogApiProvider = Provider<CatalogApi>((ref) {
  final dio = ref.watch(dioProvider);
  return CatalogApi(dio);
});

final catalogListProvider =
    FutureProvider.autoDispose<List<FlavorModel>>((ref) async {
  final api = ref.watch(catalogApiProvider);
  return api.getAll();
});

final catalogByIdProvider =
    FutureProvider.autoDispose.family<FlavorModel, String>((ref, id) async {
  final api = ref.watch(catalogApiProvider);
  return api.getById(id);
});
