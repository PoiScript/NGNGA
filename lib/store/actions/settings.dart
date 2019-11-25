import 'package:async_redux/async_redux.dart';
import 'package:ngnga/store/state.dart';

import 'state_persist.dart';

class ChangeDomainAction extends ReduxAction<AppState> {
  final NgaDomain domain;

  ChangeDomainAction(this.domain);

  @override
  AppState reduce() {
    return state.copy(
      settings: state.settings.copy(
        domain: domain,
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
