import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:ngnga/models/favorite.dart';

import 'package:ngnga/models/category.dart';
import 'package:ngnga/models/post.dart';
import 'package:ngnga/models/topic.dart';
import 'package:ngnga/models/user.dart';

enum NgaDomain {
  nga178com,
  nagbbscom,
  bbsngacn,
}

enum BackgroundColor {
  white,
  black,
  grey,
}

enum PrimaryColor {
  red,
}

class SettingsState {
  final NgaDomain domain;
  final BackgroundColor backgroundColor;
  final PrimaryColor primaryColor;
  final String uid;
  final String cid;

  SettingsState({
    @required this.uid,
    @required this.cid,
    @required this.domain,
    @required this.backgroundColor,
    @required this.primaryColor,
  })  : assert(domain != null),
        assert(backgroundColor != null),
        assert(primaryColor != null);

  SettingsState.empty()
      : this(
          uid: null,
          cid: null,
          domain: NgaDomain.nga178com,
          backgroundColor: BackgroundColor.white,
          primaryColor: PrimaryColor.red,
        );

  SettingsState copy({
    domain,
    backgroundColor,
    primaryColor,
    uid,
    cid,
  }) {
    return SettingsState(
      uid: uid ?? this.uid,
      cid: cid ?? this.cid,
      domain: domain ?? this.domain,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      primaryColor: primaryColor ?? this.primaryColor,
    );
  }
}

class FavoriteState {
  final List<Favorite> favorites;
  final int favoriteCount;
  final int lastPage;

  FavoriteState({
    @required this.favorites,
    @required this.favoriteCount,
    @required this.lastPage,
  })  : assert(favorites != null),
        assert(favoriteCount != null),
        assert(lastPage != null);

  FavoriteState.empty()
      : this(
          favorites: const [],
          favoriteCount: 0,
          lastPage: 0,
        );

  FavoriteState copy({
    List<Favorite> favorites,
    int favoriteCount,
    int lastPage,
  }) {
    return FavoriteState(
      favorites: favorites ?? this.favorites,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      lastPage: lastPage ?? this.lastPage,
    );
  }
}

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
  final List<Post> posts;

  TopicState({
    @required this.topic,
    @required this.posts,
  }) : assert(topic != null && posts != null);

  TopicState copy({
    Topic topic,
    List<Post> posts,
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

/// A simple wrapper for post, so PostWrapper(null) is used to
/// indicates to a deleted or hidden reply which is now inaccessible.
class PostWrapper {
  final Post post;

  PostWrapper(this.post);
}

class AppState {
  final FavoriteState favorites;
  final SettingsState settings;
  final List<Category> savedCategories;
  final Map<int, User> users;
  final Map<int, CategoryState> categories;
  final Map<int, TopicState> topics;
  final bool isLoading;

  final DateTime lastUpdated;

  final Event<PostWrapper> fetchReplyEvt;
  final Event<Editing> setEditingEvt;
  final Event<String> categorySnackBarEvt;
  final Event<String> topicSnackBarEvt;

  final Client client = Client();

  AppState._({
    @required this.isLoading,
    @required this.settings,
    @required this.favorites,
    @required this.savedCategories,
    @required this.users,
    @required this.topics,
    @required this.categories,
    @required this.lastUpdated,
    @required this.fetchReplyEvt,
    @required this.setEditingEvt,
    @required this.categorySnackBarEvt,
    @required this.topicSnackBarEvt,
  })  : assert(categories != null),
        assert(settings != null),
        assert(favorites != null),
        assert(savedCategories != null),
        assert(isLoading != null),
        assert(users != null),
        assert(topics != null),
        assert(categories != null),
        assert(fetchReplyEvt != null),
        assert(setEditingEvt != null),
        assert(categorySnackBarEvt != null),
        assert(topicSnackBarEvt != null);

  AppState copy({
    SettingsState settings,
    FavoriteState favorites,
    List<Category> savedCategories,
    Map<int, CategoryState> categories,
    Map<int, TopicState> topics,
    Map<int, User> users,
    bool isLoading,
    DateTime lastUpdated,
    Event<PostWrapper> fetchReplyEvt,
    Event<Editing> setEditing,
    Event<String> categorySnackBarEvt,
    Event<String> topicSnackBarEvt,
  }) {
    return AppState._(
      settings: settings ?? this.settings,
      savedCategories: savedCategories ?? this.savedCategories,
      favorites: favorites ?? this.favorites,
      categories: categories ?? this.categories,
      topics: topics ?? this.topics,
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      fetchReplyEvt: fetchReplyEvt ?? this.fetchReplyEvt,
      setEditingEvt: setEditing ?? this.setEditingEvt,
      categorySnackBarEvt: categorySnackBarEvt ?? this.categorySnackBarEvt,
      topicSnackBarEvt: topicSnackBarEvt ?? this.topicSnackBarEvt,
    );
  }

  factory AppState.empty() {
    return AppState._(
      settings: SettingsState.empty(),
      savedCategories: List(),
      isLoading: false,
      categories: Map(),
      topics: Map(),
      users: Map(),
      lastUpdated: DateTime.now(),
      favorites: FavoriteState.empty(),
      fetchReplyEvt: Event.spent(),
      setEditingEvt: Event.spent(),
      categorySnackBarEvt: Event.spent(),
      topicSnackBarEvt: Event.spent(),
    );
  }

  String get baseUrl {
    switch (settings.domain) {
      case NgaDomain.nga178com:
        return "nga.178.com";
      case NgaDomain.bbsngacn:
        return "bbs.nga.cn";
      case NgaDomain.nagbbscom:
        return "ngabbs.com";
    }
    return null;
  }

  String get cookie =>
      "ngaPassportUid=${settings.uid};ngaPassportCid=${settings.cid};";
}
