// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'flavor_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FlavorModel {

 String get id; String get externalId; String get name; String get linha; double get preco; int get rendimento; double get custoUnit; double get margem; int get estoque; int get minStock;
/// Create a copy of FlavorModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FlavorModelCopyWith<FlavorModel> get copyWith => _$FlavorModelCopyWithImpl<FlavorModel>(this as FlavorModel, _$identity);

  /// Serializes this FlavorModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FlavorModel&&(identical(other.id, id) || other.id == id)&&(identical(other.externalId, externalId) || other.externalId == externalId)&&(identical(other.name, name) || other.name == name)&&(identical(other.linha, linha) || other.linha == linha)&&(identical(other.preco, preco) || other.preco == preco)&&(identical(other.rendimento, rendimento) || other.rendimento == rendimento)&&(identical(other.custoUnit, custoUnit) || other.custoUnit == custoUnit)&&(identical(other.margem, margem) || other.margem == margem)&&(identical(other.estoque, estoque) || other.estoque == estoque)&&(identical(other.minStock, minStock) || other.minStock == minStock));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,externalId,name,linha,preco,rendimento,custoUnit,margem,estoque,minStock);

@override
String toString() {
  return 'FlavorModel(id: $id, externalId: $externalId, name: $name, linha: $linha, preco: $preco, rendimento: $rendimento, custoUnit: $custoUnit, margem: $margem, estoque: $estoque, minStock: $minStock)';
}


}

/// @nodoc
abstract mixin class $FlavorModelCopyWith<$Res>  {
  factory $FlavorModelCopyWith(FlavorModel value, $Res Function(FlavorModel) _then) = _$FlavorModelCopyWithImpl;
@useResult
$Res call({
 String id, String externalId, String name, String linha, double preco, int rendimento, double custoUnit, double margem, int estoque, int minStock
});




}
/// @nodoc
class _$FlavorModelCopyWithImpl<$Res>
    implements $FlavorModelCopyWith<$Res> {
  _$FlavorModelCopyWithImpl(this._self, this._then);

  final FlavorModel _self;
  final $Res Function(FlavorModel) _then;

/// Create a copy of FlavorModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? externalId = null,Object? name = null,Object? linha = null,Object? preco = null,Object? rendimento = null,Object? custoUnit = null,Object? margem = null,Object? estoque = null,Object? minStock = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,externalId: null == externalId ? _self.externalId : externalId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,linha: null == linha ? _self.linha : linha // ignore: cast_nullable_to_non_nullable
as String,preco: null == preco ? _self.preco : preco // ignore: cast_nullable_to_non_nullable
as double,rendimento: null == rendimento ? _self.rendimento : rendimento // ignore: cast_nullable_to_non_nullable
as int,custoUnit: null == custoUnit ? _self.custoUnit : custoUnit // ignore: cast_nullable_to_non_nullable
as double,margem: null == margem ? _self.margem : margem // ignore: cast_nullable_to_non_nullable
as double,estoque: null == estoque ? _self.estoque : estoque // ignore: cast_nullable_to_non_nullable
as int,minStock: null == minStock ? _self.minStock : minStock // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [FlavorModel].
extension FlavorModelPatterns on FlavorModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FlavorModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FlavorModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FlavorModel value)  $default,){
final _that = this;
switch (_that) {
case _FlavorModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FlavorModel value)?  $default,){
final _that = this;
switch (_that) {
case _FlavorModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String externalId,  String name,  String linha,  double preco,  int rendimento,  double custoUnit,  double margem,  int estoque,  int minStock)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FlavorModel() when $default != null:
return $default(_that.id,_that.externalId,_that.name,_that.linha,_that.preco,_that.rendimento,_that.custoUnit,_that.margem,_that.estoque,_that.minStock);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String externalId,  String name,  String linha,  double preco,  int rendimento,  double custoUnit,  double margem,  int estoque,  int minStock)  $default,) {final _that = this;
switch (_that) {
case _FlavorModel():
return $default(_that.id,_that.externalId,_that.name,_that.linha,_that.preco,_that.rendimento,_that.custoUnit,_that.margem,_that.estoque,_that.minStock);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String externalId,  String name,  String linha,  double preco,  int rendimento,  double custoUnit,  double margem,  int estoque,  int minStock)?  $default,) {final _that = this;
switch (_that) {
case _FlavorModel() when $default != null:
return $default(_that.id,_that.externalId,_that.name,_that.linha,_that.preco,_that.rendimento,_that.custoUnit,_that.margem,_that.estoque,_that.minStock);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FlavorModel implements FlavorModel {
  const _FlavorModel({required this.id, required this.externalId, required this.name, required this.linha, required this.preco, required this.rendimento, required this.custoUnit, required this.margem, this.estoque = 0, this.minStock = 5});
  factory _FlavorModel.fromJson(Map<String, dynamic> json) => _$FlavorModelFromJson(json);

@override final  String id;
@override final  String externalId;
@override final  String name;
@override final  String linha;
@override final  double preco;
@override final  int rendimento;
@override final  double custoUnit;
@override final  double margem;
@override@JsonKey() final  int estoque;
@override@JsonKey() final  int minStock;

/// Create a copy of FlavorModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FlavorModelCopyWith<_FlavorModel> get copyWith => __$FlavorModelCopyWithImpl<_FlavorModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FlavorModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FlavorModel&&(identical(other.id, id) || other.id == id)&&(identical(other.externalId, externalId) || other.externalId == externalId)&&(identical(other.name, name) || other.name == name)&&(identical(other.linha, linha) || other.linha == linha)&&(identical(other.preco, preco) || other.preco == preco)&&(identical(other.rendimento, rendimento) || other.rendimento == rendimento)&&(identical(other.custoUnit, custoUnit) || other.custoUnit == custoUnit)&&(identical(other.margem, margem) || other.margem == margem)&&(identical(other.estoque, estoque) || other.estoque == estoque)&&(identical(other.minStock, minStock) || other.minStock == minStock));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,externalId,name,linha,preco,rendimento,custoUnit,margem,estoque,minStock);

@override
String toString() {
  return 'FlavorModel(id: $id, externalId: $externalId, name: $name, linha: $linha, preco: $preco, rendimento: $rendimento, custoUnit: $custoUnit, margem: $margem, estoque: $estoque, minStock: $minStock)';
}


}

/// @nodoc
abstract mixin class _$FlavorModelCopyWith<$Res> implements $FlavorModelCopyWith<$Res> {
  factory _$FlavorModelCopyWith(_FlavorModel value, $Res Function(_FlavorModel) _then) = __$FlavorModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String externalId, String name, String linha, double preco, int rendimento, double custoUnit, double margem, int estoque, int minStock
});




}
/// @nodoc
class __$FlavorModelCopyWithImpl<$Res>
    implements _$FlavorModelCopyWith<$Res> {
  __$FlavorModelCopyWithImpl(this._self, this._then);

  final _FlavorModel _self;
  final $Res Function(_FlavorModel) _then;

/// Create a copy of FlavorModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? externalId = null,Object? name = null,Object? linha = null,Object? preco = null,Object? rendimento = null,Object? custoUnit = null,Object? margem = null,Object? estoque = null,Object? minStock = null,}) {
  return _then(_FlavorModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,externalId: null == externalId ? _self.externalId : externalId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,linha: null == linha ? _self.linha : linha // ignore: cast_nullable_to_non_nullable
as String,preco: null == preco ? _self.preco : preco // ignore: cast_nullable_to_non_nullable
as double,rendimento: null == rendimento ? _self.rendimento : rendimento // ignore: cast_nullable_to_non_nullable
as int,custoUnit: null == custoUnit ? _self.custoUnit : custoUnit // ignore: cast_nullable_to_non_nullable
as double,margem: null == margem ? _self.margem : margem // ignore: cast_nullable_to_non_nullable
as double,estoque: null == estoque ? _self.estoque : estoque // ignore: cast_nullable_to_non_nullable
as int,minStock: null == minStock ? _self.minStock : minStock // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
