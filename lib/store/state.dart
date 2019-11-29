import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart' hide Notification;
import 'package:http/http.dart';

import 'package:ngnga/models/category.dart';
import 'package:ngnga/models/post.dart';
import 'package:ngnga/models/topic.dart';
import 'package:ngnga/models/user.dart';
import 'package:ngnga/utils/categories.dart';
import 'package:ngnga/utils/requests.dart';

abstract class UserState {
  bool isLogged;
  String get cookie;

  bool isMe(int userId);

  Map<String, dynamic> toJson();
}

class Logged extends UserState {
  final int uid;
  final String cid;

  bool isLogged = true;

  Logged(this.uid, this.cid);

  String get cookie => "ngaPassportUid=$uid;ngaPassportCid=$cid;";

  bool isMe(int userId) => userId == this.uid;

  Map<String, dynamic> toJson() => {'isLogged': true, 'uid': uid, 'cid': cid};

  Logged.fromJson(Map<String, dynamic> json)
      : cid = json['cid'],
        uid = json['uid'];
}

class Guest extends UserState {
  final String uid;

  bool isLogged = false;

  Guest(this.uid);

  String get cookie =>
      "ngaPassportUid=$uid;guestJs=${DateTime.now().millisecondsSinceEpoch ~/ 1000};";

  bool isMe(int userId) => false;

  Map<String, dynamic> toJson() => {'isLogged': false, 'uid': uid};

  Guest.fromJson(Map<String, dynamic> json) : uid = json['uid'];
}

enum AppTheme {
  white,
  black,
  grey,
  yellow,
}

class SettingsState {
  final String baseUrl;
  final AppTheme theme;

  SettingsState({
    @required this.baseUrl,
    @required this.theme,
  })  : assert(baseUrl != null),
        assert(theme != null);

  SettingsState.empty() : this(baseUrl: "nga.178.com", theme: AppTheme.white);

  SettingsState copy({String baseUrl, AppTheme theme}) => SettingsState(
        baseUrl: baseUrl ?? this.baseUrl,
        theme: theme ?? this.theme,
      );
}

class CategoryState {
  final List<int> topicIds;

  final int topicsCount;

  final int lastPage;
  final int maxPage;

  CategoryState({
    @required this.topicIds,
    @required this.topicsCount,
    @required this.lastPage,
    @required this.maxPage,
  })  : assert(topicIds != null),
        assert(topicsCount >= 0),
        assert(maxPage >= lastPage);

  CategoryState copy({
    List<int> topicIds,
    int topicsCount,
    int lastPage,
    int maxPage,
  }) =>
      CategoryState(
        topicIds: topicIds ?? this.topicIds,
        topicsCount: topicsCount ?? this.topicsCount,
        lastPage: lastPage ?? this.lastPage,
        maxPage: maxPage ?? this.maxPage,
      );
}

class TopicState {
  final List<int> postIds;
  final int postsCount;

  final int firstPage;
  final int lastPage;
  final int maxPage;

  TopicState({
    @required this.firstPage,
    @required this.lastPage,
    @required this.maxPage,
    @required this.postIds,
    @required this.postsCount,
  })  : assert(postIds != null),
        assert(maxPage >= lastPage && lastPage >= firstPage && firstPage >= 0);

  TopicState copy({
    int firstPage,
    int lastPage,
    int maxPage,
    int postsCount,
    List<int> postIds,
  }) =>
      TopicState(
        firstPage: firstPage ?? this.firstPage,
        lastPage: lastPage ?? this.lastPage,
        maxPage: maxPage ?? this.maxPage,
        postIds: postIds ?? this.postIds,
        postsCount: postsCount ?? this.postsCount,
      );
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

class Option<T> {
  final T item;
  Option(this.item);
}

class AppState {
  final SettingsState settings;
  final UserState userState;

  final List<int> pinned;

  final List<Notification> notifications;

  final Map<int, User> users;
  final Map<int, Post> posts;
  final Map<int, Topic> topics;
  final Map<int, Category> categories;

  final Map<int, CategoryState> categoryStates;
  final Map<int, TopicState> topicStates;
  final CategoryState favoriteState;

  final Event<Option<Post>> fetchReplyEvt;
  final Event<Editing> setEditingEvt;
  final Event<String> topicSnackBarEvt;

  final Client client = Client();

  AppState._({
    @required this.userState,
    @required this.settings,
    @required this.favoriteState,
    @required this.notifications,
    @required this.pinned,
    @required this.users,
    @required this.posts,
    @required this.topics,
    @required this.categories,
    @required this.topicStates,
    @required this.categoryStates,
    @required this.fetchReplyEvt,
    @required this.setEditingEvt,
    @required this.topicSnackBarEvt,
  })  : assert(categoryStates != null),
        assert(settings != null),
        assert(notifications != null),
        assert(favoriteState != null),
        assert(pinned != null),
        assert(users != null),
        assert(posts != null),
        assert(topics != null),
        assert(topicStates != null),
        assert(categoryStates != null),
        assert(fetchReplyEvt != null),
        assert(setEditingEvt != null),
        assert(topicSnackBarEvt != null);

  AppState copy({
    UserState userState,
    SettingsState settings,
    CategoryState favoriteState,
    List<int> pinned,
    List<Notification> notifications,
    Map<int, Post> posts,
    Map<int, User> users,
    Map<int, Topic> topics,
    Map<int, Category> categories,
    Map<int, CategoryState> categoryStates,
    Map<int, TopicState> topicStates,
    Event<Option<Post>> fetchReplyEvt,
    Event<Editing> setEditing,
    Event<String> topicSnackBarEvt,
  }) =>
      AppState._(
        userState: userState ?? this.userState,
        settings: settings ?? this.settings,
        pinned: pinned ?? this.pinned,
        notifications: notifications ?? this.notifications,
        favoriteState: favoriteState ?? this.favoriteState,
        categoryStates: categoryStates ?? this.categoryStates,
        topicStates: topicStates ?? this.topicStates,
        categories: categories ?? this.categories,
        topics: topics ?? this.topics,
        users: users ?? this.users,
        posts: posts ?? this.posts,
        fetchReplyEvt: fetchReplyEvt ?? this.fetchReplyEvt,
        setEditingEvt: setEditing ?? this.setEditingEvt,
        topicSnackBarEvt: topicSnackBarEvt ?? this.topicSnackBarEvt,
      );

  factory AppState.empty() {
    // TODO: save category into categoryState when need

    Map<int, Category> categories = Map()
      ..addEntries(categoryGroups
          .map((group) => group.categories)
          .expand((x) => x)
          .map((category) => MapEntry(category.id, category)));

    return AppState._(
      userState: null,
      users: Map(),
      posts: Map(),
      topics: Map(),
      categories: categories,
      settings: SettingsState.empty(),
      notifications: List(),
      pinned: List(),
      categoryStates: Map(),
      topicStates: Map(),
      favoriteState: CategoryState(
        lastPage: 0,
        topicsCount: 0,
        maxPage: 0,
        topicIds: const [],
      ),
      fetchReplyEvt: Event.spent(),
      setEditingEvt: Event.spent(),
      topicSnackBarEvt: Event.spent(),
    );
  }
}
