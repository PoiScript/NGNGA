import 'package:async_redux/async_redux.dart';
import 'package:built_collection/built_collection.dart';
import 'package:flutter/foundation.dart';

import '../../app_state.dart';
import '../../models/editor_action.dart';
import 'editing_base_action.dart';

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
          ..editingState.editorAction = action
          ..editingState.initialized = true
          ..editingState.uploadAuthCode = ''
          ..editingState.uploadUrl = ''
          ..editingState.contentEvt = Event('')
          ..editingState.subjectEvt = Event(''),
      );
    }

    final res = await state.repository.prepareEditing(
      cookie: state.userState.cookie,
      baseUrl: state.settings.baseUrl,
      action: action,
      categoryId: categoryId,
      topicId: topicId,
      postId: postId,
    );

    return state.rebuild(
      (b) => b
        ..editingState.editorAction = action
        ..editingState.categoryId = categoryId
        ..editingState.topicId = topicId
        ..editingState.postId = postId
        ..editingState.initialized = true
        ..editingState.uploadUrl = res.uploadUrl
        ..editingState.attachments = ListBuilder(res.attachs)
        ..editingState.contentEvt = Event(res.content ?? '')
        ..editingState.subjectEvt = Event(res.subject ?? '')
        ..editingState.uploadAuthCode = res.uploadAuthCode,
    );
  }
}
