import 'package:async_redux/async_redux.dart';
import 'package:ngnga/models/category.dart';

import 'package:ngnga/store/state.dart';

import 'state_persist.dart';

class RemoveFromPinnedAction extends ReduxAction<AppState> {
  final int categoryId;

  RemoveFromPinnedAction(this.categoryId);

  @override
  Future<AppState> reduce() async {
    return state.copy(
      categorySnackBarEvt: Event("Removed"),
      pinned: state.pinned..remove(categoryId),
    );
  }

  void after() => dispatch(SaveState());
}

class AddToPinnedAction extends ReduxAction<AppState> {
  final int categoryId;

  AddToPinnedAction(this.categoryId);

  @override
  Future<AppState> reduce() async {
    return state.copy(
      categorySnackBarEvt: Event("Added"),
      pinned: state.pinned..add(categoryId),
    );
  }

  void after() => dispatch(SaveState());
}
