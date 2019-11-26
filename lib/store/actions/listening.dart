import 'dart:async';

import 'package:async_redux/async_redux.dart';

import 'package:ngnga/store/state.dart';

import 'fetch_posts.dart';

StreamSubscription _streamSub;
int _subscribedId;

class StartListeningNewReplyAction extends ReduxAction<AppState> {
  final int topicId;

  StartListeningNewReplyAction(this.topicId);

  @override
  Future<AppState> reduce() async {
    if (_subscribedId != topicId) {
      if (_streamSub != null) await _streamSub.cancel();

      print("Start listening");

      _streamSub = Stream.periodic(const Duration(seconds: 20))
          .listen((_) => dispatch(_NewReplyAction(topicId)));

      _subscribedId = topicId;
    }
    return null;
  }
}

class _NewReplyAction extends ReduxAction<AppState> {
  final int topicId;

  _NewReplyAction(this.topicId);

  @override
  Future<AppState> reduce() async {
    final lastPage = state.topicStates[topicId].lastPage;
    final maxPage = state.topicStates[topicId].maxPage;

    if (lastPage == maxPage) {
      await dispatchFuture(FetchNextPostsAction(topicId));
    }

    return null;
  }
}

class CancelListeningNewReplyAction extends ReduxAction<AppState> {
  @override
  Future<AppState> reduce() async {
    _subscribedId = null;
    if (_streamSub != null) {
      await _streamSub.cancel();
      _streamSub = null;
    }

    print("Cancel listening");

    return null;
  }
}
