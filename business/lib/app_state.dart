import 'dart:convert';
import 'dart:io';

import 'package:built_value/built_value.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:business/serializers.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:path_provider/path_provider.dart';

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
import 'user/models/user_state.dart';

part 'app_state.g.dart';

abstract class AppState implements Built<AppState, AppStateBuilder> {
  static Serializer<AppState> get serializer => _$appStateSerializer;

  AppState._();

  factory AppState([Function(AppStateBuilder) updates]) = _$AppState;

  SettingsState get settings;
  UserState get userState;
  BuiltList<Category> get pinned;
  @BuiltValueField(serialize: false)
  InboxState get inboxState;
  @BuiltValueField(serialize: false)
  BuiltMap<int, User> get users;
  @BuiltValueField(serialize: false)
  BuiltMap<int, Post> get posts;
  @BuiltValueField(serialize: false)
  BuiltMap<int, CategoryState> get categoryStates;
  @BuiltValueField(serialize: false)
  BuiltMap<int, TopicState> get topicStates;
  @BuiltValueField(serialize: false)
  FavoriteState get favoriteState;
  @BuiltValueField(serialize: false)
  EditingState get editingState;
  @BuiltValueField(serialize: false)
  Repository get repository;

  static void _initializeBuilder(AppStateBuilder b) =>
      b.repository = Repository();

  static Future<File> getPersistFile() async {
    Directory directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/state.json');
  }

  static Future<AppState> load() async {
    File file = await getPersistFile();

    if (!(await file.exists())) return AppState();

    try {
      String content = await file.readAsString();

      if (kDebugMode) print('LOADED ${file.path}');

      AppState state = serializers.deserialize(
        json.decode(content),
        specifiedType: const FullType(AppState),
      );

      return state;
    } on Exception catch (e) {
      print(e);
      // this file is corrupted or something, just delete it
      await file.delete();
      return AppState();
    }
  }

  Future<void> save() async {
    File file = await getPersistFile();

    String json = jsonEncode(serializers.serialize(this));

    await file.writeAsString(json);

    if (kDebugMode) print('SAVED ${file.path}');
  }
}
