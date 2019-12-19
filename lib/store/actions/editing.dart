import 'dart:io';

import 'package:async_redux/async_redux.dart';
import 'package:built_collection/built_collection.dart';
import 'package:flutter/widgets.dart';

import 'package:ngnga/screens/editor/editor.dart';
import 'package:ngnga/store/state.dart';
import 'package:ngnga/store/editing.dart';

abstract class EditingBaseAction extends ReduxAction<AppState> {
  EditingState get editingState => state.editingState;
}

class PrepareEditingAction extends EditingBaseAction {
  final EditorAction action;
  final int categoryId;
  final int topicId;
  final int postId;

  PrepareEditingAction({
    @required this.action,
    @required this.categoryId,
    @required this.topicId,
    @required this.postId,
  });

  @override
  Future<AppState> reduce() async {
    assert(!editingState.initialized);

    if (action == EditorAction.noop) {
      return state.rebuild(
        (b) => b
          ..editingState.initialized = true
          ..editingState.uploadAuthCode = ''
          ..editingState.uploadUrl = ''
          ..editingState.contentEvt = Event('')
          ..editingState.subjectEvt = Event(''),
      );
    }

    final res = await state.repository.prepareEditing(
      action: action,
      categoryId: categoryId,
      topicId: topicId,
      postId: postId,
    );

    return state.rebuild(
      (b) => b
        ..editingState.initialized = true
        ..editingState.uploadUrl = res.uploadUrl
        ..editingState.attachments = ListBuilder(res.attachs)
        ..editingState.contentEvt = Event(res.content ?? '')
        ..editingState.subjectEvt = Event(res.subject ?? '')
        ..editingState.uploadAuthCode = res.uploadAuthCode,
    );
  }
}

class ApplyEditingAction extends EditingBaseAction {
  final EditorAction action;
  final int categoryId;
  final int topicId;
  final int postId;
  final String subject;
  final String content;

  ApplyEditingAction({
    @required this.action,
    @required this.categoryId,
    @required this.topicId,
    @required this.postId,
    @required this.subject,
    @required this.content,
  });

  @override
  Future<AppState> reduce() async {
    assert(editingState.initialized);

    await state.repository.applyEditing(
      action: action,
      categoryId: categoryId,
      topicId: topicId,
      postId: postId,
      subject: subject,
      content: content,
      attachmentCode: editingState.files
          .where((file) => file.code?.isNotEmpty ?? false)
          .join('\t'),
      attachmentChecksum: editingState.files
          .where((file) => file.code?.isNotEmpty ?? false)
          .join('\t'),
    );

    return null;
  }
}

class ClearEditingAction extends EditingBaseAction {
  @override
  AppState reduce() {
    return state.rebuild((b) => b.editingState = EditingStateBuilder());
  }
}

class UploadFileAction extends EditingBaseAction {
  final int categoryId;
  final int index;

  UploadFileAction(this.categoryId, this.index);

  @override
  Future<AppState> reduce() async {
    assert(editingState.initialized);
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

class SetFileUploadingAction extends EditingBaseAction {
  final int index;

  SetFileUploadingAction(this.index);

  @override
  AppState reduce() {
    assert(editingState.initialized);
    assert(!editingState.files[index].uploaded);

    return state.rebuild((b) => b.editingState.files[index] =
        b.editingState.files[index].rebuild((b) => b.isUploading = true));
  }
}

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
