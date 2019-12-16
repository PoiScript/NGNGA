import 'package:async_redux/async_redux.dart';
import 'package:flutter/widgets.dart';

import 'package:ngnga/screens/editor/editor.dart';
import 'package:ngnga/store/editing.dart';
import 'package:ngnga/store/state.dart';

class PrepareEditingAction extends ReduxAction<AppState> {
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
    if (action == EditorAction.noop) {
      return state.copy(
        editingState: EditingLoaded(
          uploadAuthCode: '',
          uploadUrl: '',
          files: [],
          attachments: [],
          initialSubject: '',
          initialContent: '',
        ),
      );
    }

    final res = await state.repository.prepareEditing(
      action: action,
      categoryId: categoryId,
      topicId: topicId,
      postId: postId,
    );

    return state.copy(
      editingState: EditingLoaded(
        uploadUrl: res.uploadUrl,
        attachments: res.attachs,
        files: [],
        initialContent: res.content ?? '',
        initialSubject: res.subject ?? '',
        uploadAuthCode: res.uploadAuthCode,
      ),
    );
  }
}
