import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:ngnga/models/topic.dart';

import 'package:ngnga/store/favorite.dart';
import 'package:ngnga/widgets/refresh.dart';
import 'package:ngnga/widgets/topic_row.dart';

class FavoritesTab extends StatelessWidget {
  final FavoriteState favoriteState;

  final Map<int, Topic> topics;

  final Future<void> Function() refreshFavorites;

  FavoritesTab({
    @required this.topics,
    @required this.favoriteState,
    @required this.refreshFavorites,
  })  : assert(favoriteState != null),
        assert(refreshFavorites != null);

  @override
  Widget build(BuildContext context) {
    if (!favoriteState.initialized) {
      return Center(child: CircularProgressIndicator());
    }

    return EasyRefresh(
      header: RefreshHeader(context),
      onRefresh: refreshFavorites,
      child: ListView.separated(
        itemBuilder: (context, index) =>
            TopicRow(topic: topics[favoriteState.topicIds[index]]),
        separatorBuilder: (context, index) => Divider(height: 0.0),
        itemCount: favoriteState.topicIds.length,
      ),
    );
  }
}
