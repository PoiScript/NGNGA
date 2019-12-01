import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ngnga/models/post.dart';
import 'package:ngnga/models/topic.dart';
import 'package:ngnga/models/user.dart';
import 'package:ngnga/screens/editor/editor.dart';
import 'package:ngnga/store/actions.dart';
import 'package:ngnga/store/state.dart';
import 'package:ngnga/widgets/title_colorize.dart';

import 'popup_menu.dart';
import 'post_row.dart';
import 'update_indicator.dart';

final DateFormat dateFormatter = DateFormat('HH:mm:ss');

class TopicPage extends StatefulWidget {
  final Topic topic;
  final List<PostItem> posts;
  final List<User> users;
  final bool reachMaxPage;

  final Event<String> snackBarEvt;

  final Future<void> Function() onLoad;
  final Future<void> Function() onRefresh;

  TopicPage({
    @required this.topic,
    @required this.posts,
    @required this.users,
    @required this.reachMaxPage,
    @required this.snackBarEvt,
    @required this.onRefresh,
    @required this.onLoad,
  })  : assert(topic != null),
        assert(posts != null),
        assert(users != null),
        assert(reachMaxPage != null),
        assert(snackBarEvt != null),
        assert(onRefresh != null),
        assert(onLoad != null);

  @override
  _TopicPageState createState() => _TopicPageState();
}

class _TopicPageState extends State<TopicPage>
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

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _animationController.dispose();
  }

  @override
  void didUpdateWidget(TopicPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _consumeEvents();
  }

  _consumeEvents() {
    String message = widget.snackBarEvt.consume();
    if (message != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 3),
          ));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.posts.isEmpty) {
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
          builder: _buildContent,
        ),
      ),
      floatingActionButton: SlideTransition(
        position: _offset,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/e', arguments: {
              'action': actionReply,
              'topicId': widget.topic.id,
            });
          },
          child: Icon(Icons.add),
          backgroundColor: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ScrollPhysics physics,
    Widget header,
    Widget footer,
  ) {
    List<Widget> slivers = [
      SliverAppBar(
        backgroundColor: Theme.of(context).cardColor,
        title: TitleColorize(
          widget.topic,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          displayLabel: false,
        ),
        floating: true,
        titleSpacing: 0.0,
        leading: BackButton(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
        actions: <Widget>[
          PopupMenuConnector(topicId: widget.topic.id),
        ],
      ),
      header,
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final int itemIndex = index ~/ 2;
            if (index.isOdd) {
              return PostRowConnector(
                user: widget.users[itemIndex],
                post: widget.posts[itemIndex],
              );
            }
            return Divider(height: 0.0);
          },
          semanticIndexCallback: (widget, index) {
            if (index.isOdd) {
              return index ~/ 2;
            }
            // ignore: avoid_returning_null
            return null;
          },
          childCount: widget.posts.isEmpty ? 0 : (widget.posts.length * 2 + 1),
        ),
      ),
      if (widget.reachMaxPage)
        SliverToBoxAdapter(
          child: UpdateIndicatorConnector(topicId: widget.topic.id),
        )
      else
        footer
    ];

    return CustomScrollView(
      controller: _scrollController,
      physics: physics,
      semanticChildCount: widget.posts.length,
      slivers: slivers,
    );
  }
}

class TopicPageConnector extends StatelessWidget {
  final int topicId;
  final int pageIndex;

  TopicPageConnector({
    @required this.topicId,
    @required this.pageIndex,
  }) : assert(topicId != null && pageIndex >= 0);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ViewModel>(
      model: ViewModel(topicId),
      onInit: (store) => store.dispatch(FetchPostsAction(
        topicId: topicId,
        pageIndex: pageIndex,
      )),
      builder: (context, vm) => TopicPage(
        topic: vm.topic,
        posts: vm.posts,
        users: vm.users,
        reachMaxPage: vm.reachMaxPage,
        snackBarEvt: vm.snackBarEvt,
        onRefresh: vm.onRefresh,
        onLoad: vm.onLoad,
      ),
    );
  }
}

class ViewModel extends BaseModel<AppState> {
  final int topicId;

  Topic topic;
  List<PostItem> posts;
  List<User> users;
  bool reachMaxPage;

  Event<String> snackBarEvt;

  Future<void> Function() onRefresh;
  Future<void> Function() onLoad;

  ViewModel(this.topicId);

  ViewModel.build({
    @required this.topicId,
    @required this.topic,
    @required this.posts,
    @required this.users,
    @required this.reachMaxPage,
    @required this.snackBarEvt,
    @required this.onRefresh,
    @required this.onLoad,
  }) : super(equals: [snackBarEvt, reachMaxPage, posts, users, topic]);

  @override
  ViewModel fromStore() {
    final topicState = state.topicStates[topicId];

    List<User> users = [];

    for (var post in topicState.posts) {
      users.add(state.users[post.inner.userId]);
    }

    return ViewModel.build(
      topicId: topicId,
      posts: topicState.posts,
      users: users,
      reachMaxPage: topicState.lastPage == topicState.maxPage,
      topic: state.topics[topicId],
      snackBarEvt: state.topicSnackBarEvt,
      onRefresh: () => topicState.firstPage == 0
          ? dispatchFuture(FetchPostsAction(topicId: topicId, pageIndex: 0))
          : dispatchFuture(FetchPreviousPostsAction(topicId)),
      onLoad: () => dispatchFuture(FetchNextPostsAction(topicId)),
    );
  }
}
