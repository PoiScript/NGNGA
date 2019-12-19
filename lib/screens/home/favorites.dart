import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

import 'package:ngnga/store/favorite.dart';
import 'package:ngnga/store/topic.dart';
import 'package:ngnga/widgets/refresh.dart';
import 'package:ngnga/widgets/topic_row.dart';

class FavoritesTab extends StatefulWidget {
  final FavoriteState favoriteState;

  final BuiltMap<int, TopicState> topics;

  final Future<void> Function() refreshFavorites;
  final Future<void> Function() maybeRefreshFavorites;

  const FavoritesTab({
    @required this.topics,
    @required this.favoriteState,
    @required this.refreshFavorites,
    @required this.maybeRefreshFavorites,
  });

  @override
  _FavoritesTabState createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab> {
  @override
  Widget build(BuildContext context) {
    if (!widget.favoriteState.initialized) {
      return Center(child: CircularProgressIndicator());
    }

    return EasyRefresh(
      header: RefreshHeader(context),
      onRefresh: widget.refreshFavorites,
      child: ListView.separated(
        itemBuilder: (context, index) => TopicRow(
          widget.topics[widget.favoriteState.topicIds[index]],
        ),
        separatorBuilder: (context, index) => Divider(height: 0.0),
        itemCount: widget.favoriteState.topicIds.length,
      ),
    );
  }
}
