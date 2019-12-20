import 'dart:io';

import 'package:async_redux/async_redux.dart';
import 'package:built_value/built_value.dart';
import 'package:business/editor/actions/select_file.dart';
import 'package:business/editor/actions/unselect_file.dart';
import 'package:business/editor/actions/upload_file.dart';
import 'package:flutter/widgets.dart' hide Builder;

import 'package:business/app_state.dart';
import 'package:business/editor/actions/clear_editing.dart';
import 'package:business/editor/actions/prepare_editing_action.dart';
import 'package:business/editor/models/editing_state.dart';
import 'package:business/editor/actions/apply_editing_action.dart';
import 'package:business/models/editor_action.dart';

import 'editor_page.dart';

part 'editor_page_connector.g.dart';

class EditorPageConnector extends StatelessWidget {
  final EditorAction action;
  final int categoryId;
  final int topicId;
  final int postId;

  EditorPageConnector({
    @required this.action,
    @required this.categoryId,
    @required this.topicId,
    @required this.postId,
  })  : assert(action != null),
        assert(_validateArgs(action, categoryId, topicId, postId));

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      converter: (store) => _ViewModel.fromStore(
        store,
        categoryId: categoryId,
      ),
      onInit: (store) => store.dispatch(PrepareEditingAction(
        action: action,
        categoryId: categoryId,
        topicId: topicId,
        postId: postId,
      )),
      onDispose: (store) => store.dispatch(ClearEditingAction()),
      builder: (context, vm) => EditorPage(
        editingState: vm.editingState,
        selectFile: vm.selectFile,
        unselectFile: vm.unselectFile,
        uploadFile: vm.uploadFile,
        applyEditing: vm.applyEditing,
      ),
    );
  }
}

bool _validateArgs(
    EditorAction action, int categoryId, int topicId, int postId) {
  switch (action) {
    case EditorAction.newTopic:
      return categoryId != null && topicId == null && postId == null;
    case EditorAction.newPost:
      return categoryId != null && topicId != null && postId == null;
    case EditorAction.quote:
    case EditorAction.reply:
    case EditorAction.modify:
    case EditorAction.comment:
      return categoryId != null && topicId != null && postId != null;
    case EditorAction.noop:
      return categoryId == null && topicId == null && postId == null;
  }
  return false;
}

abstract class _ViewModel implements Built<_ViewModel, _ViewModelBuilder> {
  _ViewModel._();

  factory _ViewModel([Function(_ViewModelBuilder) updates]) = _$ViewModel;

  EditingState get editingState;
  ValueChanged<File> get selectFile;
  ValueChanged<int> get unselectFile;
  Future<void> Function(int) get uploadFile;
  Future<void> Function(String, String) get applyEditing;

  factory _ViewModel.fromStore(Store<AppState> store, {int categoryId}) {
    return _ViewModel((b) => b
      ..editingState = store.state.editingState.toBuilder()
      ..applyEditing = ((subject, content) => store.dispatchFuture(
            ApplyEditingAction(subject: subject, content: content),
          ))
      ..selectFile = ((file) => store.dispatch(SelectFileAction(file)))
      ..unselectFile = ((index) => store.dispatch(UnselectFileAction(index)))
      ..uploadFile = ((index) =>
          store.dispatchFuture(UploadFileAction(categoryId, index))));
  }
}
