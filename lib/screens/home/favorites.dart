import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

import 'package:ngnga/models/favorite.dart';
import 'package:ngnga/store/actions.dart';
import 'package:ngnga/store/state.dart';
import 'package:ngnga/widgets/topic_row.dart';

import 'popup_menu.dart';

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

  Widget _appBar(BuildContext context) {
    return SliverAppBar(
      title: Text(
        "Favorites",
        style: Theme.of(context).textTheme.body2,
      ),
      actions: <Widget>[
        PopupMenu(),
      ],
      backgroundColor: Colors.white,
      floating: true,
    );
  }

  Widget _emptyScreen(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        _appBar(context),
        SliverToBoxAdapter(
          child: Container(),
        ),
      ],
    );
  }

  Widget _favoritesList(BuildContext context) {
    return EasyRefresh.builder(
        firstRefresh: favorites.isEmpty,
        header: ClassicalHeader(),
        onRefresh: onRefresh,
        builder: (context, physics, header, footer) => CustomScrollView(
              physics: physics,
              slivers: <Widget>[
                _appBar(context),
                header,
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final int itemIndex = index ~/ 2;
                      if (index.isEven) {
                        return TopicRowConnector(
                          favorites[itemIndex].topic,
                        );
                      }
                      return Divider(height: 0);
                    },
                    semanticIndexCallback: (widget, index) {
                      if (index.isEven) {
                        return index ~/ 2;
                      }
                      return null;
                    },
                    childCount:
                        favorites.length > 0 ? (favorites.length * 2 - 1) : 0,
                  ),
                ),
              ],
            ));
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
