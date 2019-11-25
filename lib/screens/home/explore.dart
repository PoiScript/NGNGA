import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:ngnga/models/category.dart';

import 'package:ngnga/store/actions.dart';
import 'package:ngnga/store/state.dart';
import 'package:ngnga/utils/categories.dart';
import 'package:ngnga/widgets/category_row.dart';

class Explore extends StatelessWidget {
  final List<Category> pinned;

  Explore({
    @required this.pinned,
  }) : assert(pinned != null);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: BouncingScrollPhysics(),
      slivers: <Widget>[
        SliverToBoxAdapter(),
        SliverStickyHeader(
          header: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            color: Colors.white,
            child: Text(
              "Pinned",
              style: Theme.of(context).textTheme.caption,
            ),
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => CategoryRowConnector(
                category: pinned[index],
              ),
              childCount: pinned.length,
            ),
          ),
        ),
      ]..addAll(
          categoryGroups.map(
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
                  (context, index) => CategoryRowConnector(
                    category: group.categories[index],
                  ),
                  childCount: group.categories.length,
                ),
              ),
            ),
          ),
        ),
    );
  }
}

class ExploreConnector extends StatelessWidget {
  ExploreConnector();

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ViewModel>(
      model: ViewModel(),
      onInit: (store) => store.dispatch(FetchFavoritesAction()),
      builder: (context, vm) => Explore(
        pinned: vm.pinned,
      ),
    );
  }
}

class ViewModel extends BaseModel<AppState> {
  List<Category> pinned;

  ViewModel();

  ViewModel.build({
    @required this.pinned,
  }) : super(equals: [pinned]);

  @override
  ViewModel fromStore() {
    return ViewModel.build(
      pinned: state.savedCategories,
    );
  }
}
