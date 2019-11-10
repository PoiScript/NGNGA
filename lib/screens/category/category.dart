import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';

import './topic_row.dart';
import '../../models/topic.dart';
import '../../models/category.dart';
import '../../store/state.dart';
import '../../store/fetch_topics.dart';
import '../../widgets/flexible_title.dart';

class CategoryPage extends StatefulWidget {
  final Category category;
  final List<Topic> topics;
  final int topicsCount;
  final bool isLoading;

  final Future<void> Function() onRefresh;
  final VoidCallback fetchNext;

  bool get containsMaxPage => (topics.length ~/ 20) == (topicsCount ~/ 20);

  CategoryPage({
    Key key,
    @required this.topics,
    @required this.category,
    @required this.topicsCount,
    @required this.isLoading,
    @required this.onRefresh,
    @required this.fetchNext,
  })  : assert(topics != null),
        assert(category != null),
        assert(topicsCount != null),
        assert(isLoading != null),
        assert(onRefresh != null),
        assert(fetchNext != null),
        super(key: key);

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

const kExpandedHeight = 200.0;

class _CategoryPageState extends State<CategoryPage> {
  ScrollController _scrollController;
  double _scale = 0.0;

  @override
  void initState() {
    _scrollController = ScrollController()
      ..addListener(() {
        if (!_scrollController.hasClients) {
          _scale = 0.0;
        } else if (_scrollController.offset <=
            kExpandedHeight - kToolbarHeight) {
          _scale =
              _scrollController.offset / (kExpandedHeight - kToolbarHeight);
        } else {
          _scale = 1.0;
        }

        if (!widget.isLoading &&
            _scrollController.offset ==
                _scrollController.position.maxScrollExtent) {
          widget.fetchNext();
        }
      });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading && widget.topics.isEmpty) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: widget.onRefresh,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            SliverAppBar(
              expandedHeight: kExpandedHeight,
              floating: false,
              pinned: true,
              leading: const BackButton(color: Colors.black),
              backgroundColor: Theme.of(context).cardColor,
              actions: <Widget>[
                IconButton(
                  color: Colors.black,
                  icon: Icon(Icons.more_vert),
                  onPressed: () {},
                ),
              ],
              flexibleSpace: FlexibleTitle(
                scale: _scale,
                title: widget.category.title,
                // subtitle: Text(
                //   "${widget.topicsCount} topics",
                //   style: Theme.of(context).textTheme.caption,
                // ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index == widget.topics.length) {
                    if (widget.containsMaxPage) {
                      return null;
                    } else {
                      return _buildIndicator();
                    }
                  } else {
                    var topic = widget.topics[index];
                    return GestureDetector(
                      onTap: () => _onTap(context, topic.id),
                      child: TopicRow(topic),
                    );
                  }
                },
                childCount: widget.topics.length + 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator() {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Center(
        child: SizedBox(
          width: 24.0,
          height: 24.0,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Colors.black),
          ),
        ),
      ),
    );
  }

  _onTap(BuildContext context, int topicId) {
    Navigator.pushNamed(context, "/t", arguments: {"id": topicId});
  }
}

class CategoryPageConnector extends StatelessWidget {
  final int categoryId;

  CategoryPageConnector(this.categoryId, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ViewModel>(
      model: ViewModel(categoryId),
      onInit: (store) => store.dispatch(FetchTopicsAction(
        categoryId: categoryId,
      )),
      builder: (BuildContext context, ViewModel vm) => CategoryPage(
        isLoading: vm.isLoading,
        topics: vm.topics,
        category: vm.category,
        topicsCount: vm.topicsCount,
        onRefresh: vm.onRefresh,
        fetchNext: vm.fetchNext,
      ),
    );
  }
}

class ViewModel extends BaseModel<AppState> {
  final categoryId;

  ViewModel(this.categoryId);

  Category category;
  List<Topic> topics;
  int topicsCount;
  bool isLoading;

  Future<void> Function() onRefresh;
  VoidCallback fetchNext;

  ViewModel.build({
    @required this.topics,
    @required this.isLoading,
    @required this.categoryId,
    @required this.category,
    @required this.topicsCount,
    @required this.onRefresh,
    @required this.fetchNext,
  }) : super(equals: [isLoading, topics, category, topicsCount]);

  @override
  ViewModel fromStore() {
    return ViewModel.build(
      category: state.categories[categoryId].category,
      topics: state.categories[categoryId].topics,
      isLoading: state.isLoading,
      onRefresh: () =>
          dispatchFuture(FetchTopicsAction(categoryId: categoryId)),
      fetchNext: () => dispatch(FetchNextTopicsAction(categoryId: categoryId)),
      categoryId: categoryId,
      topicsCount: state.categories[categoryId].topicsCount,
    );
  }
}
