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

    assert(editingState.files[index].isUploading);

    final res = await state.repository.uploadFile(
      file: editingState.files[index].file,
      uploadUrl: editingState.uploadUrl,
      auth: editingState.uploadAuthCode,
      categoryId: categoryId,
    );

    return state.rebuild(
      (b) => b.editingState.files[index] =
          b.editingState.files[index].rebuild((b) => b
            ..uploaded = true
            ..isUploading = false
            ..check = res.attachChecksum
            ..code = res.attachCode
            ..url = res.attachUrl),
    );
  }

  void before() => dispatch(SetFileUploadingAction(index));
}

class SetFileUploadingAction extends ReduxAction<AppState> {
  final int index;

  SetFileUploadingAction(this.index);

  @override
  AppState reduce() {
    EditingState editingState = state.editingState;

    assert(!editingState.files[index].uploaded);

    return state.rebuild((b) => b.editingState.files[index] =
        b.editingState.files[index].rebuild((b) => b.isUploading = true));
  }
}

class SelectFileAction extends ReduxAction<AppState> {
  final File file;

  SelectFileAction(this.file);

  @override
  AppState reduce() {
    return state.rebuild(
      (b) => b.editingState.files.add(UploadFile((b) => b.file = file)),
    );
  }
}

class UnselectFileAction extends ReduxAction<AppState> {
  final int index;

  UnselectFileAction(this.index);

  @override
  AppState reduce() {
    return state.rebuild(
      (b) => b.editingState.files.removeAt(index),
    );
  }
}
