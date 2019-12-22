import 'package:async_redux/async_redux.dart';
import 'package:flutter/widgets.dart';

import '../../app_state.dart';

class DownvotePostAction extends ReduxAction<AppState> {
  final int topicId;
  final int postId;

  DownvotePostAction({
    @required this.topicId,
    @required this.postId,
  });

  @override
  Future<AppState> reduce() async {
    final res = await state.repository.votePost(
      cookie: state.userState.cookie,
      baseUrl: state.settings.baseUrl,
      value: -1,
      topicId: topicId,
      postId: postId,
    );

    return state.rebuild(
      (b) => b
        ..posts.updateValue(
          postId,
          (post) => post.rebuild((b) => b.vote += res.value),
        )
        ..topicStates.updateValue(
          topicId,
          (topicState) => topicState.rebuild(
            (b) => b.snackBarEvt = Event(res.message),
          ),
        ),
    );
  }
}
