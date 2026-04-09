import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/dashboard_stats.dart';

part 'dashboard_api.g.dart';

@RestApi()
abstract class DashboardApi {
  factory DashboardApi(Dio dio, {String baseUrl}) = _DashboardApi;

  @GET('/catalog/dashboard')
  Future<DashboardStats> getStats();
}
