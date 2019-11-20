import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ngnga/models/post.dart';
import 'package:ngnga/models/topic.dart';
import 'package:ngnga/models/user.dart';
import 'package:ngnga/screens/editor/editor.dart';
import 'package:ngnga/store/actions.dart';
import 'package:ngnga/store/state.dart';
import 'package:ngnga/widgets/title_colorize.dart';

import 'post_row.dart';

final dateFormatter = DateFormat("HH:mm:ss");

class TopicPage extends StatefulWidget {
  final List<Post> posts;
  final Topic topic;
  final Map<int, User> users;
  final Event<String> snackBarEvt;

  final DateTime lastUpdated;
  final bool isLoading;
  final bool isFavorited;

  final Future<void> Function() addToFavorites;
  final Future<void> Function() removeFromFavorites;

  final Future<void> Function() onLoad;
  final Future<void> Function() onRefresh;

  final Future<void> Function() startListening;
  final Future<void> Function() cancelListening;

  final Future<void> Function({
    int topicId,
    int postId,
    int postIndex,
  }) upvotePost;

  final Future<void> Function({
    int topicId,
    int postId,
    int postIndex,
  }) downvotePost;

  TopicPage({
    @required this.topic,
    @required this.posts,
    @required this.users,
    @required this.lastUpdated,
    @required this.snackBarEvt,
    @required this.isLoading,
    @required this.onRefresh,
    @required this.onLoad,
    @required this.isFavorited,
    @required this.addToFavorites,
    @required this.removeFromFavorites,
    @required this.upvotePost,
    @required this.downvotePost,
    @required this.startListening,
    @required this.cancelListening,
  })  : assert(topic != null),
        assert(posts != null),
        assert(users != null),
        assert(lastUpdated != null),
        assert(snackBarEvt != null),
        assert(isLoading != null),
        assert(onRefresh != null),
        assert(onLoad != null),
        assert(addToFavorites != null),
        assert(removeFromFavorites != null),
        assert(upvotePost != null),
        assert(downvotePost != null),
        assert(startListening != null),
        assert(cancelListening != null);

  @override
  _TopicPageState createState() => _TopicPageState();
}

class _TopicPageState extends State<TopicPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    widget.startListening();
  }

  @override
  void dispose() {
    super.dispose();
    widget.cancelListening();
  }

  @override
  void didUpdateWidget(TopicPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _consumeEvents();
  }

  _consumeEvents() {
    String message = widget.snackBarEvt.consume();
    if (message != null)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 3),
          ));
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading && widget.posts.isEmpty) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      key: _scaffoldKey,
      body: Scrollbar(
        child: EasyRefresh.builder(
          header: ClassicalHeader(),
          footer: ClassicalFooter(),
          onRefresh: widget.onRefresh,
          onLoad: widget.onLoad,
          builder: _buildContent,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, "/e", arguments: {
            "action": ACTION_REPLY,
            "topicId": widget.topic.id,
          });
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ScrollPhysics physics,
    Widget header,
    Widget footer,
  ) {
    List<Widget> slivers = [
      SliverAppBar(
        backgroundColor: Colors.white,
        title: TitleColorize(
          widget.topic,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          displayLabel: false,
        ),
        floating: true,
        titleSpacing: 0.0,
        leading: const BackButton(color: Colors.black),
        actions: <Widget>[
          PopupMenuButton<Choice>(
            icon: const Icon(
              Icons.more_vert,
              color: Colors.black,
            ),
            itemBuilder: (context) => [
              widget.isFavorited
                  ? PopupMenuItem<Choice>(
                      value: Choice.RemoveFromFavorites,
                      child: Text(
                        "Remove from Favorites",
                        style: Theme.of(context).textTheme.body1,
                      ),
                    )
                  : PopupMenuItem<Choice>(
                      value: Choice.AddToFavorites,
                      child: Text(
                        "Add to Favorites",
                        style: Theme.of(context).textTheme.body1,
                      ),
                    ),
            ],
            onSelected: (choice) {
              switch (choice) {
                case Choice.RemoveFromFavorites:
                  widget.removeFromFavorites();
                  break;
                case Choice.AddToFavorites:
                  widget.addToFavorites();
                  break;
                default:
                  break;
              }
            },
          ),
        ],
      ),
      header,
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final int itemIndex = index ~/ 2;
            if (index.isOdd) {
              final Post post = widget.posts[itemIndex];
              return PostRow(
                post: post,
                user: widget.users[post.userId],
                topicId: widget.topic.id,
                upvote: () => widget.upvotePost(
                  topicId: widget.topic.id,
                  postId: post.id,
                  postIndex: itemIndex,
                ),
                downvote: () => widget.downvotePost(
                  topicId: widget.topic.id,
                  postId: post.id,
                  postIndex: itemIndex,
                ),
              );
            }
            return Divider(height: 0.0);
          },
          semanticIndexCallback: (widget, index) {
            if (index.isOdd) {
              return index ~/ 2;
            }
            return null;
          },
          childCount:
              widget.posts.length > 0 ? (widget.posts.length * 2 + 1) : 0,
        ),
      ),
      widget.posts.last.index ~/ 20 < widget.topic.postsCount ~/ 20
          ? footer
          : SliverToBoxAdapter(
              child: Container(
                height: 64 + kFloatingActionButtonMargin * 2 - 8,
                padding: EdgeInsets.all(8.0),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.replay,
                        color: Theme.of(context).textTheme.caption.color,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Auto-update enabled.",
                          style: Theme.of(context).textTheme.caption,
                        ),
                        Text(
                          "Last Updated: ${dateFormatter.format(widget.lastUpdated)}",
                          style: Theme.of(context).textTheme.caption,
                        ),
                        Text(
                          "Update Interval: 20s",
                          style: Theme.of(context).textTheme.caption,
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
    ];

    return CustomScrollView(
      physics: physics,
      semanticChildCount: widget.posts.length,
      slivers: slivers,
    );
  }
}

class TopicPageConnector extends StatelessWidget {
  final int topicId;
  final int pageIndex;

  TopicPageConnector({
    @required this.topicId,
    @required this.pageIndex,
  }) : assert(topicId != null && pageIndex != null && pageIndex >= 0);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ViewModel>(
      model: ViewModel(topicId),
      onInit: (store) => store.dispatch(FetchPostsAction(topicId, pageIndex)),
      builder: (context, vm) => TopicPage(
        posts: vm.posts,
        topic: vm.topic,
        users: vm.users,
        lastUpdated: vm.lastUpdated,
        snackBarEvt: vm.snackBarEvt,
        isLoading: vm.isLoading,
        onRefresh: vm.onRefresh,
        onLoad: vm.onLoad,
        upvotePost: vm.upvotePost,
        downvotePost: vm.downvotePost,
        isFavorited: vm.isFavorited,
        addToFavorites: vm.addToFavorites,
        removeFromFavorites: vm.removeFromFavorites,
        startListening: vm.startListening,
        cancelListening: vm.cancelListening,
      ),
    );
  }
}

enum Choice {
  AddToFavorites,
  RemoveFromFavorites,
  CopyLinkToClipboard,
  JumpToPage,
}

class ViewModel extends BaseModel<AppState> {
  final topicId;

  Topic topic;
  List<Post> posts;
  Map<int, User> users;
  DateTime lastUpdated;

  Event<String> snackBarEvt;

  bool isFavorited;
  Future<void> Function() addToFavorites;
  Future<void> Function() removeFromFavorites;

  Future<void> Function() onRefresh;
  Future<void> Function() onLoad;

  Future<void> Function() startListening;
  Future<void> Function() cancelListening;

  Future<void> Function({
    int topicId,
    int postId,
    int postIndex,
  }) upvotePost;

  Future<void> Function({
    int topicId,
    int postId,
    int postIndex,
  }) downvotePost;

  bool isLoading;

  ViewModel(this.topicId);

  ViewModel.build({
    @required this.topicId,
    @required this.topic,
    @required this.posts,
    @required this.users,
    @required this.lastUpdated,
    @required this.snackBarEvt,
    @required this.isLoading,
    @required this.onRefresh,
    @required this.onLoad,
    @required this.isFavorited,
    @required this.addToFavorites,
    @required this.removeFromFavorites,
    @required this.upvotePost,
    @required this.downvotePost,
    @required this.startListening,
    @required this.cancelListening,
  }) : super(equals: [
          isLoading,
          lastUpdated,
          snackBarEvt,
          isFavorited,
          posts,
          topic,
          users,
        ]);

  @override
  ViewModel fromStore() {
    final topic = state.topics[topicId];

    return ViewModel.build(
      topicId: topicId,
      posts: topic.posts,
      topic: topic.topic,
      users: state.users,
      snackBarEvt: state.snackBarEvt,
      isLoading: state.isLoading,
      lastUpdated: state.lastUpdated,
      onRefresh: () => dispatchFuture(FetchPreviousPostsAction(topicId)),
      onLoad: () => dispatchFuture(FetchNextPostsAction(topicId)),
      isFavorited:
          state.favorites.favorites.indexWhere((f) => f.topic.id == topicId) !=
              -1,
      addToFavorites: () => dispatchFuture(
        AddToFavoritesAction(topicId: topicId),
      ),
      removeFromFavorites: () => dispatchFuture(
        RemoveFromFavoritesAction(topicId: topicId),
      ),
      upvotePost: ({topicId, postId, postIndex}) => dispatchFuture(
        UpvotePostAction(
          topicId: topicId,
          postId: postId,
          postIndex: postIndex,
        ),
      ),
      downvotePost: ({topicId, postId, postIndex}) => dispatchFuture(
        DownvotePostAction(
          topicId: topicId,
          postId: postId,
          postIndex: postIndex,
        ),
      ),
      startListening: () => dispatchFuture(
        StartListeningNewReplyAction(topicId),
      ),
      cancelListening: () => dispatchFuture(
        CancelListeningNewReplyAction(),
      ),
    );
  }
}
