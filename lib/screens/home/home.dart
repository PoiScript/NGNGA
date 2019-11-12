import 'package:flutter/foundation.dart' as prefix0;
import 'package:flutter/material.dart';
import 'package:async_redux/async_redux.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

import './category_row.dart';
import './header.dart';
import './popup_menu.dart';
import '../../models/category.dart';
import '../../models/topic.dart';
import '../../store/state.dart';
import '../../store/fetch_favor.dart';
import '../../screens/category/topic_row.dart';
import '../../store/ensure_exists.dart';

const kExpandedHeight = 200.0;

class HomePage extends StatelessWidget {
  final List<Category> categories;
  final List<Topic> topics;
  final bool isLoading;
  final Future<void> Function() onRefresh;
  final void Function(Category) ensureCategoryExists;

  HomePage({
    @required this.categories,
    @required this.topics,
    @required this.isLoading,
    @required this.onRefresh,
    @required this.ensureCategoryExists,
  })  : assert(categories != null),
        assert(isLoading != null),
        assert(topics != null),
        assert(onRefresh != null),
        assert(ensureCategoryExists != null);

  @override
  Widget build(BuildContext context) {
    if (isLoading && categories.isEmpty) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: EasyRefresh.custom(
        header: ClassicalHeader(),
        onRefresh: onRefresh,
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
              PopupMenu(),
            ],
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: SliverHeaderDelegate('Favorite Topic'),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => TopicRow(topics[index]),
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
                return GestureDetector(
                  onTap: () {
                    ensureCategoryExists(category);
                    Navigator.pushNamed(context, "/c", arguments: {
                      "id": category.id,
                    });
                  },
                  child: CategoryRow(category),
                );
              },
              childCount: categories.length,
            ),
          ),
        ],
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
        ensureCategoryExists: vm.ensureCategoryExists,
      ),
    );
  }
}

class ViewModel extends BaseModel<AppState> {
  List<Category> categories;
  List<Topic> topics;
  bool isLoading;
  Future<void> Function() onRefresh;
  void Function(Category) ensureCategoryExists;

  ViewModel();

  ViewModel.build({
    @required this.categories,
    @required this.topics,
    @required this.isLoading,
    @required this.onRefresh,
    @required this.ensureCategoryExists,
  }) : super(equals: [categories, topics, isLoading]);

  @override
  ViewModel fromStore() {
    return ViewModel.build(
      categories: state.savedCategories,
      topics: state.favorTopics,
      isLoading: state.isLoading,
      onRefresh: () => dispatchFuture(FetchFavorTopicsAction()),
      ensureCategoryExists: (category) =>
          dispatch(EnsureCategoryExistsAction(category)),
    );
  }
}
