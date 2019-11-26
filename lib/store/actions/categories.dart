import 'package:async_redux/async_redux.dart';

import 'package:ngnga/store/state.dart';

import 'state_persist.dart';

class RemoveFromPinnedAction extends ReduxAction<AppState> {
  final int categoryId;

  RemoveFromPinnedAction(this.categoryId);

  @override
  AppState reduce() {
    return state.copy(
      pinned: state.pinned..remove(categoryId),
    );
  }

  void after() => dispatch(SaveState());
}

class AddToPinnedAction extends ReduxAction<AppState> {
  final int categoryId;

  AddToPinnedAction(this.categoryId);

  @override
  AppState reduce() {
    return state.copy(
      pinned: state.pinned..add(categoryId),
    );
  }

  void after() => dispatch(SaveState());
}
