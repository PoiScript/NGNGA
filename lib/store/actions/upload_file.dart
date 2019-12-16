import 'dart:async';
import 'dart:io';

import 'package:async_redux/async_redux.dart';

import 'package:ngnga/store/state.dart';
import 'package:ngnga/store/editing.dart';

class UploadFileAction extends ReduxAction<AppState> {
  final int categoryId;
  final int index;

  UploadFileAction(this.categoryId, this.index);

  @override
  Future<AppState> reduce() async {
    EditingState editingState = state.editingState;

    if (editingState is EditingLoaded) {
      assert(editingState.files[index] is FileUploading);

      final res = await state.repository.uploadFile(
        file: editingState.files[index].file,
        uploadUrl: editingState.uploadUrl,
        auth: editingState.uploadAuthCode,
        categoryId: categoryId,
      );

      return state.copy(
        editingState: editingState.copy(
          files: editingState.files
            ..[index] = FileUploaded(
              check: res.attachChecksum,
              code: res.attachCode,
              url: res.attachUrl,
              file: editingState.files[index].file,
            ),
        ),
      );
    }

    return null;
  }

  void before() => dispatch(SetFileUploadingAction(index));
}

class SetFileUploadingAction extends ReduxAction<AppState> {
  final int index;

  SetFileUploadingAction(this.index);

  @override
  AppState reduce() {
    EditingState editingState = state.editingState;

    if (editingState is EditingLoaded) {
      assert(editingState.files[index] is FileSelected);

      return state.copy(
        editingState: editingState.copy(
          files: editingState.files
            ..[index] = FileUploading(editingState.files[index].file),
        ),
      );
    }

    return null;
  }
}

class SelectFileAction extends ReduxAction<AppState> {
  final File file;

  SelectFileAction(this.file);

  @override
  AppState reduce() {
    EditingState editingState = state.editingState;

    if (editingState is EditingLoaded) {
      return state.copy(
        editingState: editingState.copy(
          files: editingState.files..add(FileSelected(file)),
        ),
      );
    }

    return null;
  }
}

class UnselectFileAction extends ReduxAction<AppState> {
  final int index;

  UnselectFileAction(this.index);

  @override
  AppState reduce() {
    EditingState editingState = state.editingState;

    if (editingState is EditingLoaded) {
      assert(editingState.files[index] is FileSelected);

      return state.copy(
        editingState: editingState.copy(
          files: editingState.files..removeAt(index),
        ),
      );
    }

    return null;
  }
}