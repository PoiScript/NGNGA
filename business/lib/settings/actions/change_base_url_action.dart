import 'package:async_redux/async_redux.dart';

import '../../app_state.dart';

class ChangeBaseUrlAction extends ReduxAction<AppState> {
  final String baseUrl;

  ChangeBaseUrlAction(this.baseUrl);

  @override
  AppState reduce() {
    return state.rebuild((b) => b.settings.baseUrl = baseUrl);
  }

  void after() => state.save();
}
