import 'dart:async';

import 'package:async_redux/async_redux.dart';

import 'package:ngnga/utils/requests.dart';

import '../state.dart';
import 'is_loading.dart';

class FetchTopicsAction extends ReduxAction<AppState> {
  final int categoryId;

  FetchTopicsAction(this.categoryId) : assert(categoryId != null);

  @override
  Future<AppState> reduce() async {
    final response = await fetchCategoryTopics(
      client: state.client,
      categoryId: categoryId,
      page: 0,
      isSubcategory: state.categories[categoryId].category.isSubcategory,
      cookies: state.cookies,
    );

    return state.copy(
      categories: state.categories
        ..update(
          categoryId,
          (categoryState) => categoryState.copy(
            topics: List.of(response.topics),
            topicsCount: response.topicCount,
            lastPage: 0,
          ),
        ),
    );
  }

  void before() => dispatch(IsLoadingAction(true));

  void after() => dispatch(IsLoadingAction(false));
}

class FetchNextTopicsAction extends ReduxAction<AppState> {
  final int categoryId;

  FetchNextTopicsAction(this.categoryId) : assert(categoryId != null);

  @override
  Future<AppState> reduce() async {
    final lastPage = state.categories[categoryId].lastPage;

    assert(lastPage <= (state.categories[categoryId].topicsCount / 35).ceil());

    final response = await fetchCategoryTopics(
      client: state.client,
      categoryId: categoryId,
      page: lastPage + 1,
      isSubcategory: state.categories[categoryId].category.isSubcategory,
      cookies: state.cookies,
    );

    return state.copy(
      categories: state.categories
        ..update(
          categoryId,
          (categoryState) => categoryState.copy(
            topics: categoryState.topics..addAll(response.topics),
            topicsCount: response.topicCount,
            lastPage: lastPage + 1,
          ),
        ),
    );
  }

  void before() => dispatch(IsLoadingAction(true));

  void after() => dispatch(IsLoadingAction(false));
}
