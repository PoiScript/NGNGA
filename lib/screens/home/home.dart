import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter/material.dart';

import 'package:ngnga/models/category.dart';
import 'package:ngnga/models/topic.dart';
import 'package:ngnga/store/actions.dart';
import 'package:ngnga/store/state.dart';
import 'package:ngnga/widgets/category_row.dart';
import 'package:ngnga/widgets/topic_row.dart';

import 'header.dart';
import 'popup_menu.dart';

const kExpandedHeight = 150.0;

class HomePage extends StatelessWidget {
  final List<Category> categories;
  final List<Topic> topics;
  final bool isLoading;

  final Future<void> Function() onRefresh;

  HomePage({
    @required this.categories,
    @required this.topics,
    @required this.isLoading,
    @required this.onRefresh,
  })  : assert(categories != null),
        assert(isLoading != null),
        assert(topics != null),
        assert(onRefresh != null);

  @override
  Widget build(BuildContext context) {
    if (isLoading && categories.isEmpty) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "NGNGA",
          style: Theme.of(context).textTheme.body2,
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.explore, color: Colors.black),
            onPressed: () {
              Navigator.pushNamed(context, "explore");
            },
          ),
          PopupMenu(),
        ],
        backgroundColor: Colors.white,
      ),
      body: EasyRefresh.builder(
        header: ClassicalHeader(),
        onRefresh: onRefresh,
        builder: (context, physics, header, footer) => CustomScrollView(
          physics: physics,
          slivers: <Widget>[
            SliverPersistentHeader(
              pinned: true,
              delegate: SliverHeaderDelegate('Favorite Topic'),
            ),
            header,
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final int itemIndex = index ~/ 2;
                  if (index.isEven) {
                    return TopicRowConnector(
                      topics[itemIndex],
                    );
                  }
                  return Divider(height: 0);
                },
                semanticIndexCallback: (widget, index) {
                  if (index.isEven) {
                    return index ~/ 2;
                  }
                  return null;
                },
                childCount: topics.length > 0 ? (topics.length * 2 - 1) : 0,
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: SliverHeaderDelegate('Saved Category'),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => CategoryRowConnector(
                  category: categories[index],
                ),
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
      ),
    );
  }
}

class ViewModel extends BaseModel<AppState> {
  List<Category> categories;
  List<Topic> topics;
  bool isLoading;

  Future<void> Function() onRefresh;

  ViewModel();

  ViewModel.build({
    @required this.categories,
    @required this.topics,
    @required this.isLoading,
    @required this.onRefresh,
  }) : super(equals: [categories, topics, isLoading]);

  @override
  ViewModel fromStore() {
    return ViewModel.build(
      categories: state.savedCategories,
      topics: state.favorTopics,
      isLoading: state.isLoading,
      onRefresh: () => dispatchFuture(FetchFavorTopicsAction()),
    );
  }
}
