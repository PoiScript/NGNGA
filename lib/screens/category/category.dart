import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ngnga/models/category.dart';
import 'package:ngnga/models/topic.dart';
import 'package:ngnga/screens/editor/editor.dart';
import 'package:ngnga/store/actions.dart';
import 'package:ngnga/store/category.dart';
import 'package:ngnga/store/state.dart';
import 'package:ngnga/widgets/refresh.dart';
import 'package:ngnga/widgets/topic_row.dart';

import 'popup_menu.dart';

final _numberFormatter = NumberFormat('#,###,###,###');

class CategoryPage extends StatelessWidget {
  final CategoryState categoryState;

  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoad;

  final Map<int, Topic> topics;

  final String baseUrl;
  final Function(Category) addToPinned;
  final Function(Category) removeFromPinned;

  CategoryPage({
    Key key,
    @required this.topics,
    @required this.categoryState,
    @required this.onRefresh,
    @required this.onLoad,
    @required this.baseUrl,
    @required this.addToPinned,
    @required this.removeFromPinned,
  })  : assert(categoryState != null),
        assert(onRefresh != null),
        assert(onLoad != null),
        super(key: key);

  Widget build(BuildContext context) {
    if (categoryState is CategoryUninitialized) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (categoryState is CategoryLoaded) {
      return Scaffold(
        appBar: _buildAppBar(context, categoryState),
        body: _buildBody(context, categoryState),
        floatingActionButton: _buildFab(context, categoryState),
      );
    }

    return null;
  }

  Widget _buildFab(BuildContext context, CategoryLoaded state) {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () {
        Navigator.pushNamed(context, '/e', arguments: {
          'action': EditorAction.newTopic,
          'categoryId': state.category.id,
        });
      },
    );
  }

  Widget _buildAppBar(BuildContext context, CategoryLoaded state) {
    return AppBar(
      leading: BackButton(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      actions: <Widget>[
        PopupMenu(
          categoryId: state.category.id,
          isSubcategory: state.category.isSubcategory,
          baseUrl: baseUrl,
          isPinned: state.isPinned,
          addToPinned: () => addToPinned(state.category),
          removeFromPinned: () => removeFromPinned(state.category),
        ),
      ],
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            state.category.title,
            style: Theme.of(context).textTheme.subhead,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${_numberFormatter.format(state.topicsCount)} topics',
            style: Theme.of(context).textTheme.caption,
          ),
        ],
      ),
      titleSpacing: 0,
    );
  }

  Widget _buildBody(BuildContext context, CategoryLoaded state) {
    return Scrollbar(
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
                        topic: topics[state.topicIds[index ~/ 2]],
                      )
                    : Divider(height: 0),
                childCount: state.topicIds.length * 2 + 1,
                semanticIndexCallback: (widget, localIndex) =>
                    localIndex.isOdd ? localIndex ~/ 2 : null,
              ),
            ),
            if (!state.hasRechedMax) footer,
          ],
        ),
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
      model: ViewModel(
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

class ViewModel extends BaseModel<AppState> {
  final int categoryId;
  final bool isSubcategory;

  CategoryState categoryState;

  Map<int, Topic> topics;

  Future<void> Function() onRefresh;
  Future<void> Function() onLoad;

  String baseUrl;
  Function(Category) addToPinned;
  Function(Category) removeFromPinned;

  ViewModel({this.categoryId, this.isSubcategory});

  ViewModel.build({
    @required this.topics,
    @required this.isSubcategory,
    @required this.categoryId,
    @required this.categoryState,
    @required this.onRefresh,
    @required this.onLoad,
    @required this.baseUrl,
    @required this.addToPinned,
    @required this.removeFromPinned,
  }) : super(equals: [topics, categoryId, categoryState]);

  @override
  ViewModel fromStore() {
    return ViewModel.build(
      topics: state.topics,
      categoryId: categoryId,
      isSubcategory: isSubcategory,
      categoryState:
          state.categoryStates[categoryId] ?? CategoryUninitialized(),
      onRefresh: () => dispatchFuture(RefreshTopicsAction(
        categoryId: categoryId,
        isSubcategory: isSubcategory,
      )),
      onLoad: () => dispatchFuture(FetchNextTopicsAction(
        categoryId: categoryId,
        isSubcategory: isSubcategory,
      )),
      baseUrl: state.settings.baseUrl,
      addToPinned: (category) => dispatch(AddToPinnedAction(category)),
      removeFromPinned: (category) =>
          dispatch(RemoveFromPinnedAction(category)),
    );
  }
}
