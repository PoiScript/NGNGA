import 'dart:collection';

import 'package:async_redux/async_redux.dart';

import 'package:ngnga/models/category.dart';
import 'package:ngnga/models/topic.dart';

import 'state.dart';

class NavigateToCategoryAction extends ReduxAction<AppState> {
  final Category category;

  NavigateToCategoryAction(this.category) : assert(category != null);

  @override
  AppState reduce() {
    return state.copy(
      categories: state.categories
        ..putIfAbsent(
          category.id,
          () => CategoryState(
            category: category,
            topics: List(),
            lastPage: 0,
            topicsCount: 0,
          ),
        ),
    );
  }

  void after() =>
      dispatch(NavigateAction.pushNamed("/c", arguments: {"id": category.id}));
}

class NavigateToTopicAction extends ReduxAction<AppState> {
  final Topic topic;
  final int page;

  NavigateToTopicAction(this.topic, this.page)
      : assert(topic != null),
        assert(page != null);

  @override
  AppState reduce() {
    return state.copy(
      topics: state.topics
        ..putIfAbsent(
          topic.id,
          () => TopicState(
            topic: topic,
            posts: ListQueue(),
          ),
        ),
    );
  }

  void after() => dispatch(NavigateAction.pushNamed("/t",
      arguments: {"id": topic.id, "page": page}));
}
