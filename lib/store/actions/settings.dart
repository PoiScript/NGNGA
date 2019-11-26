import 'package:async_redux/async_redux.dart';
import 'package:ngnga/store/state.dart';

import 'state_persist.dart';

class ChangeBaseUrlAction extends ReduxAction<AppState> {
  final String baseUrl;

  ChangeBaseUrlAction(this.baseUrl);

  @override
  AppState reduce() {
    return state.copy(
      settings: state.settings.copy(
        baseUrl: baseUrl,
      ),
    );
  }

  void after() => dispatch(SaveState());
}

class ChangeCookiesAction extends ReduxAction<AppState> {
  final String uid;
  final String cid;

  ChangeCookiesAction({
    this.uid,
    this.cid,
  });

  @override
  AppState reduce() {
    return state.copy(
      settings: state.settings.copy(
        uid: uid,
        cid: cid,
      ),
    );
  }

  void after() => dispatch(SaveState());
}
