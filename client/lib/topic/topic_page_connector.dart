import 'package:async_redux/async_redux.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:flutter/widgets.dart' hide Builder;

import 'package:business/app_state.dart';
import 'package:business/favorites/actions/add_to_favorites_action.dart';
import 'package:business/favorites/actions/remove_from_favorites_action.dart';
import 'package:business/models/post.dart';
import 'package:business/models/user.dart';
import 'package:business/topic/actions/clear_topic_action.dart';
import 'package:business/topic/actions/jump_to_page_action.dart';
import 'package:business/topic/actions/load_next_page_action.dart';
import 'package:business/topic/actions/load_previous_page_action.dart';
import 'package:business/topic/actions/refresh_first_page_action.dart';
import 'package:business/topic/actions/refresh_last_page_action.dart';
import 'package:business/topic/actions/upvote_post_action.dart';
import 'package:business/topic/actions/downvote_post_action.dart';
import 'package:business/topic/models/topic_state.dart';

import 'topic_page.dart';

part 'topic_page_connector.g.dart';

class TopicPageConnector extends StatelessWidget {
  final int topicId;
  final int pageIndex;

  TopicPageConnector({
    @required this.topicId,
    @required this.pageIndex,
  }) : assert(topicId != null && pageIndex >= 0);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      converter: (store) => _ViewModel.fromStore(store, topicId, pageIndex),
      onInit: (store) => store.dispatch(
        JumpToPageAction(topicId: topicId, pageIndex: pageIndex),
      ),
      onDispose: (store) => store.dispatch(
        ClearTopicAction(topicId: topicId),
      ),
      builder: (context, vm) => TopicPage(
        isMe: vm.isMe,
        baseUrl: vm.baseUrl,
        refreshFirst: vm.refreshFirst,
        refreshLast: vm.refreshLast,
        loadPrevious: vm.loadPrevious,
        loadNext: vm.loadNext,
        topicState: vm.topicState,
        users: vm.users,
        posts: vm.posts,
        addToFavorites: vm.addToFavorites,
        removeFromFavorites: vm.removeFromFavorites,
        changePage: vm.changePage,
        upvotePost: vm.upvotePost,
        downvotePost: vm.downvotePost,
      ),
    );
  }
}

abstract class _ViewModel implements Built<_ViewModel, _ViewModelBuilder> {
  _ViewModel._();

  factory _ViewModel([Function(_ViewModelBuilder) updates]) = _$ViewModel;

  TopicState get topicState;
  String get baseUrl;
  BuiltMap<int, User> get users;
  BuiltMap<int, Post> get posts;
  Function(int) get isMe;
  Future<void> Function() get refreshFirst;
  Future<void> Function() get refreshLast;
  Future<void> Function() get loadPrevious;
  Future<void> Function() get loadNext;
  Future<void> Function() get addToFavorites;
  Future<void> Function() get removeFromFavorites;
  Future<void> Function(int) get changePage;
  Future<void> Function(int) get upvotePost;
  Future<void> Function(int) get downvotePost;

  factory _ViewModel.fromStore(
      Store<AppState> store, int topicId, int pageIndex) {
    return _ViewModel(
      (b) => b
        ..topicState =
            store.state.topicStates[topicId]?.toBuilder() ?? TopicStateBuilder()
        ..users = store.state.users.toBuilder()
        ..posts = store.state.posts.toBuilder()
        ..baseUrl = store.state.settings.baseUrl
        ..refreshFirst = (() =>
            store.dispatchFuture(RefreshFirstPageAction(topicId: topicId)))
        ..refreshLast = (() =>
            store.dispatchFuture(RefreshLastPageAction(topicId: topicId)))
        ..loadPrevious = (() =>
            store.dispatchFuture(LoadPreviousPageAction(topicId: topicId)))
        ..loadNext =
            (() => store.dispatchFuture(LoadNextPageAction(topicId: topicId)))
        ..addToFavorites =
            (() => store.dispatchFuture(AddToFavoritesAction(topicId: topicId)))
        ..removeFromFavorites = (() =>
            store.dispatchFuture(RemoveFromFavoritesAction(topicId: topicId)))
        ..changePage = ((pageIndex) => store.dispatchFuture(
            JumpToPageAction(topicId: topicId, pageIndex: pageIndex)))
        ..isMe = ((userId) => store.state.userState.uid == userId)
        ..upvotePost = ((postId) => store
            .dispatchFuture(UpvotePostAction(topicId: topicId, postId: postId)))
        ..downvotePost = ((postId) => store.dispatchFuture(
            DownvotePostAction(topicId: topicId, postId: postId))),
    );
  }
}
