import 'package:flutter/foundation.dart';

import 'package:business/editor/actions/editing_base_action.dart';

import '../../app_state.dart';

class ApplyEditingAction extends EditingBaseAction {
  final String subject;
  final String content;

  ApplyEditingAction({
    @required this.subject,
    @required this.content,
  });

  @override
  Future<AppState> reduce() async {
    assert(editingState.initialized);

    await state.repository.applyEditing(
      cookie: state.userState.cookie,
      baseUrl: state.settings.baseUrl,
      action: editingState.editorAction,
      categoryId: editingState.categoryId,
      topicId: editingState.topicId,
      postId: editingState.postId,
      subject: subject,
      content: content,
      attachmentCode: editingState.files
          .where((file) => file.uploaded)
          .map((file) => file.code)
          .join('\t'),
      attachmentChecksum: editingState.files
          .where((file) => file.uploaded)
          .map((file) => file.check)
          .join('\t'),
    );

    return null;
  }
}
