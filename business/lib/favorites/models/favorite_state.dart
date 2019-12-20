import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';

part 'favorite_state.g.dart';

abstract class FavoriteState
    implements Built<FavoriteState, FavoriteStateBuilder> {
  FavoriteState._();

  factory FavoriteState([Function(FavoriteStateBuilder) updates]) =
      _$FavoriteState;

  bool get initialized;
  BuiltList<int> get topicIds;
  int get topicsCount;
  int get lastPage;
  int get maxPage;

  static void _initializeBuilder(FavoriteStateBuilder b) => b
    ..initialized = false
    ..topicsCount = 0
    ..lastPage = 0
    ..maxPage = 0;
}
