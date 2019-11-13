import 'dart:collection';

import 'package:flutter/material.dart';

import 'package:ngnga/models/category.dart';
import 'package:ngnga/models/post.dart';
import 'package:ngnga/models/topic.dart';
import 'package:ngnga/models/user.dart';

class CategoryState {
  final Category category;
  final List<Topic> topics;
  final int topicsCount;
  final int lastPage;

  CategoryState({
    @required this.category,
    @required this.topics,
    @required this.topicsCount,
    @required this.lastPage,
  })  : assert(category != null),
        assert(topics != null),
        assert(topicsCount != null),
        assert(lastPage != null);

  CategoryState copy({
    Category category,
    List<Topic> topics,
    int topicsCount,
    int lastPage,
  }) {
    return CategoryState(
      category: category ?? this.category,
      topics: topics ?? this.topics,
      topicsCount: topicsCount ?? this.topicsCount,
      lastPage: lastPage ?? this.lastPage,
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
  final List<Topic> favorTopics;
  final List<Category> savedCategories;
  final Map<int, User> users;
  final Map<int, CategoryState> categories;
  final Map<int, TopicState> topics;
  final Map<String, String> cookies;
  final bool isLoading;

  AppState({
    @required this.isLoading,
    @required this.favorTopics,
    @required this.savedCategories,
    @required this.cookies,
    @required this.users,
    @required this.topics,
    @required this.categories,
  })  : assert(categories != null),
        assert(cookies != null),
        assert(favorTopics != null),
        assert(savedCategories != null),
        assert(isLoading != null),
        assert(topics != null),
        assert(users != null);

  AppState copy({
    List<Topic> favorTopics,
    List<Category> savedCategories,
    Map<int, CategoryState> categories,
    Map<int, TopicState> topics,
    Map<int, User> users,
    Map<String, String> cookies,
    bool isLoading,
  }) {
    return AppState(
      savedCategories: savedCategories ?? this.savedCategories,
      favorTopics: favorTopics ?? this.favorTopics,
      categories: categories ?? this.categories,
      topics: topics ?? this.topics,
      users: users ?? this.users,
      cookies: cookies ?? this.cookies,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
