import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:ngnga/models/topic.dart';

import 'package:ngnga/store/state.dart';
import 'package:ngnga/store/topic.dart';

class MaybeRefreshFavoritesAction extends ReduxAction<AppState> {
  @override
  Future<AppState> reduce() async {
    if (!state.favoriteState.initialized) {
      await dispatchFuture(RefreshFavoritesAction());
    }

    return null;
  }
}

class RefreshFavoritesAction extends ReduxAction<AppState> {
  @override
  Future<AppState> reduce() async {
    final res = await state.repository.fetchFavorTopics(page: 0);

    List<int> favoriteIds = res.topics.map((t) => t.id).toList();

    return state.rebuild(
      (b) => b
        ..favoriteState.initialized = true
        ..favoriteState.topicsCount = res.topicsCount
        ..favoriteState.topicIds = ListBuilder(res.topics.map((t) => t.id))
        ..favoriteState.maxPage = res.maxPage
        ..favoriteState.lastPage = 0
        ..topicStates.update((b) {
          for (Topic topic in res.topics) {
            b.updateValue(topic.id, (s) => s.rebuild((b) => b.topic = topic),
                ifAbsent: () => TopicState((b) => b.topic = topic));
          }
        })
        ..topicStates.updateAllValues((id, topicsState) => topicsState
            .rebuild((b) => b.isFavorited = favoriteIds.contains(id))),
    );
  }
}

class AddToFavoritesAction extends ReduxAction<AppState> {
  final int topicId;

  AddToFavoritesAction({
    @required this.topicId,
  });

  @override
  Future<AppState> reduce() async {
    await state.repository.addToFavorites(topicId: topicId);

    return null;
  }

  void after() => dispatch(RefreshFavoritesAction());
}

class RemoveFromFavoritesAction extends ReduxAction<AppState> {
  final int topicId;

  RemoveFromFavoritesAction({
    @required this.topicId,
  });

  @override
  Future<AppState> reduce() async {
    await state.repository.removeFromFavorites(topicId: topicId);

    return null;
  }

  void after() => dispatch(RefreshFavoritesAction());
}
