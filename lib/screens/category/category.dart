import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:built_value/built_value.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter/material.dart' hide Builder;
import 'package:intl/intl.dart';

import 'package:ngnga/models/category.dart';
import 'package:ngnga/screens/editor/editor.dart';
import 'package:ngnga/store/actions.dart';
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

  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoad;

  final Map<int, TopicState> topics;

  final String baseUrl;
  final Function(Category) addToPinned;
  final Function(Category) removeFromPinned;

  const CategoryPage({
    Key key,
    @required this.topics,
    @required this.categoryState,
    @required this.onRefresh,
    @required this.onLoad,
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
              '${_numberFormatter.format(categoryState.topicsCount)} topics',
              style: Theme.of(context).textTheme.caption,
            ),
          ],
        ),
        titleSpacing: 0,
      ),
      body: Scrollbar(
        child: EasyRefresh.builder(
          header: RefreshHeader(context),
          footer: NextPageHeader(context),
          onRefresh: onRefresh,
          onLoad: onLoad,
          builder: (context, physics, header, footer) => CustomScrollView(
            physics: physics,
            slivers: <Widget>[
              header,
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => index.isOdd
                      ? TopicRow(
                          topic: topics[
                              categoryState.topicIds.elementAt(index ~/ 2)],
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

  CategoryPageConnector({
    @required this.categoryId,
    @required this.isSubcategory,
  });

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ViewModel>(
      converter: (store) => ViewModel.fromStore(
        store,
        categoryId: categoryId,
        isSubcategory: isSubcategory,
      ),
      onInit: (store) => store.dispatch(FetchTopicsAction(
        categoryId: categoryId,
        isSubcategory: isSubcategory,
      )),
      builder: (context, vm) => CategoryPage(
        topics: vm.topics,
        categoryState: vm.categoryState,
        onRefresh: vm.onRefresh,
        onLoad: vm.onLoad,
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
  Map<int, TopicState> get topics;
  Future<void> Function() get onRefresh;
  Future<void> Function() get onLoad;
  String get baseUrl;
  Function(Category) get addToPinned;
  Function(Category) get removeFromPinned;

  factory ViewModel.fromStore(
    Store<AppState> store, {
    int categoryId,
    bool isSubcategory,
  }) {
    final categoryState = store.state.categoryStates[categoryId]?.toBuilder() ??
        CategoryStateBuilder();

    return ViewModel(
      (b) => b
        ..topics = store.state.topicStates.toMap()
        ..baseUrl = store.state.repository.baseUrl
        ..categoryState = categoryState
        ..onRefresh = (() => store.dispatchFuture(RefreshTopicsAction(
            categoryId: categoryId, isSubcategory: isSubcategory)))
        ..onLoad = (() => store.dispatchFuture(FetchNextTopicsAction(
            categoryId: categoryId, isSubcategory: isSubcategory)))
        ..addToPinned =
            ((category) => store.dispatch(AddToPinnedAction(category)))
        ..removeFromPinned =
            ((category) => store.dispatch(RemoveFromPinnedAction(category))),
    );
  }
}
