import 'dart:io';

import '../../app_state.dart';
import '../models/upload_file.dart';
import 'editing_base_action.dart';

class SelectFileAction extends EditingBaseAction {
  final File file;

  SelectFileAction(this.file);

  @override
  AppState reduce() {
    assert(editingState.initialized);

    return state.rebuild(
      (b) => b.editingState.files.add(UploadFile((b) => b.file = file)),
    );
  }
}
