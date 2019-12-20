import 'package:async_redux/async_redux.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:flutter/foundation.dart';

import '../../models/topic.dart';

part 'topic_state.g.dart';

class PostVoted {
  final int postId;
  final int delta;

  PostVoted({
    @required this.postId,
    @required this.delta,
  });
}

abstract class TopicState implements Built<TopicState, TopicStateBuilder> {
  TopicState._() {
    if (initialized) assert(topic != null);
    assert(0 <= firstPage && firstPage <= lastPage && lastPage <= maxPage);
  }

  factory TopicState([Function(TopicStateBuilder) updates]) = _$TopicState;

  bool get initialized;

  @nullable
  Topic get topic;

  BuiltSet<int> get postIds;
  Event<String> get snackBarEvt;
  bool get isFavorited;

  int get firstPage;
  int get lastPage;
  int get maxPage;

  @memoized
  bool get hasRechedMin => firstPage == 0;

  @memoized
  bool get hasRechedMax => lastPage == maxPage;

  static void _initializeBuilder(TopicStateBuilder b) => b
    ..initialized = false
    ..snackBarEvt = Event.spent()
    ..isFavorited = false
    ..firstPage = 0
    ..lastPage = 0
    ..maxPage = 0;

  static TopicStateBuilder fromJson() => TopicStateBuilder();
}
