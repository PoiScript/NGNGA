import 'dart:async';

// import 'package:async_redux/async_redux.dart';
import 'package:built_collection/built_collection.dart';
// import 'package:built_value/built_value.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:business/category/models/category_state.dart';
import 'package:business/models/editor_action.dart';
import 'package:business/topic/models/topic_state.dart';
import 'package:business/models/category.dart';
// import 'package:ngnga/screens/editor/editor.dart';
// import 'package:ngnga/store/actions/category.dart';
// import 'package:ngnga/store/actions/pinned.dart';
// import 'package:ngnga/store/category.dart';
// import 'package:ngnga/store/state.dart';
// import 'package:ngnga/store/topic.dart';
import 'package:ngnga/widgets/refresh.dart';
import 'package:ngnga/widgets/topic_row.dart';

import 'popup_menu.dart';

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
          header: categoryState.hasRechedMin
              ? RefreshHeader(context)
              : PreviousPageHeader(context, categoryState.firstPage),
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
