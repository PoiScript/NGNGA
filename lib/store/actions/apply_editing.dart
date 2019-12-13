import 'package:async_redux/async_redux.dart';
import 'package:flutter/widgets.dart';

import 'package:ngnga/screens/editor/editor.dart';
import 'package:ngnga/store/state.dart';
import 'package:ngnga/utils/requests.dart';

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
    String attachmentChecksum = state.editingState.attachs
        .map((attach) => attach is UploadedAttachment ? attach.checksum : null)
        .where((i) => i != null)
        .join('\t');

    String attachmentCode = state.editingState.attachs
        .map((attach) => attach is UploadedAttachment ? attach.code : null)
        .where((i) => i != null)
        .join('\t');

    await applyEditing(
      client: state.client,
      action: action,
      categoryId: categoryId,
      topicId: topicId,
      postId: postId,
      baseUrl: state.settings.baseUrl,
      subject: subject,
      content: content,
      attachmentCode: attachmentCode,
      attachmentChecksum: attachmentChecksum,
    );

    return null;
  }

  void after() => dispatch(ClearEditingAction());
}
