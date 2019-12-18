import 'package:async_redux/async_redux.dart';
import 'package:flutter/widgets.dart';

import 'package:ngnga/store/actions.dart';
import 'package:ngnga/store/state.dart';

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

    return state.rebuild(
      (b) => b.topicStates.updateValue(
        topicId,
        (topicState) => topicState.rebuild((b) => b.isFavorited = false),
      ),
    );
  }

  void after() => dispatch(FetchFavoritesAction());
}
