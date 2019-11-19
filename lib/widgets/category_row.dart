import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:ngnga/models/category.dart';

import 'package:ngnga/store/actions.dart';
import 'package:ngnga/store/state.dart';

class CategoryRow extends StatelessWidget {
  final void Function(Category) navigateToCategory;
  final Category category;

  CategoryRow({
    @required this.navigateToCategory,
    @required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(category.title),
      trailing: const Icon(Icons.keyboard_arrow_right),
      onTap: () => navigateToCategory(category),
    );
  }
}

class CategoryRowConnector extends StatelessWidget {
  final Category category;

  CategoryRowConnector({@required this.category});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ViewModel>(
      model: ViewModel(),
      builder: (context, vm) => CategoryRow(
        navigateToCategory: vm.navigateToCategory,
        category: category,
      ),
    );
  }
}

class ViewModel extends BaseModel<AppState> {
  void Function(Category) navigateToCategory;

  ViewModel();

  ViewModel.build({@required this.navigateToCategory});

  @override
  ViewModel fromStore() {
    return ViewModel.build(
      navigateToCategory: (category) =>
          dispatch(NavigateToCategoryAction(category)),
    );
  }
}
