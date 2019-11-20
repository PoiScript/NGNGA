import 'package:async_redux/async_redux.dart';
import 'package:ngnga/models/category.dart';

import 'package:ngnga/store/state.dart';

class RemoveCategoryAction extends ReduxAction<AppState> {
  final Category category;

  RemoveCategoryAction(this.category);

  @override
  Future<AppState> reduce() async {
    return state.copy(savedCategories: state.savedCategories..remove(category));
  }
}

class AddCategoryAction extends ReduxAction<AppState> {
  final Category category;

  AddCategoryAction(this.category);

  @override
  Future<AppState> reduce() async {
    return state.copy(savedCategories: state.savedCategories..add(category));
  }
}

class ClearCategoriesAction extends ReduxAction<AppState> {
  @override
  Future<AppState> reduce() async {
    return state.copy(savedCategories: []);
  }
}

class SaveCookiesAction extends ReduxAction<AppState> {
  final List<String> cookies;

  SaveCookiesAction(this.cookies);

  @override
  Future<AppState> reduce() async {
    return state.copy(cookies: cookies);
  }
}

class ClearCookiesAction extends ReduxAction<AppState> {
  @override
  Future<AppState> reduce() async {
    return state.copy(
      cookies: [],
    );
  }
}
