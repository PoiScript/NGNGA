import 'package:async_redux/async_redux.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter/material.dart';

import '../../models/topic.dart';
import '../../models/category.dart';
import '../../store/state.dart';
import '../../store/fetch_topics.dart';
import '../../store/router.dart';

import 'topic_row.dart';

const kExpandedHeight = 200.0;

class CategoryPage extends StatelessWidget {
  final Category category;
  final List<Topic> topics;
  final int topicsCount;
  final bool isLoading;

  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoad;
  final void Function(Topic, int) navigateToTopic;

  CategoryPage({
    @required this.topics,
    @required this.category,
    @required this.topicsCount,
    @required this.isLoading,
    @required this.onRefresh,
    @required this.onLoad,
    @required this.navigateToTopic,
  })  : assert(topics != null),
        assert(category != null),
        assert(topicsCount != null),
        assert(isLoading != null),
        assert(onRefresh != null),
        assert(onLoad != null),
        assert(navigateToTopic != null);

  Widget build(BuildContext context) {
    if (isLoading && topics.isEmpty) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: EasyRefresh.builder(
        header: ClassicalHeader(),
        footer: ClassicalFooter(),
        onRefresh: onRefresh,
        onLoad: onLoad,
        builder: (context, physics, header, footer) => CustomScrollView(
          physics: physics,
          semanticChildCount: topics.length,
          slivers: <Widget>[
            SliverAppBar(
              expandedHeight: kExpandedHeight,
              floating: false,
              pinned: true,
              leading: const BackButton(color: Colors.black),
              backgroundColor: Theme.of(context).backgroundColor,
              actions: <Widget>[
                IconButton(
                  color: Colors.black,
                  icon: Icon(Icons.more_vert),
                  onPressed: () {},
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(horizontal: 58.0),
                  height: kToolbarHeight,
                  child: Text(
                    category.title,
                    style: Theme.of(context).textTheme.subhead,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                titlePadding: EdgeInsets.all(0.0),
              ),
            ),
            header,
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final int itemIndex = index ~/ 2;
                  if (index.isEven) {
                    return TopicRow(topics[itemIndex], navigateToTopic);
                  }
                  return Divider(height: 16.0, color: Colors.grey);
                },
                semanticIndexCallback: (Widget widget, int localIndex) {
                  if (localIndex.isEven) {
                    return localIndex ~/ 2;
                  }
                  return null;
                },
                childCount: topics.length * 2,
              ),
            ),
            footer,
          ],
        ),
      ),
    );
  }
}

class CategoryPageConnector extends StatelessWidget {
  final int categoryId;

  CategoryPageConnector(this.categoryId);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ViewModel>(
      model: ViewModel(categoryId),
      onInit: (store) => store.dispatch(FetchTopicsAction(categoryId)),
      builder: (context, vm) => CategoryPage(
        isLoading: vm.isLoading,
        topics: vm.topics,
        category: vm.category,
        topicsCount: vm.topicsCount,
        onRefresh: vm.onRefresh,
        onLoad: vm.onLoad,
        navigateToTopic: vm.navigateToTopic,
      ),
    );
  }
}

class ViewModel extends BaseModel<AppState> {
  final int categoryId;
  Category category;
  List<Topic> topics;
  int topicsCount;
  bool isLoading;

  Future<void> Function() onRefresh;
  Future<void> Function() onLoad;
  void Function(Topic, int) navigateToTopic;

  ViewModel(this.categoryId);

  ViewModel.build({
    @required this.topics,
    @required this.isLoading,
    @required this.categoryId,
    @required this.category,
    @required this.topicsCount,
    @required this.onRefresh,
    @required this.onLoad,
    @required this.navigateToTopic,
  }) : super(equals: [isLoading, topics, category, topicsCount]);

  @override
  ViewModel fromStore() {
    var category = state.categories[categoryId];
    return ViewModel.build(
      categoryId: categoryId,
      isLoading: state.isLoading,
      category: category.category,
      topics: category.topics,
      topicsCount: category.topicsCount,
      onRefresh: () => dispatchFuture(FetchTopicsAction(categoryId)),
      onLoad: () => dispatchFuture(FetchNextTopicsAction(categoryId)),
      navigateToTopic: (topic, page) =>
          dispatch(NavigateToTopicAction(topic, page)),
    );
  }
}
