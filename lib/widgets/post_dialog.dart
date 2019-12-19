import 'package:async_redux/async_redux.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:flutter/material.dart' hide Builder;

import 'package:ngnga/bbcode/render.dart';
import 'package:ngnga/localizations.dart';
import 'package:ngnga/models/post.dart';
import 'package:ngnga/models/user.dart';
import 'package:ngnga/store/actions/topic.dart';
import 'package:ngnga/store/state.dart';
import 'package:ngnga/utils/open_link.dart';
import 'package:ngnga/widgets/distance_to_now.dart';

part 'post_dialog.g.dart';

class PostDialog extends StatefulWidget {
  final BuiltMap<int, User> users;
  final BuiltMap<int, Post> posts;

  final int initialTopicId;
  final int initialPostId;

  final Future<void> Function(int, int) fetchReply;

  const PostDialog({
    @required this.initialTopicId,
    @required this.initialPostId,
    @required this.users,
    @required this.posts,
    @required this.fetchReply,
  });

  @override
  _PostDialogState createState() => _PostDialogState();
}

class _PostDialogState extends State<PostDialog> {
  bool isLoading = false;
  List<int> postIds = [];

  @override
  void initState() {
    super.initState();
    _fetchReply(widget.initialTopicId, widget.initialPostId);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      if (isLoading) Center(child: CircularProgressIndicator()),
      for (int id in postIds.reversed)
        if (widget.posts[id] == null)
          Text(
            AppLocalizations.of(context).postNotFound,
            style: Theme.of(context)
                .textTheme
                .caption
                .copyWith(fontStyle: FontStyle.italic),
          )
        else
          _buildContent(id)
    ];

    return AlertDialog(
      contentPadding: EdgeInsets.all(16.0),
      content: ListView.separated(
        shrinkWrap: true,
        itemCount: children.length,
        itemBuilder: (context, index) => children[index],
        separatorBuilder: (context, index) => Divider(),
      ),
    );
  }

  Widget _buildContent(int postId) {
    Post post = widget.posts[postId];
    User user = widget.users[post.userId];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  user?.username ?? '#ANONYMOUS#',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.caption,
                ),
              ),
              DistanceToNow(post.createdAt),
            ],
          ),
        ),
        BBCodeRender(
          raw: post.content,
          openLink: (url) => openLink(context, url),
          openUser: (userId) {},
          openPost: (topicId, _, postId) => _fetchReply(topicId, postId),
        ),
      ],
    );
  }

  _fetchReply(int topicId, int postId) async {
    int fixedPostId = (postId == 0 ? 2 ^ 32 - topicId : postId);
    if (!isLoading && !postIds.contains(fixedPostId)) {
      if (!widget.posts.containsKey(fixedPostId)) {
        setState(() => isLoading = true);
        await widget.fetchReply(topicId, fixedPostId);
      }
      setState(() {
        isLoading = false;
        postIds.add(fixedPostId);
      });
    }
  }
}

class PostDialogConnector extends StatelessWidget {
  final int initialTopicId;
  final int initialPostId;

  const PostDialogConnector({
    @required this.initialPostId,
    @required this.initialTopicId,
  }) : assert(initialPostId != null);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ViewModel>(
      converter: (store) => ViewModel.fromStore(store),
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

abstract class ViewModel implements Built<ViewModel, ViewModelBuilder> {
  ViewModel._();

  factory ViewModel([Function(ViewModelBuilder) updates]) = _$ViewModel;

  BuiltMap<int, User> get users;
  BuiltMap<int, Post> get posts;

  Future<void> Function(int, int) get fetchReply;

  factory ViewModel.fromStore(Store<AppState> store) => ViewModel(
        (b) => b
          ..users = store.state.users.toBuilder()
          ..posts = store.state.posts.toBuilder()
          ..fetchReply = (topicId, postId) => store.dispatchFuture(
              FetchReplyAction(topicId: topicId, postId: postId)),
      );
}
