import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:ngnga/models/topic.dart';

import 'package:ngnga/store/actions.dart';
import 'package:ngnga/store/favorite.dart';
import 'package:ngnga/store/state.dart';
import 'package:ngnga/widgets/refresh.dart';
import 'package:ngnga/widgets/topic_row.dart';

class Favorites extends StatelessWidget {
  final FavoriteState favoriteState;

  final Map<int, Topic> topics;

  final Future<void> Function() onRefresh;

  Favorites({
    @required this.topics,
    @required this.favoriteState,
    @required this.onRefresh,
  })  : assert(favoriteState != null),
        assert(onRefresh != null);

  @override
  Widget build(BuildContext context) {
    if (favoriteState is FavoriteUninitialized) {
      return Center(child: CircularProgressIndicator());
    }

    if (favoriteState is FavoriteLoaded) {
      return _buildList(context, favoriteState);
    }

    return null;
  }

  Widget _buildList(BuildContext context, FavoriteLoaded state) {
    return EasyRefresh(
      header: RefreshHeader(context),
      onRefresh: onRefresh,
      child: ListView.separated(
        itemBuilder: (context, index) =>
            TopicRow(topic: topics[state.topicIds[index]]),
        separatorBuilder: (context, index) => Divider(height: 0.0),
        itemCount: state.topicIds.length,
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
        topics: vm.topics,
        favoriteState: vm.favoriteState,
        onRefresh: vm.onRefresh,
      ),
    );
  }
}

class ViewModel extends BaseModel<AppState> {
  FavoriteState favoriteState;

  Map<int, Topic> topics;

  Future<void> Function() onRefresh;

  ViewModel();

  ViewModel.build({
    @required this.topics,
    @required this.favoriteState,
    @required this.onRefresh,
  }) : super(equals: [topics, favoriteState]);

  @override
  ViewModel fromStore() {
    return ViewModel.build(
      topics: state.topics,
      favoriteState: state.favoriteState,
      onRefresh: () => dispatchFuture(RefreshFavoritesAction()),
    );
  }
}
