import 'package:async_redux/async_redux.dart';

import 'package:business/models/category.dart';
import 'package:business/state_persistor/persist_state_action.dart';

import '../../app_state.dart';

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

  void after() => dispatch(PersistStateAction());
}
