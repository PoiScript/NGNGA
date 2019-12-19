import 'package:async_redux/async_redux.dart';

import 'package:ngnga/models/category.dart';
import 'package:ngnga/store/state.dart';

import 'state_persist.dart';

class AddToPinnedAction extends ReduxAction<AppState> {
  final Category category;

  AddToPinnedAction(this.category);

  @override
  AppState reduce() {
    return state.rebuild(
      (b) => b
        ..pinned.add(category)
        ..categoryStates.updateValue(
          category.id,
          (categoryState) => categoryState.rebuild((b) => b.isPinned = true),
        ),
    );
  }

  void after() => dispatch(SaveState());
}

class RemoveFromPinnedAction extends ReduxAction<AppState> {
  final Category category;

  RemoveFromPinnedAction(this.category);

  @override
  AppState reduce() {
    return state.rebuild(
      (b) => b
        ..pinned.remove(category)
        ..categoryStates.updateValue(
          category.id,
          (categoryState) => categoryState.rebuild((b) => b.isPinned = false),
        ),
    );
  }

  void after() => dispatch(SaveState());
}
