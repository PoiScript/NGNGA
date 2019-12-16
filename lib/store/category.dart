import 'package:flutter/widgets.dart';

import 'package:ngnga/models/category.dart';

abstract class CategoryState {
  const CategoryState();
}

class CategoryUninitialized extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final Category category;
  final int toppedTopicId;
  final List<int> topicIds;
  final bool isPinned;

  final int topicsCount;

  final int lastPage;
  final int maxPage;

  bool get hasRechedMax => lastPage == maxPage;

  const CategoryLoaded({
    @required this.category,
    @required this.toppedTopicId,
    @required this.isPinned,
    @required this.topicIds,
    @required this.topicsCount,
    @required this.lastPage,
    @required this.maxPage,
  })  : assert(topicIds != null),
        assert(topicsCount >= 0),
        assert(maxPage >= lastPage);

  CategoryLoaded copyWith({
    Category category,
    int toppedTopicId,
    bool isPinned,
    List<int> topicIds,
    int topicsCount,
    int lastPage,
    int maxPage,
  }) =>
      CategoryLoaded(
        category: category ?? this.category,
        toppedTopicId: toppedTopicId ?? this.toppedTopicId,
        isPinned: isPinned ?? this.isPinned,
        topicIds: topicIds ?? this.topicIds,
        topicsCount: topicsCount ?? this.topicsCount,
        lastPage: lastPage ?? this.lastPage,
        maxPage: maxPage ?? this.maxPage,
      );
}
