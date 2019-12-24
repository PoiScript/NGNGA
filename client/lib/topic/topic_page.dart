import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter/material.dart' hide Builder;

import 'package:business/models/attachment.dart';
import 'package:business/models/editor_action.dart';
import 'package:business/models/post.dart';
import 'package:business/models/user.dart';
import 'package:business/topic/models/topic_state.dart';
import 'package:ngnga/widgets/post_dialog_connector.dart';
import 'package:ngnga/widgets/refresh.dart';
import 'package:ngnga/widgets/title_colorize.dart';

import 'attachment_sheet.dart';
import 'comment_sheet.dart';
import 'popup_menu.dart';
import 'post_row.dart';
import 'top_reply_sheet.dart';
import 'update_indicator.dart';

class TopicPage extends StatefulWidget {
  final String baseUrl;

  final BuiltMap<int, User> users;
  final BuiltMap<int, Post> posts;
  final TopicState topicState;

  final Function(int) isMe;

  final Future<void> Function() refreshFirst;
  final Future<void> Function() refreshLast;
  final Future<void> Function() loadPrevious;
  final Future<void> Function() loadNext;

  final Future<void> Function() addToFavorites;
  final Future<void> Function() removeFromFavorites;
  final Future<void> Function(int) changePage;

  final Future<void> Function(int) upvotePost;
  final Future<void> Function(int) downvotePost;

  const TopicPage({
    @required this.isMe,
    @required this.users,
    @required this.posts,
    @required this.baseUrl,
    @required this.topicState,
    @required this.refreshFirst,
    @required this.refreshLast,
    @required this.loadPrevious,
    @required this.loadNext,
    @required this.addToFavorites,
    @required this.removeFromFavorites,
    @required this.changePage,
    @required this.upvotePost,
    @required this.downvotePost,
  });

  @override
  _TopicPageState createState() => _TopicPageState();
}

class _TopicPageState extends State<TopicPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void didUpdateWidget(TopicPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _consumeEvents();
  }

  _consumeEvents() {
    String message = widget.topicState.snackBarEvt.consume();
    if (message != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _scaffoldKey.currentState
            ..removeCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.topicState.initialized) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      key: _scaffoldKey,
      body: Scrollbar(child: _buildBody(context)),
      floatingActionButton: _buildFab(context),
    );
  }

  Widget _buildFab(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () {
        Navigator.pushNamed(context, '/e', arguments: {
          'action': EditorAction.newPost,
          'categoryId': widget.topicState.topic.categoryId,
          'topicId': widget.topicState.topic.id,
        });
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    return EasyRefresh.builder(
      header: widget.topicState.hasRechedMin
          ? RefreshHeader(context)
          : PreviousPageHeader(context, widget.topicState.firstPage),
      footer: NextPageHeader(context),
      onRefresh: widget.topicState.hasRechedMin
          ? widget.refreshFirst
          : widget.loadPrevious,
      onLoad: widget.loadNext,
      builder: (context, physics, header, footer) {
        return CustomScrollView(
          physics: physics,
          semanticChildCount: widget.topicState.postIds.length,
          slivers: <Widget>[
            SliverAppBar(
              backgroundColor: Theme.of(context).cardColor,
              title: TitleColorize(
                widget.topicState.topic,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              floating: true,
              titleSpacing: 0.0,
              leading: BackButton(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
              actions: <Widget>[
                PopupMenu(
                  topicId: widget.topicState.topic.id,
                  isFavorited: widget.topicState.isFavorited,
                  firstPage: widget.topicState.firstPage,
                  maxPage: widget.topicState.maxPage,
                  baseUrl: widget.baseUrl,
                  addToFavorites: widget.addToFavorites,
                  removeFromFavorites: widget.removeFromFavorites,
                  changePage: widget.changePage,
                ),
              ],
            ),
            header,
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  int itemIndex = index ~/ 2;
                  if (index.isOdd) {
                    Post post = widget
                        .posts[widget.topicState.postIds.elementAt(itemIndex)];
                    return PostRow(
                      post: post,
                      baseUrl: widget.baseUrl,
                      user: widget.users[post.userId],
                      sentByMe: widget.isMe(post.userId),
                      upvote: () => widget.upvotePost(post.id),
                      downvote: () => widget.downvotePost(post.id),
                      openAttachmentSheet: _openAttachmentSheet,
                      openCommentSheet: _openCommentSheet,
                      openTopReplySheet: _openTopReplySheet,
                      openPost: _openPostDialog,
                    );
                  }
                  return Divider(height: 0.0);
                },
                semanticIndexCallback: (widget, index) =>
                    index.isOdd ? index ~/ 2 : null,
                childCount: widget.topicState.postIds.isEmpty
                    ? 0
                    : (widget.topicState.postIds.length * 2 + 1),
              ),
            ),
            if (widget.topicState.hasRechedMax)
              SliverToBoxAdapter(
                child: UpdateIndicator(
                  fetch: widget.refreshLast,
                ),
              )
            else
              footer
          ],
        );
      },
    );
  }

  _openAttachmentSheet(BuiltList<Attachment> attachments) {
    showModalBottomSheet(
      context: context,
      builder: (context) => AttachmentSheet(
        attachments: attachments,
      ),
    );
  }

  _openCommentSheet(BuiltList<int> commentIds) {
    showModalBottomSheet(
      context: context,
      builder: (context) => CommentSheet(
        users: widget.users,
        posts: commentIds.map((id) => widget.posts[id]).toList(growable: false),
      ),
    );
  }

  _openTopReplySheet(BuiltList<int> topReplyIds) {
    showModalBottomSheet(
      context: context,
      builder: (context) => TopReplySheet(
        users: widget.users,
        posts:
            topReplyIds.map((id) => widget.posts[id]).toList(growable: false),
      ),
    );
  }

  _openPostDialog(int topicId, int postId) {
    showDialog(
      context: context,
      builder: (context) => PostDialogConnector(
        initialTopicId: topicId,
        initialPostId: postId,
      ),
    );
  }
}
