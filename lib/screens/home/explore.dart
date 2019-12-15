import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:ngnga/localizations.dart';

import 'package:ngnga/models/category.dart';
import 'package:ngnga/store/state.dart';
import 'package:ngnga/utils/categories.dart';

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
            color: Theme.of(context).cardColor,
            child: Text(
              AppLocalizations.of(context).pinned,
              style: Theme.of(context).textTheme.caption,
            ),
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => ListTile(
                title: Text(pinned[index].title),
                trailing: const Icon(Icons.keyboard_arrow_right),
                onTap: () => Navigator.pushNamed(context, '/c', arguments: {
                  'id': pinned[index].id,
                  'isSubcategory': pinned[index].isSubcategory,
                }),
              ),
              childCount: pinned.length,
            ),
          ),
        ),
        for (CategoryGroup group in categoryGroups)
          SliverStickyHeader(
            header: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              color: Theme.of(context).cardColor,
              child: Text(
                group.name,
                style: Theme.of(context).textTheme.caption,
              ),
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => ListTile(
                  title: Text(group.categories[index].title),
                  trailing: const Icon(Icons.keyboard_arrow_right),
                  onTap: () => Navigator.pushNamed(context, 'c', arguments: {
                    'id': group.categories[index].id,
                    'isSubcategory': group.categories[index].isSubcategory,
                  }),
                ),
                childCount: group.categories.length,
              ),
            ),
          ),
      ],
    );
  }
}

class ExploreConnector extends StatelessWidget {
  ExploreConnector();

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ViewModel>(
      model: ViewModel(),
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
    return ViewModel.build(pinned: state.pinned);
  }
}
