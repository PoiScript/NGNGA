import 'dart:convert';
import 'dart:io';

import 'package:async_redux/async_redux.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:path_provider/path_provider.dart';

import 'package:ngnga/models/category.dart';
import 'package:ngnga/store/state.dart';

class JsonPersistor implements Persistor<AppState> {
  final File _file;

  JsonPersistor._(this._file);

  Duration get throttle => Duration(seconds: 10);

  static Future<JsonPersistor> init() async {
    final directory = await getApplicationDocumentsDirectory();
    return JsonPersistor._(File('${directory.path}/state.json'));
  }

  Future<void> saveInitialState(AppState state) async {
    if (await _file.exists())
      throw PersistException("Store is already persisted.");
    else
      return persistDifference(lastPersistedState: null, newState: state);
  }

  Future<void> persistDifference({
    AppState lastPersistedState,
    AppState newState,
  }) async {
    assert(newState != null);

    if (lastPersistedState == null ||
        !listEquals(
          lastPersistedState.savedCategories,
          newState.savedCategories,
        ) ||
        !listEquals(lastPersistedState.cookies, newState.cookies)) {
      String json = jsonEncode({
        "cookies": newState.cookies,
        "saved_cateogries":
            newState.savedCategories.map((c) => c.toJson()).toList(),
      });

      await _file.writeAsString(json);
    }
  }

  Future<AppState> readState() async {
    if (await _file.exists()) {
      try {
        String contents = await _file.readAsString();
        final json = jsonDecode(contents);
        return AppState.empty().copy(
          cookies: List<String>.from(json["cookies"]),
          savedCategories: List.from(json["saved_cateogries"])
              .map((x) => Category.fromJson(x))
              .toList(),
        );
      } catch (e) {
        print(e);
        // this file is corrupted or something, just delete it
        await _file.delete();
        return null;
      }
    } else {
      return null;
    }
  }

  Future<void> deleteState() async {
    if (await _file.exists()) {
      await _file.delete();
    }
  }
}
