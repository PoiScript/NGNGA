import 'package:async_redux/async_redux.dart';
import 'package:flutter/widgets.dart';

import 'package:ngnga/store/state.dart';
import 'package:ngnga/utils/requests.dart';

class ApplyEditingAction extends ReduxAction<AppState> {
  final int action;
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
    await applyEditing(
      client: state.client,
      action: action,
      categoryId: categoryId,
      topicId: topicId,
      postId: postId,
      cookie: state.cookie,
      baseUrl: state.baseUrl,
      subject: subject,
      content: content,
    );

    return state.copy(
      setEditing: Event(Editing(
        content: "",
        subject: "",
        attachUrl: "",
      )),
    );
  }
}
