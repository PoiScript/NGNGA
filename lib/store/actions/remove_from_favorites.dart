import 'package:async_redux/async_redux.dart';
import 'package:flutter/widgets.dart';

import 'package:ngnga/store/actions.dart';
import 'package:ngnga/store/state.dart';
import 'package:ngnga/utils/requests.dart';

class RemoveFromFavoritesAction extends ReduxAction<AppState> {
  final int topicId;

  RemoveFromFavoritesAction({
    @required this.topicId,
  });

  @override
  Future<AppState> reduce() async {
    await removeFromFavorites(
      client: state.client,
      topicId: topicId,
      cookie: state.userState.cookie,
      baseUrl: state.settings.baseUrl,
    );

    return state.copy(
      topicSnackBarEvt: Event('成功移出收藏'),
    );
  }

  void after() => dispatch(FetchFavoritesAction());
}
