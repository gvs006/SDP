import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/dashboard_stats.dart';
import '../../data/datasources/dashboard_api.dart';
import '../../../customers/presentation/providers/customer_providers.dart';

final dashboardApiProvider = Provider<DashboardApi>((ref) {
  final dio = ref.watch(dioProvider);
  return DashboardApi(dio);
});

final dashboardStatsProvider =
    FutureProvider.autoDispose<DashboardStats>((ref) async {
  final api = ref.watch(dashboardApiProvider);
  return api.getStats();
});
