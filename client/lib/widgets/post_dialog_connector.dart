import 'package:async_redux/async_redux.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:flutter/widgets.dart' hide Builder;

import 'package:business/app_state.dart';
import 'package:business/topic/actions/fetch_reply_action.dart';
import 'package:business/models/post.dart';
import 'package:business/models/user.dart';

import 'post_dialog.dart';

part 'post_dialog_connector.g.dart';

class PostDialogConnector extends StatelessWidget {
  final int initialTopicId;
  final int initialPostId;

  const PostDialogConnector({
    @required this.initialPostId,
    @required this.initialTopicId,
  }) : assert(initialPostId != null);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      converter: (store) => _ViewModel.fromStore(store),
      builder: (context, vm) => PostDialog(
        initialTopicId: initialTopicId,
        initialPostId: initialPostId,
        users: vm.users,
        posts: vm.posts,
        fetchReply: vm.fetchReply,
      ),
    );
  }
}

abstract class _ViewModel implements Built<_ViewModel, _ViewModelBuilder> {
  _ViewModel._();

  factory _ViewModel([Function(_ViewModelBuilder) updates]) = _$ViewModel;

  BuiltMap<int, User> get users;
  BuiltMap<int, Post> get posts;

  Future<void> Function(int, int) get fetchReply;

  factory _ViewModel.fromStore(Store<AppState> store) => _ViewModel(
        (b) => b
          ..users = store.state.users.toBuilder()
          ..posts = store.state.posts.toBuilder()
          ..fetchReply = (topicId, postId) => store.dispatchFuture(
              FetchReplyAction(topicId: topicId, postId: postId)),
      );
}
