import 'package:flutter/material.dart';

import 'package:ngnga/models/category.dart';
import 'package:ngnga/models/post.dart';
import 'package:ngnga/models/topic.dart';
import 'package:ngnga/models/user.dart';
import 'package:ngnga/store/favorite.dart';
import 'package:ngnga/utils/repository.dart';

import 'category.dart';
import 'editing.dart';
import 'inbox.dart';
import 'topic.dart';

enum AppTheme { white, black, grey, yellow }

enum AppLocale { en, zh }

enum UserAgent { none, osOnly, full }

class SettingsState {
  final String baseUrl;
  final AppTheme theme;
  final AppLocale locale;
  final UserAgent userAgent;

  SettingsState({
    @required this.baseUrl,
    @required this.theme,
    @required this.locale,
    @required this.userAgent,
  })  : assert(baseUrl != null),
        assert(theme != null),
        assert(locale != null),
        assert(userAgent != null);

  SettingsState.empty()
      : baseUrl = 'ngabbs.com',
        theme = AppTheme.white,
        locale = AppLocale.en,
        userAgent = UserAgent.osOnly;

  SettingsState copy({
    String baseUrl,
    AppTheme theme,
    AppLocale locale,
    UserAgent userAgent,
  }) =>
      SettingsState(
        baseUrl: baseUrl ?? this.baseUrl,
        theme: theme ?? this.theme,
        locale: locale ?? this.locale,
        userAgent: userAgent ?? this.userAgent,
      );
}

abstract class UserState {
  const UserState();
}

class UserUninitialized extends UserState {}

class UserLogged extends UserState {
  final int uid;
  final String cid;

  const UserLogged(this.uid, this.cid);
}

// TODO: guest login
// class Guest extends UserState {
//   final String uid;

//   Guest(this.uid);

//   bool isMe(int userId) => false;
// }

class AppState {
  final SettingsState settings;
  final UserState userState;

  final List<Category> pinned;

  final InboxState inboxState;

  final Map<int, User> users;
  final Map<int, Topic> topics;
  final Map<int, PostItem> posts;

  final Map<int, CategoryState> categoryStates;
  final Map<int, TopicState> topicStates;
  final FavoriteState favoriteState;
  final EditingState editingState;

  final Repository repository;

  AppState({
    @required this.repository,
    @required this.categoryStates,
    @required this.favoriteState,
    @required this.inboxState,
    @required this.pinned,
    @required this.posts,
    @required this.topics,
    @required this.editingState,
    @required this.settings,
    @required this.topicStates,
    @required this.users,
    @required this.userState,
  })  : assert(categoryStates != null),
        assert(repository != null),
        assert(favoriteState != null),
        assert(inboxState != null),
        assert(pinned != null),
        assert(posts != null),
        assert(editingState != null),
        assert(settings != null),
        assert(topicStates != null),
        assert(users != null),
        assert(userState != null);

  AppState copy({
    Repository repository,
    UserState userState,
    SettingsState settings,
    FavoriteState favoriteState,
    EditingState editingState,
    List<Category> pinned,
    InboxState inboxState,
    Map<int, PostItem> posts,
    Map<int, User> users,
    Map<int, Topic> topics,
    Map<int, CategoryState> categoryStates,
    Map<int, TopicState> topicStates,
  }) =>
      AppState(
        repository: repository ?? this.repository,
        userState: userState ?? this.userState,
        settings: settings ?? this.settings,
        pinned: pinned ?? this.pinned,
        inboxState: inboxState ?? this.inboxState,
        favoriteState: favoriteState ?? this.favoriteState,
        categoryStates: categoryStates ?? this.categoryStates,
        topicStates: topicStates ?? this.topicStates,
        users: users ?? this.users,
        posts: posts ?? this.posts,
        topics: topics ?? this.topics,
        editingState: editingState ?? this.editingState,
      );

  AppState.empty()
      : repository = Repository(),
        userState = UserUninitialized(),
        users = {},
        posts = {},
        topics = {},
        settings = SettingsState.empty(),
        inboxState = InboxUninitialized(),
        pinned = [],
        categoryStates = {},
        topicStates = {},
        favoriteState = FavoriteUninitialized(),
        editingState = EditingUninitialized();
}
