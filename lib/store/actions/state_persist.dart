import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:async_redux/async_redux.dart';
import 'package:ngnga/models/category.dart';
import 'package:path_provider/path_provider.dart';

import 'package:ngnga/store/state.dart';

class SaveState extends ReduxAction<AppState> {
  @override
  Future<AppState> reduce() async {
    Directory directory = await getApplicationDocumentsDirectory();
    File file = File('${directory.path}/state.json');

    String json = jsonEncode({
      "user": state.userState.toJson(),
      "baseUrl": state.settings.baseUrl,
      "pinned": state.pinned
          .map((id) => state.categories[id])
          .map((category) => {
                "id": category.id,
                "title": category.title,
                "isSubcategory": category.isSubcategory,
              })
          .toList(),
    });

    await file.writeAsString(json);

    print("Saved state to ${file.path}");

    return null;
  }
}

class LoadState extends ReduxAction<AppState> {
  @override
  Future<AppState> reduce() async {
    Directory directory = await getApplicationDocumentsDirectory();
    File file = File('${directory.path}/state.json');

    if (!(await file.exists())) return null;

    try {
      String content = await file.readAsString();
      final json = jsonDecode(content);

      print("Loaded state from ${file.path}");

      Iterable<Category> categories = List.of(json["pinned"]).map(
        (json) => Category(
          id: json["id"],
          title: json["title"],
          isSubcategory: json["isSubcategory"],
        ),
      );

      UserState userState;

      if (json['user'] is Map && json['user']['isLogged'] is bool) {
        if (json['user']['isLogged']) {
          userState = Logged.fromJson(json['user']);
        } else {
          userState = Guest.fromJson(json['user']);
        }
      }

      return state.copy(
        userState: userState,
        settings: state.settings.copy(
          baseUrl: json["baseUrl"],
        ),
        pinned: state.pinned..addAll(categories.map((category) => category.id)),
        categories: state.categories
          ..addEntries(
            categories.map((category) => MapEntry(category.id, category)),
          ),
      );
    } catch (e) {
      print(e);
      // this file is corrupted or something, just delete it
      await file.delete();
      return null;
    }
  }
}
