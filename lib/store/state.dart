import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'package:ngnga/models/category.dart';
import 'package:ngnga/models/post.dart';
import 'package:ngnga/models/topic.dart';
import 'package:ngnga/models/user.dart';
import 'package:ngnga/utils/categories.dart';

enum BackgroundColor {
  white,
  black,
  grey,
}

enum PrimaryColor {
  red,
}

class SettingsState {
  final String baseUrl;
  final BackgroundColor backgroundColor;
  final PrimaryColor primaryColor;
  final String uid;
  final String cid;

  SettingsState({
    @required this.uid,
    @required this.cid,
    @required this.baseUrl,
    @required this.backgroundColor,
    @required this.primaryColor,
  })  : assert(baseUrl != null),
        assert(backgroundColor != null),
        assert(primaryColor != null);

  SettingsState.empty()
      : this(
          uid: null,
          cid: null,
          baseUrl: "nga.178.com",
          backgroundColor: BackgroundColor.white,
          primaryColor: PrimaryColor.red,
        );

  SettingsState copy({
    baseUrl,
    backgroundColor,
    primaryColor,
    uid,
    cid,
  }) {
    return SettingsState(
      uid: uid ?? this.uid,
      cid: cid ?? this.cid,
      baseUrl: baseUrl ?? this.baseUrl,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      primaryColor: primaryColor ?? this.primaryColor,
    );
  }
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
  }) {
    return CategoryState(
      topicIds: topicIds ?? this.topicIds,
      topicsCount: topicsCount ?? this.topicsCount,
      lastPage: lastPage ?? this.lastPage,
      maxPage: maxPage ?? this.maxPage,
    );
  }
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
  }) {
    return TopicState(
      firstPage: firstPage ?? this.firstPage,
      lastPage: lastPage ?? this.lastPage,
      maxPage: maxPage ?? this.maxPage,
      postIds: postIds ?? this.postIds,
      postsCount: postsCount ?? this.postsCount,
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

class Option<T> {
  final T item;
  Option(this.item);
}

class AppState {
  final SettingsState settings;

  final List<int> pinned;

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
    @required this.settings,
    @required this.favoriteState,
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
    SettingsState settings,
    CategoryState favoriteState,
    List<int> pinned,
    Map<int, Post> posts,
    Map<int, User> users,
    Map<int, Topic> topics,
    Map<int, Category> categories,
    Map<int, CategoryState> categoryStates,
    Map<int, TopicState> topicStates,
    Event<Option<Post>> fetchReplyEvt,
    Event<Editing> setEditing,
    Event<String> topicSnackBarEvt,
  }) {
    return AppState._(
      settings: settings ?? this.settings,
      pinned: pinned ?? this.pinned,
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
  }

  factory AppState.empty() {
    // TODO: save category into categoryState when need

    Map<int, Category> categories = Map()
      ..addEntries(categoryGroups
          .map((group) => group.categories)
          .expand((x) => x)
          .map((category) => MapEntry(category.id, category)));

    return AppState._(
      users: Map(),
      posts: Map(),
      topics: Map(),
      categories: categories,
      settings: SettingsState.empty(),
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

  String get cookie =>
      "ngaPassportUid=${settings.uid};ngaPassportCid=${settings.cid};";
}
