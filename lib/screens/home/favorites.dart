import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

import 'package:ngnga/models/favorite.dart';
import 'package:ngnga/store/actions.dart';
import 'package:ngnga/store/state.dart';
import 'package:ngnga/widgets/topic_row.dart';

class Favorites extends StatelessWidget {
  final List<Favorite> favorites;
  final bool isLoading;
  final bool isLogged;

  final Future<void> Function() onRefresh;

  Favorites({
    @required this.favorites,
    @required this.isLogged,
    @required this.isLoading,
    @required this.onRefresh,
  })  : assert(isLogged != null),
        assert(isLoading != null),
        assert(favorites != null),
        assert(onRefresh != null);

  @override
  Widget build(BuildContext context) {
    return isLogged ? _favoritesList(context) : _emptyScreen(context);
  }

  Widget _emptyScreen(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[],
    );
  }

  Widget _favoritesList(BuildContext context) {
    return EasyRefresh(
      firstRefresh: favorites.isEmpty,
      header: ClassicalHeader(),
      onRefresh: onRefresh,
      child: ListView.separated(
        itemBuilder: (context, index) => TopicRowConnector(
          favorites[index].topic,
        ),
        separatorBuilder: (context, index) => Divider(height: 0.0),
        itemCount: favorites.length,
      ),
    );
  }
}

class FavoritesConnector extends StatelessWidget {
  FavoritesConnector();

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ViewModel>(
      model: ViewModel(),
      // onInit: (store) => store.dispatch(FetchFavoritesAction()),
      builder: (context, vm) => Favorites(
        favorites: vm.favorites,
        isLogged: vm.isLogged,
        isLoading: vm.isLoading,
        onRefresh: vm.onRefresh,
      ),
    );
  }
}

class ViewModel extends BaseModel<AppState> {
  List<Favorite> favorites;
  bool isLoading;
  bool isLogged;

  Future<void> Function() onRefresh;

  ViewModel();

  ViewModel.build({
    @required this.favorites,
    @required this.isLogged,
    @required this.isLoading,
    @required this.onRefresh,
  }) : super(equals: [favorites, isLogged, isLoading]);

  @override
  ViewModel fromStore() {
    return ViewModel.build(
      favorites: state.favorites.favorites,
      isLoading: state.isLoading,
      isLogged: state.cookies.isNotEmpty,
      onRefresh: () => dispatchFuture(FetchFavoritesAction()),
    );
  }
}
