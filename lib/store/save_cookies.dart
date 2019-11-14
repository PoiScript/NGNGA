import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'state.dart';

class SaveCookiesAction extends ReduxAction<AppState> {
  final List<String> cookies;

  SaveCookiesAction(this.cookies);

  @override
  Future<AppState> reduce() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList("cookies", cookies);

    return state.copy(cookies: cookies);
  }
}
