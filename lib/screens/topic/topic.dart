import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';

import '../../models/topic.dart';
import '../../models/post.dart';
import './post_row.dart';

import '../../store/state.dart';
import '../../store/fetch_posts.dart';

class TopicPage extends StatelessWidget {
  final Map<int, List<Post>> pages;
  final Topic topic;

  TopicPage({this.topic, this.pages});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(topic.title)),
      body: pages.isNotEmpty
          ? ListView(
              children: pages.values
                  .expand((posts) => posts)
                  .map((post) => PostRow(post))
                  .toList(),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}

class TopicPageConnector extends StatelessWidget {
  final int topicId;

  TopicPageConnector(this.topicId);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ViewModel>(
      model: ViewModel(topicId),
      // distinct: false,
      onInit: (st) => st.dispatch(FetchPostsAction(
        topic: Topic(id: topicId),
        page: 0,
      )),
      builder: (BuildContext context, ViewModel vm) => TopicPage(
        pages: vm.pages ?? Map(),
        topic: vm.topic,
      ),
    );
  }
}

class ViewModel extends BaseModel<AppState> {
  final topicId;

  Topic topic;
  Map<int, List<Post>> pages;
  bool isLoading;

  ViewModel(this.topicId);

  ViewModel.build({
    @required this.pages,
    @required this.isLoading,
    @required this.topicId,
    @required this.topic,
  }) : super(equals: [isLoading, pages, topic]);

  @override
  ViewModel fromStore() {
    return ViewModel.build(
      pages: state.topics[topicId]?.pages,
      topic: state.topics[topicId]?.topic,
      isLoading: state.isLoading,
      topicId: topicId,
    );
  }
}
