import 'package:freezed_annotation/freezed_annotation.dart';

part 'flavor_model.freezed.dart';
part 'flavor_model.g.dart';

@freezed
abstract class FlavorModel with _$FlavorModel {
  const factory FlavorModel({
    required String id,
    required String externalId,
    required String name,
    required String linha,
    required double preco,
    required int rendimento,
    required double custoUnit,
    required double margem,
    @Default(0) int estoque,
    @Default(5) int minStock,
  }) = _FlavorModel;

  factory FlavorModel.fromJson(Map<String, dynamic> json) =>
      _$FlavorModelFromJson(json);
}
