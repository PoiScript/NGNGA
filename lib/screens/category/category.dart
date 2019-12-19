import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter/material.dart' hide Builder;
import 'package:intl/intl.dart';

import 'package:ngnga/models/category.dart';
import 'package:ngnga/screens/editor/editor.dart';
import 'package:ngnga/store/actions/category.dart';
import 'package:ngnga/store/actions/pinned.dart';
import 'package:ngnga/store/category.dart';
import 'package:ngnga/store/state.dart';
import 'package:ngnga/store/topic.dart';
import 'package:ngnga/widgets/refresh.dart';
import 'package:ngnga/widgets/topic_row.dart';

import 'popup_menu.dart';

part 'category.g.dart';

final _numberFormatter = NumberFormat('#,###,###,###');

class CategoryPage extends StatelessWidget {
  final CategoryState categoryState;

  final Future<void> Function() refreshFirst;
  final Future<void> Function() loadPrevious;
  final Future<void> Function() loadNext;
  final Future<void> Function(int) changePage;

  final BuiltMap<int, TopicState> topics;

  final String baseUrl;
  final Function(Category) addToPinned;
  final Function(Category) removeFromPinned;

  const CategoryPage({
    Key key,
    @required this.topics,
    @required this.categoryState,
    @required this.refreshFirst,
    @required this.loadPrevious,
    @required this.loadNext,
    @required this.changePage,
    @required this.baseUrl,
    @required this.addToPinned,
    @required this.removeFromPinned,
  }) : super(key: key);

  Widget build(BuildContext context) {
    if (!categoryState.initialized) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: <Widget>[
          PopupMenu(
            categoryId: categoryState.category.id,
            isSubcategory: categoryState.category.isSubcategory,
            toppedTopicId: categoryState.toppedTopicId,
            baseUrl: baseUrl,
            isPinned: categoryState.isPinned,
            addToPinned: () => addToPinned(categoryState.category),
            removeFromPinned: () => removeFromPinned(categoryState.category),
            changePage: changePage,
            firstPage: categoryState.firstPage,
            maxPage: categoryState.maxPage,
          ),
        ],
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              categoryState.category.title,
              style: Theme.of(context).textTheme.subhead,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${_numberFormatter.format(categoryState.topicsCount)} topics${categoryState.isPinned ? ' ‎· pinned' : ''}',
              style: Theme.of(context).textTheme.caption,
            ),
          ],
        ),
        titleSpacing: 0,
      ),
      body: Scrollbar(
        child: EasyRefresh.builder(
          header: PreviousPageHeader(context, categoryState.firstPage),
          footer: NextPageHeader(context),
          onRefresh: categoryState.hasRechedMin ? refreshFirst : loadPrevious,
          onLoad: loadNext,
          builder: (context, physics, header, footer) => CustomScrollView(
            physics: physics,
            slivers: <Widget>[
              header,
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => index.isOdd
                      ? TopicRow(
                          topics[categoryState.topicIds.elementAt(index ~/ 2)],
                        )
                      : Divider(height: 0),
                  childCount: categoryState.topicIds.length * 2 + 1,
                  semanticIndexCallback: (widget, localIndex) =>
                      localIndex.isOdd ? localIndex ~/ 2 : null,
                ),
              ),
              if (!categoryState.hasRechedMax) footer,
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, '/e', arguments: {
            'action': EditorAction.newTopic,
            'categoryId': categoryState.category.id,
          });
        },
      ),
    );
  }
}

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
    return StoreConnector<AppState, ViewModel>(
      converter: (store) => ViewModel.fromStore(
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

abstract class ViewModel implements Built<ViewModel, ViewModelBuilder> {
  ViewModel._();

  factory ViewModel([Function(ViewModelBuilder) updates]) = _$ViewModel;

  CategoryState get categoryState;
  BuiltMap<int, TopicState> get topics;
  Future<void> Function() get refreshFirst;
  Future<void> Function() get loadPrevious;
  Future<void> Function() get loadNext;
  Future<void> Function(int) get changePage;
  String get baseUrl;
  Function(Category) get addToPinned;
  Function(Category) get removeFromPinned;

  factory ViewModel.fromStore(
    Store<AppState> store, {
    int categoryId,
    bool isSubcategory,
    int pageIndex,
  }) {
    return ViewModel(
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
