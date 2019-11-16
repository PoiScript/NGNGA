import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter/material.dart';

import 'package:ngnga/models/category.dart';
import 'package:ngnga/models/topic.dart';
import 'package:ngnga/screens/category/topic_row.dart';
import 'package:ngnga/store/fetch_favor.dart';
import 'package:ngnga/store/router.dart';
import 'package:ngnga/store/state.dart';

import 'category_row.dart';
import 'header.dart';
import 'popup_menu.dart';

const kExpandedHeight = 150.0;

class HomePage extends StatelessWidget {
  final List<Category> categories;
  final List<Topic> topics;
  final bool isLoading;

  final StreamController<DateTime> everyMinutes;

  final Future<void> Function() onRefresh;
  final void Function(Category) navigateToCategory;
  final void Function(Topic, int) navigateToTopic;

  HomePage({
    @required this.categories,
    @required this.topics,
    @required this.isLoading,
    @required this.onRefresh,
    @required this.navigateToCategory,
    @required this.navigateToTopic,
  })  : assert(categories != null),
        assert(isLoading != null),
        assert(topics != null),
        assert(onRefresh != null),
        assert(navigateToCategory != null),
        assert(navigateToTopic != null),
        everyMinutes = StreamController.broadcast()
          ..addStream(
            Stream.periodic(const Duration(minutes: 1), (x) => DateTime.now()),
          );

  @override
  Widget build(BuildContext context) {
    if (isLoading && categories.isEmpty) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: EasyRefresh.builder(
        header: ClassicalHeader(),
        onRefresh: onRefresh,
        builder: (context, physics, header, footer) => CustomScrollView(
          physics: physics,
          slivers: <Widget>[
            SliverAppBar(
              expandedHeight: kExpandedHeight,
              floating: false,
              pinned: true,
              backgroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  "NGNGA",
                  style: Theme.of(context).textTheme.title,
                ),
                titlePadding: EdgeInsetsDirectional.only(bottom: 16),
              ),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(
                    Icons.settings,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, "/s");
                  },
                ),
                PopupMenu(),
              ],
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: SliverHeaderDelegate('Favorite Topic'),
            ),
            header,
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => TopicRow(
                  topic: topics[index],
                  navigateToTopic: navigateToTopic,
                  everyMinutes: everyMinutes.stream,
                  navigateToCategory: navigateToCategory,
                ),
                childCount: topics.length,
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: SliverHeaderDelegate('Saved Category'),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  var category = categories[index];
                  return InkWell(
                    onTap: () => navigateToCategory(category),
                    child: CategoryRow(category),
                  );
                },
                childCount: categories.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePageConnector extends StatelessWidget {
  HomePageConnector();

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ViewModel>(
      model: ViewModel(),
      onInit: (store) => store.dispatch(FetchFavorTopicsAction()),
      builder: (context, vm) => HomePage(
        categories: vm.categories,
        topics: vm.topics,
        isLoading: vm.isLoading,
        onRefresh: vm.onRefresh,
        navigateToCategory: vm.navigateToCategory,
        navigateToTopic: vm.navigateToTopic,
      ),
    );
  }
}

class ViewModel extends BaseModel<AppState> {
  List<Category> categories;
  List<Topic> topics;
  bool isLoading;

  Future<void> Function() onRefresh;
  void Function(Category) navigateToCategory;
  void Function(Topic, int) navigateToTopic;

  ViewModel();

  ViewModel.build({
    @required this.categories,
    @required this.topics,
    @required this.isLoading,
    @required this.onRefresh,
    @required this.navigateToCategory,
    @required this.navigateToTopic,
  }) : super(equals: [categories, topics, isLoading]);

  @override
  ViewModel fromStore() {
    return ViewModel.build(
      categories: state.savedCategories,
      topics: state.favorTopics,
      isLoading: state.isLoading,
      onRefresh: () => dispatchFuture(FetchFavorTopicsAction()),
      navigateToCategory: (category) =>
          dispatch(NavigateToCategoryAction(category)),
      navigateToTopic: (topic, page) =>
          dispatch(NavigateToTopicAction(topic, page)),
    );
  }
}
