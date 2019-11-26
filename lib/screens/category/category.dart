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
import 'package:ngnga/widgets/topic_row.dart';

const kExpandedHeight = 150.0;

final numberFormatter = NumberFormat("#,###,###,###");

class CategoryPage extends StatefulWidget {
  final Category category;
  final List<Topic> topics;
  final int topicsCount;

  final Event<String> snackBarEvt;

  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoad;

  final bool isPinned;
  final VoidCallback addToPinned;
  final VoidCallback removeFromPinned;

  CategoryPage({
    @required this.category,
    @required this.topics,
    @required this.topicsCount,
    @required this.snackBarEvt,
    @required this.onRefresh,
    @required this.onLoad,
    @required this.isPinned,
    @required this.addToPinned,
    @required this.removeFromPinned,
  })  : assert(topics != null),
        assert(category != null),
        assert(topicsCount != null),
        assert(isPinned != null),
        assert(snackBarEvt != null),
        assert(onRefresh != null),
        assert(onLoad != null),
        assert(addToPinned != null),
        assert(removeFromPinned != null);

  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  AnimationController _animationController;
  Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

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

  @required
  didUpdateWidget(CategoryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _consumeEvents();
  }

  _consumeEvents() {
    String message = widget.snackBarEvt.consume();
    if (message != null)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 3),
          ));
        }
      });
  }

  Widget build(BuildContext context) {
    if (widget.topics.isEmpty) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      key: _scaffoldKey,
      body: Scrollbar(
        child: EasyRefresh.builder(
          header: ClassicalHeader(),
          footer: ClassicalFooter(),
          onRefresh: widget.onRefresh,
          onLoad: widget.onLoad,
          builder: (context, physics, header, footer) => CustomScrollView(
            controller: _scrollController,
            physics: physics,
            slivers: <Widget>[
              SliverAppBar(
                expandedHeight: kExpandedHeight,
                floating: false,
                pinned: true,
                leading: const BackButton(color: Colors.black),
                backgroundColor: Theme.of(context).backgroundColor,
                actions: <Widget>[
                  widget.isPinned
                      ? IconButton(
                          color: Colors.black,
                          icon: Icon(Icons.star),
                          onPressed: widget.removeFromPinned,
                        )
                      : IconButton(
                          color: Colors.black,
                          icon: Icon(Icons.star_border),
                          onPressed: widget.addToPinned,
                        ),
                  IconButton(
                    color: Colors.black,
                    icon: Icon(Icons.more_vert),
                    onPressed: () {},
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  title: Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(horizontal: 58.0),
                    height: kToolbarHeight,
                    child: Text(
                      widget.category.title,
                      style: Theme.of(context).textTheme.subhead,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  titlePadding: EdgeInsets.all(0.0),
                ),
              ),
              header,
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  alignment: Alignment.centerRight,
                  child: Text(
                    "${numberFormatter.format(widget.topicsCount)} topics",
                    style: Theme.of(context).textTheme.caption,
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index.isOdd) {
                      return TopicRowConnector(widget.topics[index ~/ 2]);
                    }
                    return Divider(
                      height: 1.0,
                    );
                  },
                  semanticIndexCallback: (widget, localIndex) {
                    if (localIndex.isOdd) {
                      return localIndex ~/ 2;
                    }
                    return null;
                  },
                  childCount: widget.topics.length * 2 + 1,
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
          onPressed: () {
            Navigator.pushNamed(context, "/e", arguments: {
              "action": ACTION_NEW_TOPIC,
              "categoryId": widget.category.id,
            });
          },
          child: Icon(Icons.add),
          backgroundColor: Colors.blue,
        ),
      ),
    );
  }
}

class CategoryPageConnector extends StatelessWidget {
  final int categoryId;

  CategoryPageConnector(this.categoryId);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ViewModel>(
      model: ViewModel(categoryId),
      onInit: (store) => store.dispatch(FetchTopicsAction(categoryId)),
      builder: (context, vm) => CategoryPage(
        category: vm.category,
        topics: vm.topics,
        topicsCount: vm.topicsCount,
        snackBarEvt: vm.snackBarEvt,
        onRefresh: vm.onRefresh,
        onLoad: vm.onLoad,
        isPinned: vm.isPinned,
        addToPinned: vm.addToPinned,
        removeFromPinned: vm.removeFromPinned,
      ),
    );
  }
}

class ViewModel extends BaseModel<AppState> {
  final int categoryId;

  Category category;
  List<Topic> topics;
  int topicsCount;

  Event<String> snackBarEvt;

  Future<void> Function() onRefresh;
  Future<void> Function() onLoad;

  bool isPinned;
  VoidCallback addToPinned;
  VoidCallback removeFromPinned;

  ViewModel(this.categoryId);

  ViewModel.build({
    @required this.topics,
    @required this.isPinned,
    @required this.snackBarEvt,
    @required this.categoryId,
    @required this.category,
    @required this.topicsCount,
    @required this.onRefresh,
    @required this.onLoad,
    @required this.addToPinned,
    @required this.removeFromPinned,
  }) : super(equals: [category, topics, topicsCount, snackBarEvt, isPinned]);

  @override
  ViewModel fromStore() {
    var categoryState = state.categoryStates[categoryId];
    return ViewModel.build(
      categoryId: categoryId,
      category: state.categories[categoryId],
      topics: categoryState.topicIds.map((id) => state.topics[id]).toList(),
      topicsCount: categoryState.topicsCount,
      snackBarEvt: state.categorySnackBarEvt,
      onRefresh: () => dispatchFuture(FetchTopicsAction(categoryId)),
      onLoad: () => dispatchFuture(FetchNextTopicsAction(categoryId)),
      isPinned: state.pinned.contains(categoryId),
      addToPinned: () => dispatch(AddToPinnedAction(categoryId)),
      removeFromPinned: () => dispatch(RemoveFromPinnedAction(categoryId)),
    );
  }
}
