import 'package:async_redux/async_redux.dart';
import 'package:flutter/widgets.dart';

import 'package:ngnga/screens/editor/editor.dart';
import 'package:ngnga/store/state.dart';
import 'package:ngnga/store/editing.dart';

import 'clear_editing.dart';

class ApplyEditingAction extends ReduxAction<AppState> {
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
    EditingState editingState = state.editingState;

    await state.repository.applyEditing(
      action: action,
      categoryId: categoryId,
      topicId: topicId,
      postId: postId,
      subject: subject,
      content: content,
      attachmentCode: editingState.files
          .map((file) => file is FileUploaded ? file.code : '')
          .where((code) => code.isNotEmpty)
          .join('\t'),
      attachmentChecksum: editingState.files
          .map((file) => file is FileUploaded ? file.check : '')
          .where((check) => check.isNotEmpty)
          .join('\t'),
    );

    return null;
  }

  void after() => dispatch(ClearEditingAction());
}
