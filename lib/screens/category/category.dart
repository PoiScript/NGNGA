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
  final CategoryLoaded categoryState;

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
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
      floatingActionButton: _buildFab(context),
    );
  }

  Widget _buildFab(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () {
        Navigator.pushNamed(context, '/e', arguments: {
          'action': EditorAction.newTopic,
          'categoryId': categoryState.category.id,
        });
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
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
    );
  }

  Widget _buildBody(BuildContext context) {
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
                        topic: topics[categoryState.topicIds[index ~/ 2]],
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
      builder: (context, vm) {
        if (vm.categoryState is CategoryUninitialized) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return CategoryPage(
          topics: vm.topics,
          categoryState: vm.categoryState,
          onRefresh: vm.onRefresh,
          onLoad: vm.onLoad,
          baseUrl: vm.baseUrl,
          addToPinned: vm.addToPinned,
          removeFromPinned: vm.removeFromPinned,
        );
      },
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
