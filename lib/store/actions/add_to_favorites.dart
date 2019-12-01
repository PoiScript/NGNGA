import 'package:async_redux/async_redux.dart';
import 'package:flutter/widgets.dart';

import 'package:ngnga/store/actions.dart';
import 'package:ngnga/store/state.dart';
import 'package:ngnga/utils/requests.dart';

class AddToFavoritesAction extends ReduxAction<AppState> {
  final int topicId;

  AddToFavoritesAction({
    @required this.topicId,
  });

  @override
  Future<AppState> reduce() async {
    await addToFavorites(
      client: state.client,
      cookie: state.userState.cookie,
      baseUrl: state.settings.baseUrl,
      topicId: topicId,
    );

    return null;
  }

  void after() => dispatch(FetchFavoritesAction());
}
