import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/customer_model.dart';

part 'customer_api.g.dart';

@RestApi()
abstract class CustomerApi {
  factory CustomerApi(Dio dio, {String baseUrl}) = _CustomerApi;

  @GET('/customers')
  Future<List<CustomerModel>> getAll();

  @GET('/customers/{id}')
  Future<CustomerModel> getById(@Path('id') String id);

  @POST('/customers')
  Future<CustomerModel> create(@Body() Map<String, dynamic> body);

  @PATCH('/customers/{id}')
  Future<CustomerModel> update(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/customers/{id}')
  Future<void> delete(@Path('id') String id);
}
