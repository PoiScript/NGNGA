import 'package:async_redux/async_redux.dart';
import 'package:flutter/widgets.dart';

import 'package:ngnga/store/state.dart';
import 'package:ngnga/utils/requests.dart';

class PrepareEditingAction extends ReduxAction<AppState> {
  final int action;
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
    final response = await prepareEditing(
      client: state.client,
      action: action,
      categoryId: categoryId,
      topicId: topicId,
      postId: postId,
      cookie: state.cookie,
      baseUrl: state.baseUrl,
    );

    return state.copy(
      setEditing: Event(Editing(
        content: response.content,
        subject: response.subject,
        attachUrl: response.attachUrl,
      )),
    );
  }
}
