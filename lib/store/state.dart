import 'dart:io';

import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'package:ngnga/models/category.dart';
import 'package:ngnga/models/post.dart';
import 'package:ngnga/models/topic.dart';
import 'package:ngnga/models/user.dart';
import 'package:ngnga/utils/categories.dart';
import 'package:ngnga/utils/requests.dart';

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

  CategoryState.empty()
      : topicIds = [],
        topicsCount = 0,
        lastPage = 0,
        maxPage = 0;
}

abstract class AttachmentItem {}

class RemoteAttachment extends AttachmentItem {
  final String url;

  RemoteAttachment(this.url);
}

class LocalAttachment extends AttachmentItem {
  final File file;

  LocalAttachment(this.file);
}

class UploadedAttachment extends AttachmentItem {
  final String checksum;
  final String code;
  final String url;
  final File file;

  UploadedAttachment({
    this.checksum,
    this.code,
    this.url,
    this.file,
  });
}

class EditingState {
  final bool perpared;
  final String uploadAuthCode;
  final String uploadUrl;
  final List<AttachmentItem> attachs;
  final Event<String> setSubjectEvt;
  final Event<String> setContentEvt;

  EditingState({
    @required this.perpared,
    @required this.uploadAuthCode,
    @required this.uploadUrl,
    @required this.attachs,
    @required this.setSubjectEvt,
    @required this.setContentEvt,
  })  : assert(perpared != null),
        assert(uploadAuthCode != null),
        assert(uploadUrl != null),
        assert(attachs != null),
        assert(setSubjectEvt != null),
        assert(setContentEvt != null);

  EditingState copy({
    bool perpared,
    String uploadAuthCode,
    String uploadUrl,
    List<AttachmentItem> attachs,
    Event<String> setSubjectEvt,
    Event<String> setContentEvt,
  }) =>
      EditingState(
        perpared: perpared ?? this.perpared,
        uploadAuthCode: uploadAuthCode ?? this.uploadAuthCode,
        uploadUrl: uploadUrl ?? this.uploadUrl,
        attachs: attachs ?? this.attachs,
        setSubjectEvt: setSubjectEvt ?? this.setSubjectEvt,
        setContentEvt: setContentEvt ?? this.setContentEvt,
      );

  EditingState.empty()
      : perpared = false,
        uploadAuthCode = '',
        uploadUrl = '',
        attachs = [],
        setSubjectEvt = Event.spent(),
        setContentEvt = Event.spent();
}

enum AppTheme { white, black, grey, yellow }

enum AppLocale { en, zh }

class SettingsState {
  final String baseUrl;
  final AppTheme theme;
  final AppLocale locale;

  SettingsState({
    @required this.baseUrl,
    @required this.theme,
    @required this.locale,
  })  : assert(baseUrl != null),
        assert(locale != null),
        assert(theme != null);

  SettingsState.empty()
      : baseUrl = 'ngabbs.com',
        theme = AppTheme.white,
        locale = AppLocale.en;

  SettingsState copy({
    String baseUrl,
    AppTheme theme,
    AppLocale locale,
  }) =>
      SettingsState(
        baseUrl: baseUrl ?? this.baseUrl,
        theme: theme ?? this.theme,
        locale: locale ?? this.locale,
      );
}

class TopicState {
  final List<int> postIds;

  final int firstPage;
  final int lastPage;
  final int maxPage;

  TopicState({
    @required this.firstPage,
    @required this.lastPage,
    @required this.maxPage,
    @required this.postIds,
  })  : assert(postIds != null),
        assert(maxPage >= lastPage && lastPage >= firstPage && firstPage >= 0);

  TopicState copy({
    int firstPage,
    int lastPage,
    int maxPage,
    List<int> postIds,
  }) =>
      TopicState(
        firstPage: firstPage ?? this.firstPage,
        lastPage: lastPage ?? this.lastPage,
        maxPage: maxPage ?? this.maxPage,
        postIds: postIds ?? this.postIds,
      );
}

abstract class UserState {
  bool get isLogged;
  String get cookie;

  bool isMe(int userId);

  Map<String, dynamic> toJson();

  static UserState fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return Unlogged();
    } else if (json['isLogged']) {
      return Logged.fromJson(json);
    } else {
      return Guest.fromJson(json);
    }
  }
}

class Unlogged extends UserState {
  String cookie = '';
  bool get isLogged => false;

  bool isMe(int userId) => false;

  Map<String, dynamic> toJson() => null;
}

class Logged extends UserState {
  final int uid;
  final String cid;
  final bool isLogged = true;
  final String cookie;

  Logged(this.uid, this.cid)
      : cookie = 'ngaPassportUid=$uid;ngaPassportCid=$cid;';

  bool isMe(int userId) => userId == uid;

  Map<String, dynamic> toJson() => {'isLogged': true, 'uid': uid, 'cid': cid};

  Logged.fromJson(Map<String, dynamic> json) : this(json['uid'], json['cid']);
}

class Guest extends UserState {
  final String uid;
  final bool isLogged = false;

  Guest(this.uid);

  String get cookie =>
      'ngaPassportUid=$uid;guestJs=${DateTime.now().millisecondsSinceEpoch ~/ 1000};';

  bool isMe(int userId) => false;

  Map<String, dynamic> toJson() => {'isLogged': false, 'uid': uid};

  Guest.fromJson(Map<String, dynamic> json) : uid = json['uid'];
}

class AppState {
  final SettingsState settings;
  final UserState userState;

  final List<int> pinned;

  final List<UserNotification> notifications;

  final Map<int, User> users;
  final Map<int, PostItem> posts;
  final Map<int, Topic> topics;
  final Map<int, Category> categories;

  final Map<int, CategoryState> categoryStates;
  final Map<int, TopicState> topicStates;
  final CategoryState favoriteState;
  final EditingState editingState;

  final Event<String> topicSnackBarEvt;

  final Client client;

  AppState._({
    @required this.client,
    @required this.categories,
    @required this.categoryStates,
    @required this.favoriteState,
    @required this.notifications,
    @required this.pinned,
    @required this.posts,
    @required this.editingState,
    @required this.settings,
    @required this.topics,
    @required this.topicSnackBarEvt,
    @required this.topicStates,
    @required this.users,
    @required this.userState,
  })  : assert(categoryStates != null),
        assert(client != null),
        assert(favoriteState != null),
        assert(notifications != null),
        assert(pinned != null),
        assert(posts != null),
        // assert(editingState != null),
        assert(settings != null),
        assert(topics != null),
        assert(topicSnackBarEvt != null),
        assert(topicStates != null),
        assert(users != null),
        assert(userState != null);

  AppState copy({
    Client client,
    UserState userState,
    SettingsState settings,
    CategoryState favoriteState,
    EditingState editingState,
    List<int> pinned,
    List<UserNotification> notifications,
    Map<int, PostItem> posts,
    Map<int, User> users,
    Map<int, Topic> topics,
    Map<int, Category> categories,
    Map<int, CategoryState> categoryStates,
    Map<int, TopicState> topicStates,
    Event<String> topicSnackBarEvt,
  }) =>
      AppState._(
        client: client ?? this.client,
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
        editingState: editingState ?? this.editingState,
        topicSnackBarEvt: topicSnackBarEvt ?? this.topicSnackBarEvt,
      );

  factory AppState.empty() {
    // TODO: save category into categoryState when need

    Map<int, Category> categories = Map.fromEntries((categoryGroups
        .map((group) => group.categories)
        .expand((x) => x)
        .map((category) => MapEntry(category.id, category))));

    return AppState._(
      client: Client(),
      userState: Unlogged(),
      users: {},
      posts: {},
      topics: {},
      categories: categories,
      settings: SettingsState.empty(),
      notifications: [],
      pinned: [],
      categoryStates: {},
      topicStates: {},
      favoriteState: CategoryState.empty(),
      editingState: EditingState.empty(),
      topicSnackBarEvt: Event.spent(),
    );
  }
}
