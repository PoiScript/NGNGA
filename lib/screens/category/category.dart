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
import 'package:ngnga/store/state.dart';
import 'package:ngnga/widgets/refresh.dart';
import 'package:ngnga/widgets/topic_row.dart';

import 'popup_menu.dart';

final _numberFormatter = NumberFormat('#,###,###,###');

class CategoryPage extends StatelessWidget {
  final Category category;
  final List<Topic> topics;
  final int topicsCount;

  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoad;

  CategoryPage({
    Key key,
    @required this.category,
    @required this.topics,
    @required this.topicsCount,
    @required this.onRefresh,
    @required this.onLoad,
  })  : assert(topics != null),
        assert(category != null),
        assert(topicsCount != null),
        assert(onRefresh != null),
        assert(onLoad != null),
        super(key: key);

  Widget build(BuildContext context) {
    if (topics.isEmpty) {
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
          PopupMenuConnector(categoryId: category.id),
        ],
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              category.title,
              style: Theme.of(context).textTheme.subhead,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${_numberFormatter.format(topicsCount)} topics',
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
                      ? TopicRowConnector(topics[index ~/ 2])
                      : Divider(height: 0),
                  childCount: topics.length * 2 + 1,
                  semanticIndexCallback: (widget, localIndex) =>
                      localIndex.isOdd ? localIndex ~/ 2 : null,
                ),
              ),
              if (topics.length ~/ 35 != topicsCount ~/ 35) footer,
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, '/e', arguments: {
            'action': EditorAction.newTopic,
            'categoryId': category.id,
          });
        },
      ),
    );
  }
}

class CategoryPageConnector extends StatelessWidget {
  final int categoryId;

  CategoryPageConnector({
    @required this.categoryId,
  });

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ViewModel>(
      model: ViewModel(categoryId),
      onInit: (store) => store.dispatch(FetchTopicsAction(categoryId)),
      builder: (context, vm) => CategoryPage(
        category: vm.category,
        topics: vm.topics,
        topicsCount: vm.topicsCount,
        onRefresh: vm.onRefresh,
        onLoad: vm.onLoad,
      ),
    );
  }
}

class ViewModel extends BaseModel<AppState> {
  final int categoryId;

  Category category;
  List<Topic> topics;
  int topicsCount;

  Future<void> Function() onRefresh;
  Future<void> Function() onLoad;

  ViewModel(this.categoryId);

  ViewModel.build({
    @required this.topics,
    @required this.categoryId,
    @required this.category,
    @required this.topicsCount,
    @required this.onRefresh,
    @required this.onLoad,
  }) : super(equals: [categoryId, category, topics, topicsCount]);

  @override
  ViewModel fromStore() {
    CategoryState categoryState = state.categoryStates[categoryId];
    return ViewModel.build(
      categoryId: categoryId,
      category: state.categories[categoryId],
      topics: categoryState.topicIds.map((id) => state.topics[id]).toList(),
      topicsCount: categoryState.topicsCount,
      onRefresh: () => dispatchFuture(FetchTopicsAction(categoryId)),
      onLoad: () => dispatchFuture(FetchNextTopicsAction(categoryId)),
    );
  }
}
