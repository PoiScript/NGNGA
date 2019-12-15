import 'package:async_redux/async_redux.dart';
import 'package:flutter/widgets.dart';

import 'package:ngnga/models/topic.dart';

class PostVoted {
  final int postId;
  final int delta;

  PostVoted({this.postId, this.delta});
}

abstract class TopicState {
  const TopicState();
}

class TopicUninitialized extends TopicState {}

class TopicLoaded extends TopicState {
  final Topic topic;
  final List<int> postIds;
  final Event<PostVoted> postVotedEvt;
  final bool isFavorited;

  final int firstPage;
  final int lastPage;
  final int maxPage;

  bool get hasRechedMin => firstPage == 0;
  bool get hasRechedMax => lastPage == maxPage;

  const TopicLoaded({
    @required this.topic,
    @required this.firstPage,
    @required this.lastPage,
    @required this.maxPage,
    @required this.postIds,
    @required this.postVotedEvt,
    @required this.isFavorited,
  })  : assert(postIds != null),
        assert(postVotedEvt != null),
        assert(isFavorited != null),
        assert(maxPage >= lastPage && lastPage >= firstPage && firstPage >= 0);

  TopicLoaded copyWith({
    Topic topic,
    List<int> postIds,
    int firstPage,
    int lastPage,
    int maxPage,
    Event<PostVoted> postVotedEvt,
    bool isFavorited,
  }) =>
      TopicLoaded(
        topic: topic ?? this.topic,
        postIds: postIds ?? this.postIds,
        firstPage: firstPage ?? this.firstPage,
        lastPage: lastPage ?? this.lastPage,
        maxPage: maxPage ?? this.maxPage,
        postVotedEvt: postVotedEvt ?? this.postVotedEvt,
        isFavorited: isFavorited ?? this.isFavorited,
      );
}
