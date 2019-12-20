import '../../app_state.dart';
import 'editing_base_action.dart';

class UnselectFileAction extends EditingBaseAction {
  final int index;

  UnselectFileAction(this.index);

  @override
  AppState reduce() {
    assert(editingState.initialized);

    return state.rebuild(
      (b) => b.editingState.files.removeAt(index),
    );
  }
}
