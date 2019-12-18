import 'package:built_value/built_value.dart';
import 'package:built_collection/built_collection.dart';

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

part 'state.g.dart';

enum AppTheme { white, black, grey, yellow }

enum AppLocale { en, zh }

enum UserAgent { none, osOnly, full }

abstract class SettingsState
    implements Built<SettingsState, SettingsStateBuilder> {
  SettingsState._();

  factory SettingsState([Function(SettingsStateBuilder) updates]) =
      _$SettingsState;

  AppTheme get theme;
  AppLocale get locale;
  UserAgent get userAgent;

  static void _initializeBuilder(SettingsStateBuilder b) => b
    ..theme = AppTheme.white
    ..locale = AppLocale.en
    ..userAgent = UserAgent.osOnly;
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

abstract class AppState implements Built<AppState, AppStateBuilder> {
  AppState._();

  factory AppState([Function(AppStateBuilder) updates]) = _$AppState;

  SettingsState get settings;
  UserState get userState;

  BuiltList<Category> get pinned;

  InboxState get inboxState;

  BuiltMap<int, User> get users;
  BuiltMap<int, Topic> get topics;
  BuiltMap<int, PostItem> get posts;

  BuiltMap<int, CategoryState> get categoryStates;
  BuiltMap<int, TopicState> get topicStates;
  FavoriteState get favoriteState;
  EditingState get editingState;

  Repository get repository;

  static void _initializeBuilder(AppStateBuilder b) =>
      b.userState = UserUninitialized();
}
