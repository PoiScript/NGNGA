import 'dart:async';

import 'package:async_redux/async_redux.dart';

import 'package:ngnga/store/state.dart';
import 'package:ngnga/utils/requests.dart';

class UploadAttachmentAction extends ReduxAction<AppState> {
  final LocalAttachment attach;
  final int categoryId;

  UploadAttachmentAction(this.attach, this.categoryId);

  @override
  Future<AppState> reduce() async {
    final res = await uploadFile(
      originDomain: state.settings.baseUrl,
      client: state.client,
      file: attach.file,
      uploadUrl: state.editingState.uploadUrl,
      auth: state.editingState.uploadAuthCode,
      categoryId: categoryId,
    );

    int index = state.editingState.attachs.indexWhere((i) => i == attach);

    return state.copy(
      editingState: state.editingState.copy(
        attachs: [
          ...state.editingState.attachs.getRange(0, index),
          UploadedAttachment(
            checksum: res.attachChecksum,
            code: res.attachCode,
            url: res.attachUrl,
            file: attach.file,
          ),
          ...state.editingState.attachs
              .getRange(index + 1, state.editingState.attachs.length)
        ],
      ),
    );
  }
}

class AddAttachmentAction extends ReduxAction<AppState> {
  final LocalAttachment attach;

  AddAttachmentAction(this.attach);

  @override
  Future<AppState> reduce() async {
    return state.copy(
      editingState: state.editingState.copy(
        attachs: List.of(state.editingState.attachs)..add(attach),
      ),
    );
  }
}

class RemoveAttachmentAction extends ReduxAction<AppState> {
  final LocalAttachment attach;

  RemoveAttachmentAction(this.attach);

  @override
  AppState reduce() {
    return state.copy(
      editingState: state.editingState.copy(
        attachs: List.of(state.editingState.attachs)..remove(attach),
      ),
    );
  }
}
