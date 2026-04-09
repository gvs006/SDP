// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DashboardStats _$DashboardStatsFromJson(Map<String, dynamic> json) =>
    _DashboardStats(
      faturamentoHoje: (json['faturamentoHoje'] as num?)?.toDouble() ?? 0,
      lucroHoje: (json['lucroHoje'] as num?)?.toDouble() ?? 0,
      vendasHoje: (json['vendasHoje'] as num?)?.toInt() ?? 0,
      estoqueTotal: (json['estoqueTotal'] as num?)?.toInt() ?? 0,
      estoqueBaixo: (json['estoqueBaixo'] as num?)?.toInt() ?? 0,
      totalFlavors: (json['totalFlavors'] as num?)?.toInt() ?? 0,
      faturamentoTotal: (json['faturamentoTotal'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$DashboardStatsToJson(_DashboardStats instance) =>
    <String, dynamic>{
      'faturamentoHoje': instance.faturamentoHoje,
      'lucroHoje': instance.lucroHoje,
      'vendasHoje': instance.vendasHoje,
      'estoqueTotal': instance.estoqueTotal,
      'estoqueBaixo': instance.estoqueBaixo,
      'totalFlavors': instance.totalFlavors,
      'faturamentoTotal': instance.faturamentoTotal,
    };
