import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';

import 'package:ngnga/bbcode/render.dart';
import 'package:ngnga/localizations.dart';
import 'package:ngnga/models/post.dart';
import 'package:ngnga/models/user.dart';
import 'package:ngnga/store/actions.dart';
import 'package:ngnga/store/state.dart';
import 'package:ngnga/utils/duration.dart';
import 'package:ngnga/utils/open_link.dart';
import 'package:ngnga/widgets/user_dialog.dart';

final _everyMinutes = StreamController<DateTime>.broadcast()
  ..addStream(
    Stream.periodic(Duration(minutes: 1), (_) => DateTime.now()),
  );

class PostDialog extends StatefulWidget {
  final Map<int, User> userMap;
  final Map<int, PostItem> postMap;
  final int initialPostId;

  final Future<void> Function(int, int) fetchReply;

  PostDialog({
    @required this.userMap,
    @required this.postMap,
    @required this.initialPostId,
    @required this.fetchReply,
  })  : assert(userMap != null),
        assert(postMap != null),
        assert(initialPostId != null),
        assert(fetchReply != null);

  @override
  _PostDialogState createState() => _PostDialogState();
}

class _PostDialogState extends State<PostDialog> {
  List<int> postIds;

  @override
  void initState() {
    super.initState();
    postIds = [widget.initialPostId];
  }

  @override
  Widget build(BuildContext context) {
    List<PostItem> posts = [];
    List<User> users = [];

    for (int id in postIds.reversed) {
      PostItem postItem = widget.postMap[id];
      posts.add(postItem);
      if (postItem == null || postItem is Deleted) {
        users.add(null);
      } else {
        users.add(widget.userMap[postItem.inner.userId]);
      }
    }

    List<Widget> children = [];

    for (int i = 0; i < posts.length; i++) {
      children.add(_buildContent(posts[i], users[i]));
      children.add(Divider());
    }

    return SimpleDialog(
      contentPadding: EdgeInsets.all(16.0),
      children: children..removeLast(),
    );
  }

  Widget _buildContent(PostItem postItem, User user) {
    if (postItem == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (postItem is Deleted) {
      return Text(
        AppLocalizations.of(context).postNotFound,
        style: Theme.of(context)
            .textTheme
            .caption
            .copyWith(fontStyle: FontStyle.italic),
      );
    }

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
              StreamBuilder<DateTime>(
                initialData: DateTime.now(),
                stream: _everyMinutes.stream,
                builder: (context, snapshot) => Text(
                  duration(snapshot.data, postItem.inner.createdAt),
                  style: Theme.of(context).textTheme.caption,
                ),
              ),
            ],
          ),
        ),
        BBCodeRender(
          raw: postItem.inner.content,
          openLink: (url) => openLink(context, url),
          openUser: (userId) {
            showDialog(
              context: context,
              builder: (context) => UserDialog(userId),
            );
          },
          openPost: (int topicId, int page, int postId) async {
            if (!postIds.contains(postId)) {
              setState(() => postIds.add(postId));
              await widget.fetchReply(topicId, postId);
              setState(() {});
            }
          },
        ),
      ],
    );
  }
}

class PostDialogConnector extends StatelessWidget {
  final int topicId, postId;

  PostDialogConnector({
    @required this.topicId,
    @required this.postId,
  })  : assert(topicId != null),
        assert(postId != null);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ViewModel>(
      model: ViewModel(),
      onInit: (store) => store.dispatch(FetchReplyAction(
        topicId: topicId,
        postId: postId,
      )),
      builder: (context, vm) => PostDialog(
        userMap: vm.userMap,
        postMap: vm.postMap,
        fetchReply: vm.fetchReply,
        initialPostId: postId,
      ),
    );
  }
}

class ViewModel extends BaseModel<AppState> {
  Map<int, User> userMap;
  Map<int, PostItem> postMap;

  Future<void> Function(int, int) fetchReply;

  ViewModel();

  ViewModel.build({
    @required this.userMap,
    @required this.postMap,
    @required this.fetchReply,
  }) : super(equals: [userMap, postMap]);

  @override
  ViewModel fromStore() {
    return ViewModel.build(
      userMap: state.users,
      postMap: state.posts,
      fetchReply: (topicId, postId) => dispatchFuture(FetchReplyAction(
        topicId: topicId,
        postId: postId,
      )),
    );
  }
}
