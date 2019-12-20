import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:flutter/widgets.dart' hide Builder;

import 'package:business/category/actions/jump_to_page_action.dart';
import 'package:business/category/actions/load_next_page_action.dart';
import 'package:business/category/actions/load_previous_page_action.dart';
import 'package:business/category/actions/refresh_first_page_action.dart';
import 'package:business/pinned/actions/add_to_pinned_action.dart';
import 'package:business/pinned/actions/remove_from_pinned_action.dart';
import 'package:business/app_state.dart';
import 'package:business/category/models/category_state.dart';
import 'package:business/models/category.dart';
import 'package:business/topic/models/topic_state.dart';

import 'category_page.dart';

part 'category_page_connector.g.dart';

class CategoryPageConnector extends StatelessWidget {
  final int categoryId;
  final bool isSubcategory;
  final int pageIndex;

  CategoryPageConnector({
    @required this.categoryId,
    @required this.isSubcategory,
    @required this.pageIndex,
  });

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      converter: (store) => _ViewModel.fromStore(
        store,
        categoryId: categoryId,
        isSubcategory: isSubcategory,
        pageIndex: pageIndex,
      ),
      onInit: (store) => store.dispatch(JumpToPageAction(
        categoryId: categoryId,
        isSubcategory: isSubcategory,
        pageIndex: pageIndex,
      )),
      builder: (context, vm) => CategoryPage(
        topics: vm.topics,
        categoryState: vm.categoryState,
        refreshFirst: vm.refreshFirst,
        loadPrevious: vm.loadPrevious,
        loadNext: vm.loadNext,
        changePage: vm.changePage,
        baseUrl: vm.baseUrl,
        addToPinned: vm.addToPinned,
        removeFromPinned: vm.removeFromPinned,
      ),
    );
  }
}

abstract class _ViewModel implements Built<_ViewModel, _ViewModelBuilder> {
  _ViewModel._();

  factory _ViewModel([Function(_ViewModelBuilder) updates]) = _$ViewModel;

  CategoryState get categoryState;
  BuiltMap<int, TopicState> get topics;
  Future<void> Function() get refreshFirst;
  Future<void> Function() get loadPrevious;
  Future<void> Function() get loadNext;
  Future<void> Function(int) get changePage;
  String get baseUrl;
  Function(Category) get addToPinned;
  Function(Category) get removeFromPinned;

  factory _ViewModel.fromStore(
    Store<AppState> store, {
    int categoryId,
    bool isSubcategory,
    int pageIndex,
  }) {
    return _ViewModel(
      (b) => b
        ..topics = store.state.topicStates.toBuilder()
        ..baseUrl = store.state.repository.baseUrl
        ..categoryState = store.state.categoryStates[categoryId]?.toBuilder() ??
            CategoryStateBuilder()
        ..refreshFirst = (() => store.dispatchFuture(RefreshFirstPageAction(
              categoryId: categoryId,
              isSubcategory: isSubcategory,
            )))
        ..loadPrevious = (() => store.dispatchFuture(LoadPreviousPageAction(
            categoryId: categoryId, isSubcategory: isSubcategory)))
        ..loadNext = (() => store.dispatchFuture(LoadNextPageAction(
            categoryId: categoryId, isSubcategory: isSubcategory)))
        ..changePage = ((pageIndex) => store.dispatchFuture(JumpToPageAction(
              categoryId: categoryId,
              isSubcategory: isSubcategory,
              pageIndex: pageIndex,
            )))
        ..addToPinned =
            ((category) => store.dispatch(AddToPinnedAction(category)))
        ..removeFromPinned =
            ((category) => store.dispatch(RemoveFromPinnedAction(category))),
    );
  }
}
