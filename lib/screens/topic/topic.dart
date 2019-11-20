import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter/material.dart';

import 'package:ngnga/models/post.dart';
import 'package:ngnga/models/topic.dart';
import 'package:ngnga/models/user.dart';
import 'package:ngnga/screens/editor/editor.dart';
import 'package:ngnga/store/actions.dart';
import 'package:ngnga/store/state.dart';
import 'package:ngnga/widgets/title_colorize.dart';

import 'post_row.dart';

class TopicPage extends StatefulWidget {
  final List<Post> posts;
  final Topic topic;
  final Map<int, User> users;
  final bool isLoading;

  final bool isFavorited;
  final Future<void> Function() addToFavorites;
  final Future<void> Function() removeFromFavorites;

  final Future<void> Function() onLoad;
  final Future<void> Function() onRefresh;

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
    @required this.isLoading,
    @required this.onRefresh,
    @required this.onLoad,
    @required this.isFavorited,
    @required this.addToFavorites,
    @required this.removeFromFavorites,
    @required this.upvotePost,
    @required this.downvotePost,
    @required this.cancelListening,
  })  : assert(topic != null),
        assert(posts != null),
        assert(users != null),
        assert(isLoading != null),
        assert(onRefresh != null),
        assert(onLoad != null),
        assert(addToFavorites != null),
        assert(removeFromFavorites != null),
        assert(upvotePost != null),
        assert(downvotePost != null),
        assert(cancelListening != null);

  @override
  _TopicPageState createState() => _TopicPageState();
}

class _TopicPageState extends State<TopicPage> {
  @override
  void dispose() {
    super.dispose();
    widget.cancelListening();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading && widget.posts.isEmpty) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Scrollbar(
        child: EasyRefresh.builder(
          header: ClassicalHeader(),
          footer: ClassicalFooter(),
          onRefresh: widget.onRefresh,
          onLoad: widget.onLoad,
          enableControlFinishLoad: true,
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
                  widget.removeFromFavorites().then((_) {
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text("成功移出收藏"),
                      duration: Duration(seconds: 3),
                    ));
                  });
                  break;
                case Choice.AddToFavorites:
                  widget.addToFavorites().then((_) {
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text("成功加入收藏"),
                      duration: Duration(seconds: 3),
                    ));
                  });
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
            return Divider();
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
      if (widget.posts.last.index ~/ 20 < widget.topic.postsCount ~/ 20) footer
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
      builder: (BuildContext context, ViewModel vm) => TopicPage(
        posts: vm.posts,
        topic: vm.topic,
        users: vm.users,
        isLoading: vm.isLoading,
        onRefresh: vm.onRefresh,
        onLoad: vm.onLoad,
        upvotePost: vm.upvotePost,
        downvotePost: vm.downvotePost,
        isFavorited: vm.isFavorited,
        addToFavorites: vm.addToFavorites,
        removeFromFavorites: vm.removeFromFavorites,
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

  bool isFavorited;
  Future<void> Function() addToFavorites;
  Future<void> Function() removeFromFavorites;

  Future<void> Function() onRefresh;
  Future<void> Function() onLoad;

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
    @required this.isLoading,
    @required this.onRefresh,
    @required this.onLoad,
    @required this.isFavorited,
    @required this.addToFavorites,
    @required this.removeFromFavorites,
    @required this.upvotePost,
    @required this.downvotePost,
  }) : super(equals: [isLoading, isFavorited, posts, topic, users]);
    @required this.cancelListening,

  @override
  ViewModel fromStore() {
    final topic = state.topics[topicId];

    return ViewModel.build(
      topicId: topicId,
      posts: topic.posts,
      topic: topic.topic,
      users: state.users,
      isLoading: state.isLoading,
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
      cancelListening: () => dispatchFuture(
        CancelListeningAction(),
      ),
    );
  }
}
