import '../../app_state.dart';
import '../models/editing_state.dart';

import 'editing_base_action.dart';

class ClearEditingAction extends EditingBaseAction {
  @override
  AppState reduce() {
    return state.rebuild((b) => b.editingState = EditingStateBuilder());
  }
}
