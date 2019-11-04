import 'package:flutter/material.dart';

import '../models/category.dart';
import '../models/post.dart';
import '../models/topic.dart';
import '../models/user.dart';

class CategoryState {
  final Category category;
  final List<int> topicIds;
  final int topicsCount;

  CategoryState({
    @required this.category,
    this.topicIds = const [],
    this.topicsCount = 0,
  })  : assert(category != null),
        assert(topicIds != null),
        assert(topicsCount != null);

  CategoryState copy({
    Category category,
    List<int> topicIds,
    int topicsCount,
  }) {
    return CategoryState(
      category: category ?? this.category,
      topicIds: topicIds ?? this.topicIds,
      topicsCount: topicsCount ?? this.topicsCount,
    );
  }
}

class TopicState {
  final Topic topic;
  final Map<int, Post> posts;

  int get maxPage => topic.postsCount ~/ 20;

  TopicState({
    @required this.topic,
    @required this.posts,
  })  : assert(topic != null),
        assert(posts != null);

  TopicState copy({
    @required Topic topic,
    @required Map<int, Post> pages,
  }) {
    return TopicState(
      topic: topic ?? this.topic,
      posts: pages ?? this.posts,
    );
  }
}

class AppState {
  Map<int, User> users;

  Map<int, CategoryState> categories;

  Map<int, TopicState> topics;

  bool isLoading;

  Map<String, String> cookies;

  AppState({
    this.cookies = const {},
    this.isLoading = false,
    this.users = const {},
    this.topics = const {},
    this.categories = const {},
  })  : assert(cookies != null),
        assert(isLoading != null),
        assert(users != null),
        assert(topics != null),
        assert(categories != null);

  AppState copy({
    Map<int, CategoryState> categories,
    Map<int, TopicState> topics,
    Map<int, User> users,
    Map<String, String> cookies,
    bool isLoading,
  }) {
    return AppState(
      categories: categories ?? this.categories,
      topics: topics ?? this.topics,
      users: users ?? this.users,
      cookies: cookies ?? this.cookies,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
