import 'package:async_redux/async_redux.dart';

import './state.dart';

class IsLoadingAction extends ReduxAction<AppState> {
  IsLoadingAction(this.val);

  final bool val;

  @override
  AppState reduce() => state.copy(isLoading: val);
}
