import 'package:async_redux/async_redux.dart';

import '../../app_state.dart';
import '../../state_persistor/persist_state_action.dart';
import '../models/settings_state.dart';

class ChangeThemeAction extends ReduxAction<AppState> {
  final AppTheme theme;

  ChangeThemeAction(this.theme);

  @override
  AppState reduce() {
    return state.rebuild((b) => b.settings.theme = theme);
  }

  void after() => dispatch(PersistStateAction());
}
