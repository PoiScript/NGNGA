import 'package:async_redux/async_redux.dart';
import 'package:flutter/widgets.dart';

import 'package:ngnga/store/actions.dart';
import 'package:ngnga/store/state.dart';
import 'package:ngnga/store/topic.dart';

class RemoveFromFavoritesAction extends ReduxAction<AppState> {
  final int topicId;

  RemoveFromFavoritesAction({
    @required this.topicId,
  });

  @override
  Future<AppState> reduce() async {
    await state.repository.removeFromFavorites(
      topicId: topicId,
    );

    return state.copy(
      topicStates: state.topicStates
        ..update(
          topicId,
          (topicState) => topicState is TopicLoaded
              ? topicState.copyWith(isFavorited: false)
              : topicState,
        ),
    );
  }

  void after() => dispatch(FetchFavoritesAction());
}
