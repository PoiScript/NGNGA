import 'dart:async';

import 'package:flutter/material.dart';

import 'package:ngnga/bbcode/render.dart';
import 'package:ngnga/localizations.dart';
import 'package:ngnga/models/post.dart';
import 'package:ngnga/models/user.dart';
import 'package:ngnga/utils/duration.dart';
import 'package:ngnga/utils/open_link.dart';
import 'package:ngnga/widgets/user_dialog.dart';

final _everyMinutes = StreamController<DateTime>.broadcast()
  ..addStream(
    Stream.periodic(Duration(minutes: 1), (_) => DateTime.now()),
  );

class PostDialog extends StatefulWidget {
  final Map<int, User> users;
  final Map<int, PostItem> posts;

  final int topicId;
  final int postId;

  final Future<void> Function(int, int) fetchReply;

  PostDialog({
    @required this.topicId,
    @required this.postId,
    @required this.users,
    @required this.posts,
    @required this.fetchReply,
  })  : assert(users != null),
        assert(posts != null),
        assert(postId != null),
        assert(fetchReply != null);

  @override
  _PostDialogState createState() => _PostDialogState();
}

class _PostDialogState extends State<PostDialog> {
  List<int> postIds = [];

  @override
  void initState() {
    super.initState();
    _fetchReply(widget.topicId, widget.postId);
  }

  @override
  Widget build(BuildContext context) {
    List<PostItem> posts = [];
    List<User> users = [];

    for (int id in postIds.reversed) {
      PostItem postItem = widget.posts[id];
      posts.add(postItem);
      if (postItem == null || postItem is Deleted) {
        users.add(null);
      } else {
        users.add(widget.users[postItem.inner.userId]);
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
          openPost: (int topicId, int page, int postId) =>
              _fetchReply(topicId, postId),
        ),
      ],
    );
  }

  _fetchReply(int topicId, int postId) async {
    if (!postIds.contains(postId)) {
      setState(() => postIds.add(postId));
      if (!widget.posts.containsKey(postId) ||
          widget.posts[postId] is Deleted) {
        await widget.fetchReply(widget.topicId, postId);
        setState(() {});
      }
    }
  }
}
