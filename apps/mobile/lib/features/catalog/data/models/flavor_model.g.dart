// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flavor_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FlavorModel _$FlavorModelFromJson(Map<String, dynamic> json) => _FlavorModel(
  id: json['id'] as String,
  externalId: json['externalId'] as String,
  name: json['name'] as String,
  linha: json['linha'] as String,
  preco: (json['preco'] as num).toDouble(),
  rendimento: (json['rendimento'] as num).toInt(),
  custoUnit: (json['custoUnit'] as num).toDouble(),
  margem: (json['margem'] as num).toDouble(),
  estoque: (json['estoque'] as num?)?.toInt() ?? 0,
  minStock: (json['minStock'] as num?)?.toInt() ?? 5,
);

Map<String, dynamic> _$FlavorModelToJson(_FlavorModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'externalId': instance.externalId,
      'name': instance.name,
      'linha': instance.linha,
      'preco': instance.preco,
      'rendimento': instance.rendimento,
      'custoUnit': instance.custoUnit,
      'margem': instance.margem,
      'estoque': instance.estoque,
      'minStock': instance.minStock,
    };
