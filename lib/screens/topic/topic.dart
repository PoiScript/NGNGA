import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:built_value/built_value.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter/material.dart' hide Builder;

import 'package:ngnga/models/attachment.dart';
import 'package:ngnga/models/post.dart';
import 'package:ngnga/models/user.dart';
import 'package:ngnga/screens/editor/editor.dart';
import 'package:ngnga/screens/topic/top_reply_sheet.dart';
import 'package:ngnga/store/actions.dart';
import 'package:ngnga/store/state.dart';
import 'package:ngnga/store/topic.dart';
import 'package:ngnga/widgets/post_dialog.dart';
import 'package:ngnga/widgets/refresh.dart';
import 'package:ngnga/widgets/title_colorize.dart';

import 'attachment_sheet.dart';
import 'comment_sheet.dart';
import 'popup_menu.dart';
import 'post_row.dart';
import 'update_indicator.dart';

part 'topic.g.dart';

class TopicPage extends StatefulWidget {
  final String baseUrl;

  final Map<int, User> users;
  final Map<int, PostItem> posts;
  final TopicState topicState;

  final Function(int) isMe;

  final Future<void> Function(int) fetchReply;

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
    @required this.fetchReply,
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
    PostVoted postVoted = widget.topicState.postVotedEvt.consume();
    if (postVoted != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _updatePostVote(postVoted.postId, postVoted.delta);
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
      header: PreviousPageHeader(context, widget.topicState.firstPage),
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
                  final int itemIndex = index ~/ 2;
                  if (index.isOdd) {
                    PostItem post = widget
                        .posts[widget.topicState.postIds.elementAt(itemIndex)];
                    assert(post != null);
                    return PostRow(
                      post: post,
                      baseUrl: widget.baseUrl,
                      user: widget.users[post.inner.userId],
                      sentByMe: widget.isMe(post.inner.userId),
                      upvote: () => widget.upvotePost(post.inner.id),
                      downvote: () => widget.downvotePost(post.inner.id),
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

  _openPostDialog(int topicId, int postId) {
    showDialog(
      context: context,
      builder: (context) => PostDialog(
        topicId: topicId,
        postId: postId,
        users: widget.users,
        posts: widget.posts,
        fetchReply: widget.fetchReply,
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
      converter: (store) => ViewModel.fromStore(store, topicId),
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
        fetchReply: vm.fetchReply,
        addToFavorites: vm.addToFavorites,
        removeFromFavorites: vm.removeFromFavorites,
        changePage: vm.changePage,
        upvotePost: vm.upvotePost,
        downvotePost: vm.downvotePost,
      ),
    );
  }
}

abstract class ViewModel implements Built<ViewModel, ViewModelBuilder> {
  ViewModel._();

  factory ViewModel([Function(ViewModelBuilder) updates]) = _$ViewModel;

  TopicState get topicState;
  String get baseUrl;
  Map<int, User> get users;
  Map<int, PostItem> get posts;
  Function(int) get isMe;
  Future<void> Function(int) get fetchReply;
  Future<void> Function() get refreshFirst;
  Future<void> Function() get refreshLast;
  Future<void> Function() get loadPrevious;
  Future<void> Function() get loadNext;
  Future<void> Function() get addToFavorites;
  Future<void> Function() get removeFromFavorites;
  Future<void> Function(int) get changePage;
  Future<void> Function(int) get upvotePost;
  Future<void> Function(int) get downvotePost;

  factory ViewModel.fromStore(Store<AppState> store, int topicId) {
    return ViewModel(
      (b) => b
        ..topicState =
            store.state.topicStates[topicId]?.toBuilder() ?? TopicStateBuilder()
        ..users = store.state.users.toMap()
        ..posts = store.state.posts.toMap()
        ..baseUrl = store.state.repository.baseUrl
        ..refreshFirst = (() => store
            .dispatchFuture(RefreshPostsAction(topicId: topicId, pageIndex: 0)))
        ..refreshLast =
            (() => store.dispatchFuture(RefreshLastPageAction(topicId)))
        ..loadPrevious =
            (() => store.dispatchFuture(FetchPreviousPostsAction(topicId)))
        ..loadNext = (() => store.dispatchFuture(FetchNextPostsAction(topicId)))
        ..addToFavorites =
            (() => store.dispatchFuture(AddToFavoritesAction(topicId: topicId)))
        ..removeFromFavorites = (() =>
            store.dispatchFuture(RemoveFromFavoritesAction(topicId: topicId)))
        ..changePage = ((pageIndex) => store.dispatchFuture(
            RefreshPostsAction(topicId: topicId, pageIndex: pageIndex)))
        ..isMe = ((userId) =>
            store.state.userState is UserLogged &&
            (store.state.userState as UserLogged).uid == userId)
        ..upvotePost = ((postId) => store
            .dispatchFuture(UpvotePostAction(topicId: topicId, postId: postId)))
        ..downvotePost = ((postId) => store.dispatchFuture(
            DownvotePostAction(topicId: topicId, postId: postId)))
        ..fetchReply = ((postId) => store.dispatchFuture(
            FetchReplyAction(topicId: topicId, postId: postId))),
    );
  }
}
