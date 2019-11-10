import 'dart:collection';

import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widgets/flutter_widgets.dart';

import './post_row.dart';
import '../../models/topic.dart';
import '../../models/post.dart';
import '../../store/state.dart';
import '../../store/fetch_posts.dart';

class TopicPage extends StatefulWidget {
  final ListQueue<Post> posts;
  final Topic topic;
  final bool isLoading;

  final VoidCallback fetchPrevious;
  final VoidCallback fetchNext;

  bool get containsMinPage => (posts.first.index ~/ 20) == 0;
  bool get containsMaxPage =>
      (posts.last.index ~/ 20) == (topic.postsCount ~/ 20);

  TopicPage({
    @required this.topic,
    @required this.posts,
    @required this.isLoading,
    @required this.fetchNext,
    @required this.fetchPrevious,
  })  : assert(isLoading != null),
        assert(fetchNext != null),
        assert(fetchPrevious != null);

  @override
  _TopicPageState createState() => _TopicPageState();
}

class _TopicPageState extends State<TopicPage> {
  ItemPositionsListener _itemPositionsListener;

  @override
  void initState() {
    _itemPositionsListener = ItemPositionsListener.create()
      ..itemPositions.addListener(() {
        var value = _itemPositionsListener.itemPositions.value;
        if (!widget.isLoading) {
          // print("${value.last.index} == ${widget.posts.length}");
          if (!widget.containsMinPage && value.first.index == 0) {
            widget.fetchPrevious();
          } else if (!widget.containsMaxPage &&
              value.last.index == widget.posts.length) {
            widget.fetchNext();
          }
        }
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading && widget.topic == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          widget.topic.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.subhead,
        ),
        leading: const BackButton(color: Colors.black),
        actions: <Widget>[
          IconButton(
            color: Colors.black,
            icon: Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
        titleSpacing: 0.0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: ScrollablePositionedList.builder(
          initialScrollIndex: 1,
          itemCount: widget.posts.length + 2,
          itemPositionsListener: _itemPositionsListener,
          itemBuilder: (context, index) {
            if (index == 0) {
              if (widget.containsMinPage) {
                return null;
              } else {
                return _buildIndicator();
              }
            } else if (index == widget.posts.length + 1) {
              if (widget.containsMaxPage) {
                return null;
              } else {
                return _buildIndicator();
              }
            } else {
              return PostRow(widget.posts.elementAt(index - 1));
            }
          },
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
}

class TopicPageConnector extends StatelessWidget {
  final int topicId;
  final int pageIndex;

  TopicPageConnector(this.topicId, {this.pageIndex = 1})
      : assert(pageIndex != null && pageIndex > 0);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ViewModel>(
      model: ViewModel(topicId),
      onInit: (store) => store.dispatch(FetchPostsAction(
        topicId: topicId,
        pageIndex: pageIndex,
      )),
      builder: (BuildContext context, ViewModel vm) => TopicPage(
        posts: vm.posts,
        topic: vm.topic,
        isLoading: vm.isLoading,
        fetchNext: vm.fetchNext,
        fetchPrevious: vm.fetchPrevious,
      ),
    );
  }
}

class ViewModel extends BaseModel<AppState> {
  final topicId;

  Topic topic;
  ListQueue<Post> posts;

  bool isLoading;

  VoidCallback fetchPrevious;
  VoidCallback fetchNext;

  ViewModel(this.topicId);

  ViewModel.build({
    @required this.posts,
    @required this.isLoading,
    @required this.topicId,
    @required this.topic,
    @required this.fetchPrevious,
    @required this.fetchNext,
  }) : super(equals: [isLoading, posts, topic]);

  @override
  ViewModel fromStore() {
    var topic = state.topics[topicId];
    return ViewModel.build(
      posts: topic?.posts,
      topic: topic?.topic,
      isLoading: state.isLoading,
      topicId: topicId,
      fetchPrevious: () => dispatch(FetchPreviousPostsAction(topicId)),
      fetchNext: () => dispatch(FetchNextPostsAction(topicId)),
    );
  }
}
