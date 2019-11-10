import 'package:flutter/material.dart';
import 'package:async_redux/async_redux.dart';

import './category_row.dart';
import '../../models/category.dart';
import '../../store/state.dart';

const kExpandedHeight = 200.0;

class HomePage extends StatelessWidget {
  final List<Category> categories;

  HomePage({
    @required this.categories,
  }) : assert(categories != null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: kExpandedHeight,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                "NGNGA",
                style: Theme.of(context)
                    .textTheme
                    .title
                    .copyWith(fontWeight: FontWeight.w900),
              ),
              titlePadding: EdgeInsets.all(0.0),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => GestureDetector(
                onTap: () => _onTap(context, categories[index].id),
                child: CategoryRow(categories[index]),
              ),
            ),
          )
        ],
      ),
    );
  }

  _onTap(BuildContext context, int categoryId) {
    Navigator.pushNamed(context, "/c", arguments: {"id": categoryId});
  }
}

class HomePageConnector extends StatelessWidget {
  HomePageConnector();

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ViewModel>(
      model: ViewModel(),
      builder: (BuildContext context, ViewModel vm) => HomePage(
        categories: vm.categories,
      ),
    );
  }
}

class ViewModel extends BaseModel<AppState> {
  List<Category> categories;

  ViewModel();

  ViewModel.build({
    @required this.categories,
  }) : super(equals: [categories]);

  @override
  ViewModel fromStore() {
    return ViewModel.build(
      categories:
          state.categories.values.map((state) => state.category).toList(),
    );
  }
}
