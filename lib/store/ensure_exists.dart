import 'dart:collection';

import 'package:async_redux/async_redux.dart';

import '../models/category.dart';
import '../models/topic.dart';
import './state.dart';

class EnsureCategoryExistsAction extends ReduxAction<AppState> {
  final Category category;

  EnsureCategoryExistsAction(this.category) : assert(category != null);

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
}

class EnsureTopicExistsAction extends ReduxAction<AppState> {
  final Topic topic;

  EnsureTopicExistsAction(this.topic) : assert(topic != null);

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
}
