import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:async_redux/async_redux.dart';
import 'package:business/settings/models/settings_state.dart';
import 'package:path_provider/path_provider.dart';

import '../app_state.dart';

const _themeToString = {
  AppTheme.white: 'white',
  AppTheme.black: 'black',
  AppTheme.grey: 'grey',
  AppTheme.yellow: 'yellow',
};

const _localeToString = {
  AppLocale.en: 'en',
  AppLocale.zh: 'zh',
};

class PersistStateAction extends ReduxAction<AppState> {
  @override
  Future<AppState> reduce() async {
    Directory directory = await getApplicationDocumentsDirectory();
    File file = File('${directory.path}/state.json');

    String json = jsonEncode({
      'user': _userStateToJson(state.userState),
      'baseUrl': state.repository.baseUrl,
      'locale': _localeToString[state.settings.locale],
      'theme': _themeToString[state.settings.theme],
      'pinned': state.pinned
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

    print('SAVED ${file.path}');

    return null;
  }
}

Map<String, dynamic> _userStateToJson(UserState userState) {
  if (userState is UserLogged) {
    return {'isLogged': true, 'uid': userState.uid, 'cid': userState.cid};
  }
  // TODO: guest login
  // else if (userState is Guest) {
  //   return {'isLogged': false, 'uid': userState.uid};
  // }
  return null;
}
