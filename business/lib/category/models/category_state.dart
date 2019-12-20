import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';

import '../../models/category.dart';

part 'category_state.g.dart';

abstract class CategoryState
    implements Built<CategoryState, CategoryStateBuilder> {
  CategoryState._() {
    if (initialized) assert(category != null);
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

  BuiltList<String> get keys;

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
