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

class TopicPage extends StatelessWidget {
  final List<Post> posts;
  final Topic topic;
  final Map<int, User> users;
  final bool isLoading;

  final bool isFavorited;
  final Future<void> Function() addToFavorites;
  final Future<void> Function() removeFromFavorites;

  final Future<void> Function() onLoad;
  final Future<void> Function() onRefresh;

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

  final StreamController<DateTime> everyMinutes;

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
        everyMinutes = StreamController.broadcast()
          ..addStream(
            Stream.periodic(const Duration(minutes: 1), (x) => DateTime.now()),
          );

  @override
  Widget build(BuildContext context) {
    if (isLoading && posts.isEmpty) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Scrollbar(
        child: EasyRefresh.builder(
          header: ClassicalHeader(),
          footer: ClassicalFooter(),
          onRefresh: onRefresh,
          onLoad: onLoad,
          enableControlFinishLoad: true,
          builder: _buildContent,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, "/e", arguments: {
            "action": ACTION_REPLY,
            "topicId": topic.id,
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
          topic,
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
              isFavorited
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
                  removeFromFavorites().then((_) {
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text("成功移出收藏"),
                      duration: Duration(seconds: 3),
                    ));
                  });
                  break;
                case Choice.AddToFavorites:
                  addToFavorites().then((_) {
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
              final Post post = posts[itemIndex];
              return PostRow(
                post: post,
                user: users[post.userId],
                topicId: topic.id,
                everyMinutes: everyMinutes.stream,
                upvote: () => upvotePost(
                  topicId: topic.id,
                  postId: post.id,
                  postIndex: itemIndex,
                ),
                downvote: () => downvotePost(
                  topicId: topic.id,
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
          childCount: posts.length > 0 ? (posts.length * 2 + 1) : 0,
        ),
      ),
      if (posts.last.index ~/ 20 < topic.postsCount ~/ 20) footer
    ];

    return CustomScrollView(
      physics: physics,
      semanticChildCount: posts.length,
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
      isFavorited: state.favorTopics.indexWhere((t) => t.id == topicId) != -1,
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
    );
  }
}
