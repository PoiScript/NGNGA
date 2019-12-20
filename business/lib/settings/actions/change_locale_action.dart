import 'package:async_redux/async_redux.dart';

import '../../app_state.dart';
import '../../state_persistor/persist_state_action.dart';
import '../models/settings_state.dart';

class ChangeLocaleAction extends ReduxAction<AppState> {
  final AppLocale locale;

  ChangeLocaleAction(this.locale);

  @override
  AppState reduce() {
    return state.rebuild((b) => b.settings.locale = locale);
  }

    void after() => dispatch(PersistStateAction());
}
