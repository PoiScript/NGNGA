import 'package:async_redux/async_redux.dart';
import 'package:flutter/widgets.dart';

import 'package:ngnga/screens/editor/editor.dart';
import 'package:ngnga/store/state.dart';
import 'package:ngnga/utils/requests.dart';

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
        editingState: EditingState.empty().copy(perpared: true),
      );
    }

    final response = await prepareEditing(
      client: state.client,
      action: action,
      categoryId: categoryId,
      topicId: topicId,
      postId: postId,
      cookie: state.userState.cookie,
      baseUrl: state.settings.baseUrl,
    );

    return state.copy(
      editingState: EditingState(
        perpared: true,
        uploadUrl: response.uploadUrl,
        attachs: response.attachs,
        setContentEvt: Event(response.content),
        setSubjectEvt: Event(response.subject),
        uploadAuthCode: response.uploadAuthCode,
      ),
    );
  }
}
