import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

import 'package:ngnga/models/category.dart';
import 'package:ngnga/store/router.dart';
import 'package:ngnga/store/state.dart';

import 'categories.dart';

class ExplorePage extends StatelessWidget {
  final void Function(Category) navigateToCategory;

  ExplorePage({@required this.navigateToCategory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        title: Text(
          "Explore",
          style: Theme.of(context).textTheme.body2,
        ),
        titleSpacing: 0.0,
        backgroundColor: Colors.white,
      ),
      body: Scrollbar(
        child: CustomScrollView(
          slivers: categoryGroups
              .map(
                (group) => SliverStickyHeader(
                  header: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    color: Colors.white,
                    child: Text(
                      group.name,
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => ListTile(
                        title: Text(group.categories[index].title),
                        onTap: () =>
                            navigateToCategory(group.categories[index]),
                        trailing: const Icon(Icons.keyboard_arrow_right),
                      ),
                      childCount: group.categories.length,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class ExplorePageConnector extends StatelessWidget {
  ExplorePageConnector();

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ViewModel>(
      model: ViewModel(),
      builder: (context, vm) => ExplorePage(
        navigateToCategory: vm.navigateToCategory,
      ),
    );
  }
}

class ViewModel extends BaseModel<AppState> {
  void Function(Category) navigateToCategory;

  ViewModel();

  ViewModel.build({
    @required this.navigateToCategory,
  });

  @override
  ViewModel fromStore() {
    return ViewModel.build(
      navigateToCategory: (category) =>
          dispatch(NavigateToCategoryAction(category)),
    );
  }
}
