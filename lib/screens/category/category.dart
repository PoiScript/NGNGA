import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

import '../../models/topic.dart';
import '../../models/category.dart';
import '../../store/state.dart';
import '../../store/fetch_topics.dart';
import '../../store/ensure_exists.dart';

import 'topic_row.dart';

const kExpandedHeight = 200.0;

class CategoryPage extends StatelessWidget {
  final Category category;
  final List<Topic> topics;
  final int topicsCount;
  final bool isLoading;

  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoad;
  final void Function(Topic) ensureTopicExists;

  CategoryPage({
    @required this.topics,
    @required this.category,
    @required this.topicsCount,
    @required this.isLoading,
    @required this.onRefresh,
    @required this.onLoad,
    @required this.ensureTopicExists,
  })  : assert(topics != null),
        assert(category != null),
        assert(topicsCount != null),
        assert(isLoading != null),
        assert(onRefresh != null),
        assert(onLoad != null),
        assert(ensureTopicExists != null);

  Widget build(BuildContext context) {
    if (isLoading && topics.isEmpty) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: EasyRefresh.custom(
        header: ClassicalHeader(bgColor: Theme.of(context).backgroundColor),
        footer: ClassicalFooter(),
        onRefresh: onRefresh,
        onLoad: onLoad,
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
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final int itemIndex = index ~/ 2;
                if (index.isEven) {
                  final topic = topics[itemIndex];
                  return TopicRow(topic);
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
        ],
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
        ensureTopicExists: vm.ensureTopicExists,
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
  void Function(Topic) ensureTopicExists;

  ViewModel(this.categoryId);

  ViewModel.build({
    @required this.topics,
    @required this.isLoading,
    @required this.categoryId,
    @required this.category,
    @required this.topicsCount,
    @required this.onRefresh,
    @required this.onLoad,
    @required this.ensureTopicExists,
  }) : super(equals: [isLoading, topics, category, topicsCount]);

  @override
  ViewModel fromStore() {
    var category = state.categories[categoryId];
    return ViewModel.build(
      categoryId: categoryId,
      isLoading: state.isLoading,
      category: category?.category,
      topics: category?.topics,
      topicsCount: category?.topicsCount,
      onRefresh: () => dispatchFuture(FetchTopicsAction(categoryId)),
      onLoad: () => dispatchFuture(FetchNextTopicsAction(categoryId)),
      ensureTopicExists: (topic) => dispatch(EnsureTopicExistsAction(topic)),
    );
  }
}
