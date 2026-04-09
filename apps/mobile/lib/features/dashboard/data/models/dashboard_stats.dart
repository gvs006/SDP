import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_stats.freezed.dart';
part 'dashboard_stats.g.dart';

@freezed
abstract class DashboardStats with _$DashboardStats {
  const factory DashboardStats({
    @Default(0) double faturamentoHoje,
    @Default(0) double lucroHoje,
    @Default(0) int vendasHoje,
    @Default(0) int estoqueTotal,
    @Default(0) int estoqueBaixo,
    @Default(0) int totalFlavors,
    @Default(0) double faturamentoTotal,
  }) = _DashboardStats;

  factory DashboardStats.fromJson(Map<String, dynamic> json) =>
      _$DashboardStatsFromJson(json);
}
