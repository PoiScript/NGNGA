import 'package:async_redux/async_redux.dart';

import '../../app_state.dart';
import '../models/editing_state.dart';

abstract class EditingBaseAction extends ReduxAction<AppState> {
  EditingState get editingState => state.editingState;
}
