import 'package:async_redux/async_redux.dart';
import 'package:ngnga/models/category.dart';

import 'package:ngnga/store/state.dart';

import 'state_persist.dart';

class RemoveFromPinnedAction extends ReduxAction<AppState> {
  final Category category;

  RemoveFromPinnedAction(this.category);

  @override
  Future<AppState> reduce() async {
    return state.copy(
      categorySnackBarEvt: Event("Removed"),
      pinned: state.pinned..remove(category),
    );
  }

  void after() => dispatch(SaveState());
}

class AddToPinnedAction extends ReduxAction<AppState> {
  final Category category;

  AddToPinnedAction(this.category);

  @override
  Future<AppState> reduce() async {
    return state.copy(
      categorySnackBarEvt: Event("Added"),
      pinned: state.pinned..add(category),
    );
  }

  void after() => dispatch(SaveState());
}
