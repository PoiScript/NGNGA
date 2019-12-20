import 'package:built_value/built_value.dart';
import 'package:built_collection/built_collection.dart';

import 'category/models/category_state.dart';
import 'editor/models/editing_state.dart';
import 'favorites/models/favorite_state.dart';
import 'inbox/models/inbox_state.dart';
import 'models/category.dart';
import 'models/post.dart';
import 'models/user.dart';
import 'repository/repository.dart';
import 'settings/models/settings_state.dart';
import 'topic/models/topic_state.dart';

part 'app_state.g.dart';

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
  BuiltMap<int, Post> get posts;

  BuiltMap<int, CategoryState> get categoryStates;
  BuiltMap<int, TopicState> get topicStates;
  FavoriteState get favoriteState;
  EditingState get editingState;

  Repository get repository;

  static void _initializeBuilder(AppStateBuilder b) =>
      b.userState = UserUninitialized();
}
