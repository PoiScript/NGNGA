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
import 'package:ngnga/widgets/user_dialog.dart';

import 'link_dialog.dart';

class PostDialog extends StatefulWidget {
  final Map<int, User> users;

  final Event<Option<Post>> fetchReplyEvt;
  final Function(int, int) fetchReply;

  PostDialog({
    @required this.users,
    @required this.fetchReply,
    @required this.fetchReplyEvt,
  })  : assert(users != null),
        assert(fetchReply != null),
        assert(fetchReplyEvt != null);

  @override
  _PostDialogState createState() => _PostDialogState();
}

class _PostDialogState extends State<PostDialog> {
  final List<Post> posts = [];

  bool isLoading = true;

  @override
  void didUpdateWidget(PostDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    _consumeEvents();
  }

  _consumeEvents() {
    Option option = widget.fetchReplyEvt.consume();
    if (option != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            posts.add(option.item);
            isLoading = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    if (isLoading) {
      children.add(Center(child: CircularProgressIndicator()));
      children.add(Divider());
    }

    for (var post in posts.reversed) {
      children.add(_buildContent(post));
      children.add(Divider());
    }

    if (children.isNotEmpty) {
      children.removeLast();
    }

    return SimpleDialog(
      contentPadding: EdgeInsets.all(16.0),
      children: children,
    );
  }

  Widget _buildContent(Post post) {
    if (post == null) {
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
                  widget.users[post.userId]?.username ?? '#ANONYMOUS#',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.caption,
                ),
              ),
              StreamBuilder<DateTime>(
                stream: Stream.periodic(const Duration(minutes: 1)),
                builder: (context, snapshot) => Text(
                  duration(DateTime.now(), post.createdAt),
                  style: Theme.of(context).textTheme.caption,
                ),
              ),
            ],
          ),
        ),
        BBCodeRender(
          raw: post.content,
          openLink: (url) {
            showDialog(
              context: context,
              builder: (context) => LinkDialog(url),
            );
          },
          openUser: (userId) {
            showDialog(
              context: context,
              builder: (context) => UserDialog(userId),
            );
          },
          openPost: (int topicId, int page, int postId) {
            if (!isLoading && posts.where((p) => p.id == postId).isEmpty) {
              widget.fetchReply(topicId, postId);
              setState(() => isLoading = true);
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
        users: vm.users,
        fetchReply: vm.fetchReply,
        fetchReplyEvt: vm.fetchReplyEvt,
      ),
    );
  }
}

class ViewModel extends BaseModel<AppState> {
  Map<int, User> users;

  Function(int, int) fetchReply;
  Event<Option<Post>> fetchReplyEvt;

  ViewModel();

  ViewModel.build({
    @required this.users,
    @required this.fetchReply,
    @required this.fetchReplyEvt,
  }) : super(equals: [users, fetchReplyEvt]);

  @override
  ViewModel fromStore() {
    return ViewModel.build(
      users: state.users,
      fetchReply: (topicId, postId) => dispatch(FetchReplyAction(
        topicId: topicId,
        postId: postId,
      )),
      fetchReplyEvt: state.fetchReplyEvt,
    );
  }
}
