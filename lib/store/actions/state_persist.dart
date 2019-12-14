import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:async_redux/async_redux.dart';
import 'package:ngnga/models/category.dart';
import 'package:path_provider/path_provider.dart';

import 'package:ngnga/store/state.dart';

const _stringToTheme = {
  'black': AppTheme.black,
  'white': AppTheme.white,
  'yellow': AppTheme.yellow,
  'grey': AppTheme.grey,
};

const _themeToString = {
  AppTheme.white: 'white',
  AppTheme.black: 'black',
  AppTheme.grey: 'grey',
  AppTheme.yellow: 'yellow',
};

const _stringToLocale = {
  'en': AppLocale.en,
  'zh': AppLocale.zh,
};

const _localeToString = {
  AppLocale.en: 'en',
  AppLocale.zh: 'zh',
};

class SaveState extends ReduxAction<AppState> {
  @override
  Future<AppState> reduce() async {
    Directory directory = await getApplicationDocumentsDirectory();
    File file = File('${directory.path}/state.json');

    String json = jsonEncode({
      'user': _userStateToJson(state.userState),
      'baseUrl': state.settings.baseUrl,
      'locale': _localeToString[state.settings.locale],
      'theme': _themeToString[state.settings.theme],
      'pinned': state.pinned
          .map((id) => state.categories[id])
          .map(
            (category) => {
              'id': category.id,
              'title': category.title,
              'isSubcategory': category.isSubcategory,
            },
          )
          .toList(),
    });

    await file.writeAsString(json);

    print('Saved state to ${file.path}');

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

      print('Loaded state from ${file.path}');

      Iterable<Category> categories = List.of(json['pinned']).map(
        (json) => Category(
          id: json['id'],
          title: json['title'],
          isSubcategory: json['isSubcategory'],
        ),
      );

      UserState userState;

      if (json['user'] == null) {
        userState = Unlogged();
      } else if (json['user']['isLogged']) {
        userState = Logged(
          json['user']['uid'],
          json['user']['cid'],
        );
      } else {
        userState = Guest(
          json['user']['uid'],
        );
      }

      return state.copy(
        userState: userState,
        repository: state.repository
          ..updateCookie(userState)
          ..baseUrl = json['baseUrl'],
        settings: state.settings.copy(
          baseUrl: json['baseUrl'],
          theme: _stringToTheme[json['theme']],
          locale: _stringToLocale[json['locale']],
        ),
        pinned: state.pinned..addAll(categories.map((category) => category.id)),
        categories: state.categories
          ..addEntries(
            categories.map((category) => MapEntry(category.id, category)),
          ),
      );
    } on Exception catch (e) {
      print(e);
      // this file is corrupted or something, just delete it
      await file.delete();
      return null;
    }
  }
}

Map<String, dynamic> _userStateToJson(UserState userState) {
  if (userState is Logged) {
    return {'isLogged': true, 'uid': userState.uid, 'cid': userState.cid};
  } else if (userState is Guest) {
    return {'isLogged': false, 'uid': userState.uid};
  }
  return null;
}
