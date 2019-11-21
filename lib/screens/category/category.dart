import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ngnga/models/category.dart';
import 'package:ngnga/models/topic.dart';
import 'package:ngnga/store/actions.dart';
import 'package:ngnga/store/state.dart';
import 'package:ngnga/widgets/topic_row.dart';

const kExpandedHeight = 150.0;

final numberFormatter = NumberFormat("#,###,###,###");

class CategoryPage extends StatefulWidget {
  final Category category;
  final List<Topic> topics;
  final int topicsCount;
  final bool isLoading;
  final bool isSaved;
  final Event<String> snackBarEvt;

  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoad;
  final void Function(Topic, int) navigateToTopic;
  final void Function(Category) navigateToCategory;

  final VoidCallback saveCategory;
  final VoidCallback removeCategory;

  CategoryPage({
    @required this.topics,
    @required this.isSaved,
    @required this.category,
    @required this.topicsCount,
    @required this.isLoading,
    @required this.snackBarEvt,
    @required this.onRefresh,
    @required this.onLoad,
    @required this.navigateToTopic,
    @required this.navigateToCategory,
    @required this.saveCategory,
    @required this.removeCategory,
  })  : assert(topics != null),
        assert(category != null),
        assert(topicsCount != null),
        assert(isLoading != null),
        assert(isSaved != null),
        assert(snackBarEvt != null),
        assert(onRefresh != null),
        assert(onLoad != null),
        assert(navigateToTopic != null),
        assert(navigateToCategory != null),
        assert(saveCategory != null),
        assert(removeCategory != null);

  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
    if (widget.isLoading && widget.topics.isEmpty) {
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
            physics: physics,
            slivers: <Widget>[
              SliverAppBar(
                expandedHeight: kExpandedHeight,
                floating: false,
                pinned: true,
                leading: const BackButton(color: Colors.black),
                backgroundColor: Theme.of(context).backgroundColor,
                actions: <Widget>[
                  widget.isSaved
                      ? IconButton(
                          color: Colors.black,
                          icon: Icon(Icons.star),
                          onPressed: () => widget.removeCategory(),
                        )
                      : IconButton(
                          color: Colors.black,
                          icon: Icon(Icons.star_border),
                          onPressed: () => widget.saveCategory(),
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
        isLoading: vm.isLoading,
        isSaved: vm.isSaved,
        topics: vm.topics,
        category: vm.category,
        topicsCount: vm.topicsCount,
        snackBarEvt: vm.snackBarEvt,
        onRefresh: vm.onRefresh,
        onLoad: vm.onLoad,
        navigateToTopic: vm.navigateToTopic,
        navigateToCategory: vm.navigateToCategory,
        saveCategory: vm.saveCategory,
        removeCategory: vm.removeCategory,
      ),
    );
  }
}

class ViewModel extends BaseModel<AppState> {
  final int categoryId;

  Category category;
  List<Topic> topics;
  int topicsCount;
  bool isLoading;
  bool isSaved;
  Event<String> snackBarEvt;

  Future<void> Function() onRefresh;
  Future<void> Function() onLoad;

  void Function(Topic, int) navigateToTopic;
  void Function(Category) navigateToCategory;

  VoidCallback saveCategory;
  VoidCallback removeCategory;

  ViewModel(this.categoryId);

  ViewModel.build({
    @required this.topics,
    @required this.isLoading,
    @required this.isSaved,
    @required this.snackBarEvt,
    @required this.categoryId,
    @required this.category,
    @required this.topicsCount,
    @required this.onRefresh,
    @required this.onLoad,
    @required this.navigateToTopic,
    @required this.navigateToCategory,
    @required this.saveCategory,
    @required this.removeCategory,
  }) : super(equals: [
          isLoading,
          snackBarEvt,
          isSaved,
          topics,
          category,
          topicsCount,
        ]);

  @override
  ViewModel fromStore() {
    var categoryState = state.categories[categoryId];
    return ViewModel.build(
      categoryId: categoryId,
      isLoading: state.isLoading,
      isSaved: state.savedCategories.contains(categoryState.category),
      category: categoryState.category,
      topics: categoryState.topics,
      topicsCount: categoryState.topicsCount,
      snackBarEvt: state.snackBarEvt,
      onRefresh: () => dispatchFuture(FetchTopicsAction(categoryId)),
      onLoad: () => dispatchFuture(FetchNextTopicsAction(categoryId)),
      navigateToTopic: (topic, page) =>
          dispatch(NavigateToTopicAction(topic, page)),
      navigateToCategory: (category) =>
          dispatch(NavigateToCategoryAction(category)),
      saveCategory: () => dispatch(AddCategoryAction(categoryState.category)),
      removeCategory: () =>
          dispatch(RemoveCategoryAction(categoryState.category)),
    );
  }
}
