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

  final Future<void> Function() onRefresh;

  Favorites({
    @required this.favorites,
    @required this.isLoading,
    @required this.onRefresh,
  })  : assert(isLoading != null),
        assert(favorites != null),
        assert(onRefresh != null);

  @override
  Widget build(BuildContext context) {
    return EasyRefresh.builder(
      header: ClassicalHeader(),
      onRefresh: onRefresh,
      builder: (context, physics, header, footer) => CustomScrollView(
        physics: physics,
        slivers: <Widget>[
          SliverAppBar(
            title: Text(
              "Favorites",
              style: Theme.of(context).textTheme.body2,
            ),
            actions: <Widget>[
              PopupMenu(),
            ],
            backgroundColor: Colors.white,
            floating: true,
          ),
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
              childCount: favorites.length > 0 ? (favorites.length * 2 - 1) : 0,
            ),
          ),
        ],
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
      onInit: (store) => store.dispatch(FetchFavoritesAction()),
      builder: (context, vm) => Favorites(
        favorites: vm.favorites,
        isLoading: vm.isLoading,
        onRefresh: vm.onRefresh,
      ),
    );
  }
}

class ViewModel extends BaseModel<AppState> {
  List<Favorite> favorites;
  bool isLoading;

  Future<void> Function() onRefresh;

  ViewModel();

  ViewModel.build({
    @required this.favorites,
    @required this.isLoading,
    @required this.onRefresh,
  }) : super(equals: [favorites, isLoading]);

  @override
  ViewModel fromStore() {
    return ViewModel.build(
      favorites: state.favorites.favorites,
      isLoading: state.isLoading,
      onRefresh: () => dispatchFuture(FetchFavoritesAction()),
    );
  }
}
