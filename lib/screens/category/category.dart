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

class CategoryPage extends StatefulWidget {
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

  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage>
    with TickerProviderStateMixin<CategoryPage> {
  final ScrollController _scrollController = ScrollController();

  AnimationController _animationController;
  Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(vsync: this, duration: kThemeAnimationDuration);

    _offset = Tween<Offset>(begin: Offset.zero, end: Offset(0.0, 2.0))
        .animate(_animationController);

    _scrollController.addListener(() {
      final direction = _scrollController.position.userScrollDirection;
      if (direction == ScrollDirection.reverse &&
          _animationController.isCompleted) {
        _animationController.reverse();
      } else if (direction == ScrollDirection.forward &&
          _animationController.isDismissed) {
        _animationController.forward();
      }
    });
  }

  Widget build(BuildContext context) {
    if (widget.topics.isEmpty) {
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
          PopupMenuConnector(categoryId: widget.category.id),
        ],
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.category.title,
              style: Theme.of(context).textTheme.subhead,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${_numberFormatter.format(widget.topicsCount)} topics',
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
          onRefresh: widget.onRefresh,
          onLoad: widget.onLoad,
          builder: (context, physics, header, footer) => CustomScrollView(
            controller: _scrollController,
            physics: physics,
            slivers: <Widget>[
              header,
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => index.isOdd
                      ? TopicRowConnector(widget.topics[index ~/ 2])
                      : Divider(height: 0),
                  childCount: widget.topics.length * 2 + 1,
                  semanticIndexCallback: (widget, localIndex) =>
                      localIndex.isOdd ? localIndex ~/ 2 : null,
                ),
              ),
              if (widget.topics.length ~/ 35 != widget.topicsCount ~/ 35)
                footer,
            ],
          ),
        ),
      ),
      floatingActionButton: SlideTransition(
        position: _offset,
        child: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.pushNamed(context, '/e', arguments: {
              'action': EditorAction.newTopic,
              'categoryId': widget.category.id,
            });
          },
        ),
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
