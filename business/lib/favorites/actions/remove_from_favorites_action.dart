import 'package:async_redux/async_redux.dart';
import 'package:flutter/foundation.dart';

import '../../app_state.dart';
import 'refresh_favorites_action.dart';

class RemoveFromFavoritesAction extends ReduxAction<AppState> {
  final int topicId;

  RemoveFromFavoritesAction({
    @required this.topicId,
  });

  @override
  Future<AppState> reduce() async {
    await state.repository.removeFromFavorites(
      cookie: state.userState.cookie,
      baseUrl: state.settings.baseUrl,
      topicId: topicId,
    );

    return null;
  }

  void after() => dispatch(RefreshFavoritesAction());
}
