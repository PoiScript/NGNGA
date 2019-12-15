import 'package:async_redux/async_redux.dart';

import 'package:ngnga/store/editing.dart';
import 'package:ngnga/store/state.dart';

class ClearEditingAction extends ReduxAction<AppState> {
  @override
  AppState reduce() {
    return state.copy(editingState: EditingUninitialized());
  }
}
