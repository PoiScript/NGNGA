import 'dart:async';

import 'package:async_redux/async_redux.dart';

import 'package:ngnga/utils/requests.dart';

import 'is_loading.dart';
import '../state.dart';

class FetchFavorTopicsAction extends ReduxAction<AppState> {
  @override
  Future<AppState> reduce() async {
    final response = await fetchFavorTopics(
      cookies: state.cookies,
    );

    return state.copy(
      favorTopics: response.topics,
    );
  }

  void before() => dispatch(IsLoadingAction(true));

  void after() => dispatch(IsLoadingAction(false));
}
