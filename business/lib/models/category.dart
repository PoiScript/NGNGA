import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'category.g.dart';

abstract class Category implements Built<Category, CategoryBuilder> {
  static Serializer<Category> get serializer => _$categorySerializer;

  Category._();

  factory Category([Function(CategoryBuilder) updates]) = _$Category;

  int get id;
  @BuiltValueField(compare: false)
  String get title;
  bool get isSubcategory;

  static void _initializeBuilder(CategoryBuilder b) => b.isSubcategory = false;
}
