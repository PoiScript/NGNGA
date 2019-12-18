import 'package:async_redux/async_redux.dart';
import 'package:built_collection/built_collection.dart';
import 'package:flutter/widgets.dart';

import 'package:ngnga/screens/editor/editor.dart';
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
