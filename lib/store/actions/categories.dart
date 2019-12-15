import 'package:async_redux/async_redux.dart';

import 'package:ngnga/models/category.dart';
import 'package:ngnga/store/category.dart';
import 'package:ngnga/store/state.dart';

import 'state_persist.dart';

class AddToPinnedAction extends ReduxAction<AppState> {
  final Category category;

  AddToPinnedAction(this.category);

  @override
  AppState reduce() {
    return state.copy(
      pinned: state.pinned..add(category),
      categoryStates: state.categoryStates
        ..update(
          category.id,
          (categoryState) => categoryState is CategoryLoaded
              ? categoryState.copyWith(isPinned: true)
              : categoryState,
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
    return state.copy(
      pinned: state.pinned..removeWhere((c) => c.id == category.id),
      categoryStates: state.categoryStates
        ..update(
          category.id,
          (categoryState) => categoryState is CategoryLoaded
              ? categoryState.copyWith(isPinned: false)
              : categoryState,
        ),
    );
  }

  void after() => dispatch(SaveState());
}
