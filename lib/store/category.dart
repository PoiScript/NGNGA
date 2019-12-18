import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';

import 'package:ngnga/models/category.dart';

part 'category.g.dart';

abstract class CategoryState
    implements Built<CategoryState, CategoryStateBuilder> {
  CategoryState._() {
    assert(0 <= firstPage && firstPage <= lastPage && lastPage <= maxPage);
  }

  factory CategoryState([Function(CategoryStateBuilder) updates]) =
      _$CategoryState;

  bool get initialized;

  @nullable
  Category get category;

  @nullable
  int get toppedTopicId;

  BuiltSet<int> get topicIds;

  bool get isPinned;
  int get topicsCount;
  int get firstPage;
  int get lastPage;
  int get maxPage;

  @memoized
  bool get hasRechedMin => firstPage == 0;

  @memoized
  bool get hasRechedMax => lastPage == maxPage;

  static void _initializeBuilder(CategoryStateBuilder b) => b
    ..initialized = false
    ..isPinned = false
    ..topicsCount = 0
    ..firstPage = 0
    ..lastPage = 0
    ..maxPage = 0;
}
