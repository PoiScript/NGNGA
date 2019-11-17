import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter/material.dart';

import 'package:ngnga/models/category.dart';
import 'package:ngnga/models/topic.dart';
import 'package:ngnga/store/categories.dart';
import 'package:ngnga/store/fetch_topics.dart';
import 'package:ngnga/store/router.dart';
import 'package:ngnga/store/state.dart';

import 'topic_row.dart';

const kExpandedHeight = 150.0;

class CategoryPage extends StatelessWidget {
  final Category category;
  final List<Topic> topics;
  final int topicsCount;
  final bool isLoading;
  final bool isSaved;

  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoad;
  final void Function(Topic, int) navigateToTopic;
  final void Function(Category) navigateToCategory;
  final void Function(Category) saveCategory;
  final void Function(Category) removeCategory;

  final StreamController<DateTime> everyMinutes;

  CategoryPage({
    @required this.topics,
    @required this.isSaved,
    @required this.category,
    @required this.topicsCount,
    @required this.isLoading,
    @required this.onRefresh,
    @required this.onLoad,
    @required this.navigateToTopic,
    @required this.navigateToCategory,
    @required this.saveCategory,
    @required this.removeCategory,
  })  : assert(topics != null),
        assert(category != null),
        assert(topicsCount != null),
        assert(isLoading != null),
        assert(isSaved != null),
        assert(onRefresh != null),
        assert(onLoad != null),
        assert(navigateToTopic != null),
        assert(navigateToCategory != null),
        assert(saveCategory != null),
        assert(removeCategory != null),
        everyMinutes = StreamController.broadcast()
          ..addStream(
            Stream.periodic(const Duration(minutes: 1), (x) => DateTime.now()),
          );

  Widget build(BuildContext context) {
    if (isLoading && topics.isEmpty) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Scrollbar(
        child: EasyRefresh.builder(
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
                  isSaved
                      ? IconButton(
                          color: Colors.black,
                          icon: Icon(Icons.star),
                          onPressed: () => removeCategory(category),
                        )
                      : IconButton(
                          color: Colors.black,
                          icon: Icon(Icons.star_border),
                          onPressed: () => saveCategory(category),
                        ),
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
                      return TopicRow(
                        topic: topics[itemIndex],
                        everyMinutes: everyMinutes.stream,
                        navigateToTopic: navigateToTopic,
                        navigateToCategory: navigateToCategory,
                      );
                    }
                    return Divider(height: 0.0);
                  },
                  semanticIndexCallback: (widget, localIndex) {
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
        isSaved: vm.isSaved,
        topics: vm.topics,
        category: vm.category,
        topicsCount: vm.topicsCount,
        onRefresh: vm.onRefresh,
        onLoad: vm.onLoad,
        navigateToTopic: vm.navigateToTopic,
        navigateToCategory: vm.navigateToCategory,
        saveCategory: vm.saveCategory,
        removeCategory: vm.removeCategory,
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
  bool isSaved;

  Future<void> Function() onRefresh;
  Future<void> Function() onLoad;
  void Function(Topic, int) navigateToTopic;
  void Function(Category) navigateToCategory;
  void Function(Category) saveCategory;
  void Function(Category) removeCategory;
  Stream<DateTime> everyMinutes;

  ViewModel(this.categoryId);

  ViewModel.build({
    @required this.topics,
    @required this.isLoading,
    @required this.isSaved,
    @required this.categoryId,
    @required this.category,
    @required this.topicsCount,
    @required this.onRefresh,
    @required this.onLoad,
    @required this.navigateToTopic,
    @required this.navigateToCategory,
    @required this.saveCategory,
    @required this.removeCategory,
  }) : super(equals: [isLoading, isSaved, topics, category, topicsCount]);

  @override
  ViewModel fromStore() {
    var categoryState = state.categories[categoryId];
    return ViewModel.build(
      categoryId: categoryId,
      isLoading: state.isLoading,
      isSaved: state.savedCategories.contains(categoryState.category),
      category: categoryState.category,
      topics: categoryState.topics,
      topicsCount: categoryState.topicsCount,
      onRefresh: () => dispatchFuture(FetchTopicsAction(categoryId)),
      onLoad: () => dispatchFuture(FetchNextTopicsAction(categoryId)),
      navigateToTopic: (topic, page) =>
          dispatch(NavigateToTopicAction(topic, page)),
      navigateToCategory: (category) =>
          dispatch(NavigateToCategoryAction(category)),
      saveCategory: (category) => dispatch(AddCategoryAction(category)),
      removeCategory: (category) => dispatch(RemoveCategoryAction(category)),
    );
  }
}
