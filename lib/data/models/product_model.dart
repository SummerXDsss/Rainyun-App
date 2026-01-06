import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

@freezed
class ProductModel with _$ProductModel {
  const factory ProductModel({
    required String id,
    required String name,
    required String type,
    String? description,
    @Default(0.0) double price,
    String? region,
    Map<String, dynamic>? specs,
    @Default(0) int stock,
    @Default(false) bool hasPublicIp,
    @Default(true) bool available,
  }) = _ProductModel;

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);
}

@freezed
class ProductCategory with _$ProductCategory {
  const factory ProductCategory({
    required String id,
    required String name,
    required String type,
    @Default([]) List<ProductModel> products,
  }) = _ProductCategory;

  factory ProductCategory.fromJson(Map<String, dynamic> json) =>
      _$ProductCategoryFromJson(json);
}
