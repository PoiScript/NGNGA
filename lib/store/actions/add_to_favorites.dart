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
      topicId: topicId,
      cookies: state.cookies,
    );

    return state;
  }

  void after() => dispatch(FetchFavoritesAction());
}
