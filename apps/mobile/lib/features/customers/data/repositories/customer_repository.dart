import '../models/customer_model.dart';
import '../datasources/customer_api.dart';

class CustomerRepository {
  final CustomerApi _api;

  CustomerRepository(this._api);

  Future<List<CustomerModel>> getAll() => _api.getAll();

  Future<CustomerModel> getById(String id) => _api.getById(id);

  Future<CustomerModel> create({
    required String name,
    String? document,
    String? email,
    String? phone,
  }) {
    return _api.create({
      'name': name,
      if (document != null) 'document': document,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
    });
  }

  Future<CustomerModel> update(String id, Map<String, dynamic> data) {
    return _api.update(id, data);
  }

  Future<void> delete(String id) => _api.delete(id);
}
