import 'dart:async';

import 'package:async_redux/async_redux.dart';

import 'package:ngnga/models/category.dart';
import 'package:ngnga/store/category.dart';
import 'package:ngnga/store/state.dart';

class FetchTopicsAction extends ReduxAction<AppState> {
  final int categoryId;
  final bool isSubcategory;

  FetchTopicsAction({
    this.categoryId,
    this.isSubcategory,
  })  : assert(categoryId != null),
        assert(isSubcategory != null);

  @override
  Future<AppState> reduce() async {
    if (state.categoryStates[categoryId] == null ||
        state.categoryStates[categoryId] is CategoryUninitialized) {
      await dispatchFuture(RefreshTopicsAction(
        categoryId: categoryId,
        isSubcategory: isSubcategory,
      ));
    }

    return null;
  }
}

class RefreshTopicsAction extends ReduxAction<AppState> {
  final int categoryId;
  final bool isSubcategory;

  RefreshTopicsAction({
    this.categoryId,
    this.isSubcategory,
  })  : assert(categoryId != null),
        assert(isSubcategory != null);

  @override
  Future<AppState> reduce() async {
    final res = await state.repository.fetchCategoryTopics(
      categoryId: categoryId,
      page: 0,
      isSubcategory: isSubcategory,
    );

    return state.copy(
      categoryStates: state.categoryStates
        ..[categoryId] = CategoryLoaded(
          topicIds: res.topics.map((t) => t.id).toList(),
          topicsCount: res.topicCount,
          lastPage: 0,
          maxPage: res.maxPage,
          category: Category(
            id: categoryId,
            title: 'title',
            isSubcategory: isSubcategory,
          ),
          // TODO:
          toppedTopic: 'null',
          isPinned: state.pinned.indexWhere((c) => c.id == categoryId) != -1,
        ),
      topics: state.topics
        ..addEntries(res.topics.map((t) => MapEntry(t.id, t))),
    );
  }
}

class FetchNextTopicsAction extends ReduxAction<AppState> {
  final int categoryId;
  final bool isSubcategory;

  FetchNextTopicsAction({
    this.categoryId,
    this.isSubcategory,
  })  : assert(categoryId != null),
        assert(isSubcategory != null);

  @override
  Future<AppState> reduce() async {
    CategoryState categoryState = state.categoryStates[categoryId];

    if (categoryState is CategoryLoaded) {
      final res = await state.repository.fetchCategoryTopics(
        categoryId: categoryId,
        page: categoryState.lastPage + 1,
        isSubcategory: isSubcategory,
      );

      return state.copy(
        categoryStates: state.categoryStates
          ..[categoryId] = categoryState.copyWith(
            topicIds: categoryState.topicIds
              ..addAll(res.topics.map((t) => t.id)),
            topicsCount: res.topicCount,
            lastPage: categoryState.lastPage + 1,
            maxPage: res.maxPage,
          ),
        topics: state.topics
          ..addEntries(res.topics.map((t) => MapEntry(t.id, t))),
      );
    }

    return null;
  }
}
