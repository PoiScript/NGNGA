import 'dart:collection';

import 'package:async_redux/async_redux.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../models/topic.dart';
import '../../models/post.dart';
import '../../store/state.dart';
import '../../store/fetch_posts.dart';

import 'post_row.dart';

class TopicPage extends StatelessWidget {
  final ListQueue<Post> posts;
  final Topic topic;
  final Map<int, User> users;
  final bool isLoading;

  final Future<void> Function() onLoad;
  final Future<void> Function() onRefresh;

  TopicPage({
    @required this.topic,
    @required this.posts,
    @required this.users,
    @required this.isLoading,
    @required this.onRefresh,
    @required this.onLoad,
  })  : assert(topic != null),
        assert(posts != null),
        assert(users != null),
        assert(isLoading != null),
        assert(onRefresh != null),
        assert(onLoad != null);

  @override
  Widget build(BuildContext context) {
    if (isLoading && topic == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          topic.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.subhead,
        ),
        titleSpacing: 0.0,
        leading: const BackButton(color: Colors.black),
        actions: <Widget>[
          IconButton(
            color: Colors.black,
            icon: Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: EasyRefresh.custom(
        header: ClassicalHeader(),
        footer: ClassicalFooter(),
        onRefresh: onRefresh,
        onLoad: (posts.last.index ~/ 20) == (topic.postsCount ~/ 20)
            ? null
            : onLoad,
        semanticChildCount: posts.length,
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final int itemIndex = index ~/ 2;
                if (index.isEven) {
                  final post = posts.elementAt(itemIndex);
                  return PostRow(post, users[post.userId]);
                }
                return Divider(height: 0, color: Colors.grey);
              },
              semanticIndexCallback: (widget, localIndex) =>
                  localIndex.isEven ? localIndex ~/ 2 : null,
              childCount: posts.length * 2,
            ),
          ),
        ],
      ),
    );
  }
}

class TopicPageConnector extends StatelessWidget {
  final int topicId;
  final int pageIndex;

  TopicPageConnector(this.topicId, this.pageIndex)
      : assert(topicId != null && pageIndex != null && pageIndex >= 0);

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
      ),
    );
  }
}

class ViewModel extends BaseModel<AppState> {
  final topicId;

  Topic topic;
  ListQueue<Post> posts;
  Map<int, User> users;

  Future<void> Function() onRefresh;
  Future<void> Function() onLoad;

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
  }) : super(equals: [isLoading, posts, topic, users]);

  @override
  ViewModel fromStore() {
    var topic = state.topics[topicId];
    return ViewModel.build(
      topicId: topicId,
      posts: topic?.posts,
      topic: topic?.topic,
      users: state.users,
      isLoading: state.isLoading,
      onRefresh: () => dispatchFuture(FetchPreviousPostsAction(topicId)),
      onLoad: () => dispatchFuture(FetchNextPostsAction(topicId)),
    );
  }
}
