import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/flavor_model.dart';

part 'catalog_api.g.dart';

@RestApi()
abstract class CatalogApi {
  factory CatalogApi(Dio dio, {String baseUrl}) = _CatalogApi;

  @GET('/catalog')
  Future<List<FlavorModel>> getAll();

  @GET('/catalog/{id}')
  Future<FlavorModel> getById(@Path('id') String id);

  @PATCH('/catalog/{id}/price')
  Future<FlavorModel> updatePrice(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );
}
