import 'package:async_redux/async_redux.dart';

import '../../app_state.dart';
import '../../state_persistor/persist_state_action.dart';

class ChangeBaseUrlAction extends ReduxAction<AppState> {
  final String baseUrl;

  ChangeBaseUrlAction(this.baseUrl);

  @override
  AppState reduce() {
    return state.rebuild((b) => b.repository.baseUrl = baseUrl);
  }

  void after() => dispatch(PersistStateAction());
}
