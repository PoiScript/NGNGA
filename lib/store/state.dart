import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

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

class Editing {
  final String subject;
  final String content;
  final String attachUrl;

  Editing({
    @required this.subject,
    @required this.content,
    @required this.attachUrl,
  });
}

class AppState {
  final List<Topic> favorTopics;
  final List<Category> savedCategories;
  final Map<int, User> users;
  final Map<int, CategoryState> categories;
  final Map<int, TopicState> topics;
  final List<String> cookies;
  final bool isLoading;

  final Event<Post> fetchReplyEvt;
  final Event<Editing> setEditingEvt;

  AppState({
    @required this.isLoading,
    @required this.favorTopics,
    @required this.savedCategories,
    @required this.cookies,
    @required this.users,
    @required this.topics,
    @required this.categories,
    @required this.fetchReplyEvt,
    @required this.setEditingEvt,
  })  : assert(categories != null),
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
    List<String> cookies,
    bool isLoading,
    Event<Post> fetchReplyEvt,
    Event<Editing> setEditing,
  }) {
    return AppState(
      savedCategories: savedCategories ?? this.savedCategories,
      favorTopics: favorTopics ?? this.favorTopics,
      categories: categories ?? this.categories,
      topics: topics ?? this.topics,
      users: users ?? this.users,
      cookies: cookies ?? this.cookies,
      isLoading: isLoading ?? this.isLoading,
      fetchReplyEvt: fetchReplyEvt ?? this.fetchReplyEvt,
      setEditingEvt: setEditing ?? this.setEditingEvt,
    );
  }

  factory AppState.empty() {
    return AppState(
      cookies: List(),
      savedCategories: List(),
      isLoading: false,
      categories: Map(),
      topics: Map(),
      users: Map(),
      favorTopics: List(),
      fetchReplyEvt: Event.spent(),
      setEditingEvt: Event.spent(),
    );
  }
}

Future<AppState> initState() async {
  final state = AppState.empty();

  final directory = await getApplicationDocumentsDirectory();

  List<Category> savedCategories;
  List<String> cookies;

  try {
    final file = File('${directory.path}/state.json');

    String contents = await file.readAsString();
    final json = jsonDecode(contents);

    savedCategories = List.from(json["saved_cateogries"])
        .map((x) => Category.fromJson(x))
        .toList();

    cookies = List<String>.from(json["cookies"]);
  } catch (_) {}

  return state.copy(
    cookies: cookies,
    savedCategories: savedCategories,
  );
}
