import 'dart:async';

import 'package:async_redux/async_redux.dart';

import 'package:ngnga/store/state.dart';
import 'package:ngnga/store/editing.dart';

class UploadAttachmentAction extends ReduxAction<AppState> {
  final LocalAttachment attach;
  final int categoryId;

  UploadAttachmentAction(this.attach, this.categoryId);

  @override
  Future<AppState> reduce() async {
    EditingState editingState = state.editingState;

    if (editingState is EditingLoaded) {
      final res = await state.repository.uploadFile(
        file: attach.file,
        uploadUrl: editingState.uploadUrl,
        auth: editingState.uploadAuthCode,
        categoryId: categoryId,
      );

      int index = editingState.attachs.indexWhere((i) => i == attach);

      return state.copy(
        editingState: editingState.copy(
          attachs: [
            ...editingState.attachs.getRange(0, index),
            UploadedAttachment(
              checksum: res.attachChecksum,
              code: res.attachCode,
              url: res.attachUrl,
              file: attach.file,
            ),
            ...editingState.attachs
                .getRange(index + 1, editingState.attachs.length)
          ],
        ),
      );
    }

    return null;
  }
}

class AddAttachmentAction extends ReduxAction<AppState> {
  final LocalAttachment attach;

  AddAttachmentAction(this.attach);

  @override
  Future<AppState> reduce() async {
    EditingState editingState = state.editingState;

    if (editingState is EditingLoaded) {
      return state.copy(
        editingState: editingState.copy(
          attachs: List.of(editingState.attachs)..add(attach),
        ),
      );
    }

    return null;
  }
}

class RemoveAttachmentAction extends ReduxAction<AppState> {
  final LocalAttachment attach;

  RemoveAttachmentAction(this.attach);

  @override
  AppState reduce() {
    EditingState editingState = state.editingState;

    if (editingState is EditingLoaded) {
      return state.copy(
        editingState: editingState.copy(
          attachs: List.of(editingState.attachs)..remove(attach),
        ),
      );
    }

    return null;
  }
}
