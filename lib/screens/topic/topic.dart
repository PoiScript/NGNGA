import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter/material.dart';

import 'package:ngnga/models/post.dart';
import 'package:ngnga/models/user.dart';
import 'package:ngnga/screens/editor/editor.dart';
import 'package:ngnga/screens/topic/top_reply_sheet.dart';
import 'package:ngnga/store/actions.dart';
import 'package:ngnga/store/state.dart';
import 'package:ngnga/store/topic.dart';
import 'package:ngnga/widgets/refresh.dart';
import 'package:ngnga/widgets/title_colorize.dart';

import 'attachment_sheet.dart';
import 'comment_sheet.dart';
import 'popup_menu.dart';
import 'post_row.dart';
import 'update_indicator.dart';

class TopicPage extends StatefulWidget {
  final String baseUrl;

  final Map<int, User> users;
  final Map<int, PostItem> posts;
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

  TopicPage({
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
  })  : assert(baseUrl != null),
        assert(isMe != null),
        assert(users != null),
        assert(topicState != null),
        assert(refreshFirst != null),
        assert(loadPrevious != null),
        assert(loadNext != null),
        assert(addToFavorites != null),
        assert(removeFromFavorites != null),
        assert(changePage != null),
        assert(upvotePost != null),
        assert(downvotePost != null);

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
    TopicState topicState = widget.topicState;
    if (topicState is TopicLoaded) {
      PostVoted postVoted = topicState.postVotedEvt.consume();
      if (postVoted != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _updatePostVote(postVoted.postId, postVoted.delta);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.topicState is TopicUninitialized) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (widget.topicState is TopicLoaded) {
      return Scaffold(
        key: _scaffoldKey,
        body: Scrollbar(
          child: _buildBody(context, widget.topicState),
        ),
        floatingActionButton: _buildFab(context, widget.topicState),
      );
    }

    return null;
  }

  Widget _buildFab(BuildContext context, TopicLoaded state) {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () {
        Navigator.pushNamed(context, '/e', arguments: {
          'action': EditorAction.newPost,
          'topicId': state.topic.id,
        });
      },
    );
  }

  Widget _buildBody(BuildContext context, TopicLoaded state) {
    return EasyRefresh.builder(
      header: PreviousPageHeader(context, state.firstPage),
      footer: NextPageHeader(context),
      onRefresh: state.hasRechedMin ? widget.refreshFirst : widget.loadPrevious,
      onLoad: widget.loadNext,
      builder: (context, physics, header, footer) {
        return CustomScrollView(
          physics: physics,
          semanticChildCount: state.postIds.length,
          slivers: <Widget>[
            SliverAppBar(
              backgroundColor: Theme.of(context).cardColor,
              title: TitleColorize(
                state.topic,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                displayLabel: false,
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
                  topicId: state.topic.id,
                  isFavorited: state.isFavorited,
                  firstPage: state.firstPage,
                  maxPage: state.maxPage,
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
                  final int itemIndex = index ~/ 2;
                  if (index.isOdd) {
                    PostItem post = widget.posts[state.postIds[itemIndex]];
                    assert(post != null);
                    return PostRow(
                      post: post,
                      user: widget.users[post.inner.userId],
                      sentByMe: widget.isMe(post.inner.userId),
                      upvote: () => widget.upvotePost(post.inner.id),
                      downvote: () => widget.downvotePost(post.inner.id),
                      openAttachmentSheet: _openAttachmentSheet,
                      openCommentSheet: _openCommentSheet,
                      openTopReplySheet: _openTopReplySheet,
                    );
                  }
                  return Divider(height: 0.0);
                },
                semanticIndexCallback: (widget, index) =>
                    index.isOdd ? index ~/ 2 : null,
                childCount:
                    state.postIds.isEmpty ? 0 : (state.postIds.length * 2 + 1),
              ),
            ),
            if (state.hasRechedMax)
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

  _openAttachmentSheet(List<Attachment> attachments) {
    showModalBottomSheet(
      context: context,
      builder: (context) => AttachmentSheet(
        attachments: attachments,
      ),
    );
  }

  _openCommentSheet(List<int> commentIds) {
    showModalBottomSheet(
      context: context,
      builder: (context) => CommentSheet(
        users: widget.users,
        posts: commentIds.map((id) => widget.posts[id]).toList(),
      ),
    );
  }

  _openTopReplySheet(List<int> topReplyIds) {
    showModalBottomSheet(
      context: context,
      builder: (context) => TopReplySheet(
        users: widget.users,
        posts: topReplyIds.map((id) => widget.posts[id]).toList(),
      ),
    );
  }

  _updatePostVote(int postId, int delta) {
    widget.posts.update(postId, (item) {
      if (item is TopicPost) {
        return TopicPost(
          item.post.copy(vote: item.post.vote + delta),
          item.topReplyIds,
        );
      }

      if (item is Comment) {
        return item.addPost(item.post.copy(
          vote: item.post.vote + delta,
        ));
      }

      if (item is Post) {
        return item.copy(vote: item.vote + delta);
      }

      return item;
    });

    setState(() {});

    // TODO: display different message based on delta
    _scaffoldKey.currentState
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(delta.toString())));
  }
}

class TopicPageConnector extends StatelessWidget {
  final int topicId;
  final int pageIndex;

  TopicPageConnector({
    @required this.topicId,
    @required this.pageIndex,
  }) : assert(topicId != null && pageIndex >= 0);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ViewModel>(
      model: ViewModel(topicId),
      onInit: (store) => store.dispatch(RefreshPostsAction(
        topicId: topicId,
        pageIndex: pageIndex,
      )),
      builder: (context, vm) => TopicPage(
        isMe: vm.isMe,
        baseUrl: vm.baseUrl,
        refreshFirst: vm.refreshFirst,
        refreshLast: vm.refreshLast,
        loadPrevious: vm.loadPrevious,
        loadNext: vm.loadNext,
        topicState: vm.topicState,
        users: vm.users,
        posts: vm.posts,
        addToFavorites: vm.addToFavorites,
        removeFromFavorites: vm.removeFromFavorites,
        changePage: vm.changePage,
        upvotePost: vm.upvotePost,
        downvotePost: vm.downvotePost,
      ),
    );
  }
}

class ViewModel extends BaseModel<AppState> {
  final int topicId;

  String baseUrl;
  Map<int, User> users;
  Map<int, PostItem> posts;
  TopicState topicState;

  Function(int) isMe;

  Future<void> Function() refreshFirst;
  Future<void> Function() refreshLast;
  Future<void> Function() loadPrevious;
  Future<void> Function() loadNext;

  Future<void> Function() addToFavorites;
  Future<void> Function() removeFromFavorites;
  Future<void> Function(int) changePage;

  Future<void> Function(int) upvotePost;
  Future<void> Function(int) downvotePost;

  ViewModel(this.topicId);

  ViewModel.build({
    @required this.topicId,
    @required this.users,
    @required this.posts,
    @required this.isMe,
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
  }) : super(equals: [users, posts, topicState]);

  @override
  ViewModel fromStore() {
    return ViewModel.build(
      topicId: topicId,
      topicState: state.topicStates[topicId] ?? TopicUninitialized(),
      users: state.users,
      posts: state.posts,
      baseUrl: state.repository.baseUrl,
      refreshFirst: () =>
          dispatchFuture(RefreshPostsAction(topicId: topicId, pageIndex: 0)),
      refreshLast: () => dispatchFuture(RefreshLastPageAction(topicId)),
      loadPrevious: () => dispatchFuture(FetchPreviousPostsAction(topicId)),
      loadNext: () => dispatchFuture(FetchNextPostsAction(topicId)),
      addToFavorites: () => dispatchFuture(
        AddToFavoritesAction(topicId: topicId),
      ),
      removeFromFavorites: () => dispatchFuture(
        RemoveFromFavoritesAction(topicId: topicId),
      ),
      changePage: (page) => dispatchFuture(
        RefreshPostsAction(pageIndex: page, topicId: topicId),
      ),
      isMe: (userId) =>
          state.userState is UserLogged &&
          (state.userState as UserLogged).uid == userId,
      upvotePost: (postId) => dispatchFuture(
        UpvotePostAction(
          topicId: topicId,
          postId: postId,
        ),
      ),
      downvotePost: (postId) => dispatchFuture(
        DownvotePostAction(
          topicId: topicId,
          postId: postId,
        ),
      ),
    );
  }
}
