import 'dart:async';

import 'package:async_redux/async_redux.dart';

import 'package:ngnga/utils/requests.dart';

import 'is_loading.dart';
import '../state.dart';

class FetchFavoritesAction extends ReduxAction<AppState> {
  @override
  Future<AppState> reduce() async {
    final response = await fetchFavorTopics(
      client: state.client,
      cookie: state.cookie,
      baseUrl: state.baseUrl,
      page: 0,
    );

    return state.copy(
      favorites: state.favorites.copy(
        favoriteCount: response.favoriteCount,
        favorites: response.favorites,
      ),
    );
  }

  void before() => dispatch(IsLoadingAction(true));

  void after() => dispatch(IsLoadingAction(false));
}
