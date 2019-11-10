import 'dart:collection';

import 'package:flutter/material.dart';

import '../models/category.dart';
import '../models/post.dart';
import '../models/topic.dart';
import '../models/user.dart';

class CategoryState {
  final Category category;
  final List<Topic> topics;
  final int topicsCount;

  CategoryState({
    @required this.category,
    @required this.topics,
    @required this.topicsCount,
  })  : assert(category != null),
        assert(topics != null),
        assert(topicsCount != null);

  CategoryState copy({
    Category category,
    List<Topic> topics,
    int topicsCount,
  }) {
    return CategoryState(
      category: category ?? this.category,
      topics: topics ?? this.topics,
      topicsCount: topicsCount ?? this.topicsCount,
    );
  }
}

class TopicState {
  final Topic topic;
  final ListQueue<Post> posts;

  TopicState({
    @required this.topic,
    @required this.posts,
  }) : assert(topic != null && posts != null);

  TopicState copy({
    Topic topic,
    ListQueue<Post> posts,
  }) {
    return TopicState(
      topic: topic ?? this.topic,
      posts: posts ?? this.posts,
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
