import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:ngnga/models/category.dart';

import 'package:ngnga/store/actions.dart';
import 'package:ngnga/store/state.dart';

class CategoryRow extends StatelessWidget {
  final Category category;
  final VoidCallback navigateToCategory;

  CategoryRow({
    @required this.category,
    @required this.navigateToCategory,
  })  : assert(category != null),
        assert(navigateToCategory != null);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(category.title),
      trailing: const Icon(Icons.keyboard_arrow_right),
      onTap: navigateToCategory,
    );
  }
}

class CategoryRowConnector extends StatelessWidget {
  final int categoryId;

  CategoryRowConnector({@required this.categoryId});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ViewModel>(
      model: ViewModel(categoryId),
      builder: (context, vm) => CategoryRow(
        category: vm.category,
        navigateToCategory: vm.navigateToCategory,
      ),
    );
  }
}

class ViewModel extends BaseModel<AppState> {
  final int categoryId;

  Category category;
  VoidCallback navigateToCategory;

  ViewModel(this.categoryId);

  ViewModel.build({
    @required this.categoryId,
    @required this.category,
    @required this.navigateToCategory,
  }) : super(equals: [categoryId, category]);

  @override
  ViewModel fromStore() {
    return ViewModel.build(
      categoryId: categoryId,
      category: state.categories[categoryId],
      navigateToCategory: () => dispatch(NavigateToCategoryAction(categoryId)),
    );
  }
}
