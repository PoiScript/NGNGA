import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

import 'package:ngnga/models/topic.dart';
import 'package:ngnga/store/actions.dart';
import 'package:ngnga/store/state.dart';
import 'package:ngnga/widgets/topic_row.dart';

class Favorites extends StatelessWidget {
  final List<Topic> topics;
  final bool isLogged;

  final Future<void> Function() onRefresh;

  Favorites({
    @required this.topics,
    @required this.isLogged,
    @required this.onRefresh,
  })  : assert(isLogged != null),
        assert(topics != null),
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
      firstRefresh: topics.isEmpty,
      header: ClassicalHeader(),
      onRefresh: onRefresh,
      child: ListView.separated(
        itemBuilder: (context, index) => TopicRowConnector(
          topics[index],
        ),
        separatorBuilder: (context, index) => Divider(height: 0.0),
        itemCount: topics.length,
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
      builder: (context, vm) => Favorites(
        topics: vm.topics,
        isLogged: vm.isLogged,
        onRefresh: vm.onRefresh,
      ),
    );
  }
}

class ViewModel extends BaseModel<AppState> {
  List<Topic> topics;
  bool isLogged;

  Future<void> Function() onRefresh;

  ViewModel();

  ViewModel.build({
    @required this.topics,
    @required this.isLogged,
    @required this.onRefresh,
  }) : super(equals: [topics, isLogged]);

  @override
  ViewModel fromStore() {
    return ViewModel.build(
      topics:
          state.favoriteState.topicIds.map((id) => state.topics[id]).toList(),
      isLogged: state.settings.cid != null,
      onRefresh: () => dispatchFuture(FetchFavoritesAction()),
    );
  }
}
