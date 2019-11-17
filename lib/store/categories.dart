import 'dart:convert';
import 'dart:io';

import 'package:async_redux/async_redux.dart';
import 'package:ngnga/models/category.dart';

import 'package:ngnga/store/state.dart';
import 'package:path_provider/path_provider.dart';

class RemoveCategoryAction extends ReduxAction<AppState> {
  final Category category;

  RemoveCategoryAction(this.category);

  @override
  Future<AppState> reduce() async {
    return state.copy(savedCategories: state.savedCategories..remove(category));
  }

  void after() => dispatch(_SaveStateToDiskAction());
}

class AddCategoryAction extends ReduxAction<AppState> {
  final Category category;

  AddCategoryAction(this.category);

  @override
  Future<AppState> reduce() async {
    return state.copy(savedCategories: state.savedCategories..add(category));
  }

  void after() => dispatch(_SaveStateToDiskAction());
}

class ClearCategoriesAction extends ReduxAction<AppState> {
  @override
  Future<AppState> reduce() async {
    return state.copy(savedCategories: []);
  }

  void after() => dispatch(_SaveStateToDiskAction());
}

class SaveCookiesAction extends ReduxAction<AppState> {
  final List<String> cookies;

  SaveCookiesAction(this.cookies);

  @override
  Future<AppState> reduce() async {
    return state.copy(cookies: cookies);
  }

  void after() => dispatch(_SaveStateToDiskAction());
}

class ClearCookiesAction extends ReduxAction<AppState> {
  @override
  Future<AppState> reduce() async {
    return state.copy(
      cookies: [],
    );
  }

  void after() => dispatch(_SaveStateToDiskAction());
}

class _SaveStateToDiskAction extends ReduxAction<AppState> {
  @override
  Future<AppState> reduce() async {
    String json = jsonEncode({
      "cookies": state.cookies,
      "saved_cateogries": state.savedCategories.map((c) => c.toJson()).toList()
    });

    final directory = await getApplicationDocumentsDirectory();

    final file = File('${directory.path}/state.json');

    file.writeAsString(json);

    return null;
  }
}
