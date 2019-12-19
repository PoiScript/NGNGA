import 'package:async_redux/async_redux.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:flutter/material.dart' hide Builder;

import 'package:ngnga/localizations.dart';
import 'package:ngnga/models/category.dart';
import 'package:ngnga/store/actions/favorites.dart';
import 'package:ngnga/store/actions/inbox.dart';
import 'package:ngnga/store/favorite.dart';
import 'package:ngnga/store/inbox.dart';
import 'package:ngnga/store/state.dart';
import 'package:ngnga/store/topic.dart';

import 'explore.dart';
import 'favorites.dart';
import 'inbox.dart';
import 'popup_menu.dart';

part 'home.g.dart';

class HomePage extends StatefulWidget {
  final BuiltMap<int, TopicState> topics;

  final FavoriteState favoriteState;
  final Future<void> Function() refreshFavorites;
  final Future<void> Function() maybeRefreshFavorites;

  final BuiltList<Category> pinned;

  final InboxState inboxState;
  final Future<void> Function() refreshInbox;
  final Future<void> Function() maybeRefreshInbox;

  const HomePage({
    Key key,
    this.favoriteState,
    this.topics,
    this.refreshFavorites,
    this.maybeRefreshFavorites,
    this.pinned,
    this.inboxState,
    this.refreshInbox,
    this.maybeRefreshInbox,
  }) : super(key: key);

  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          {
            0: AppLocalizations.of(context).favorites,
            1: AppLocalizations.of(context).explore,
            2: AppLocalizations.of(context).inbox,
          }[_selectedIndex],
          style: Theme.of(context).textTheme.body2,
        ),
        actions: <Widget>[
          PopupMenu(),
        ],
        backgroundColor: Theme.of(context).cardColor,
      ),
      body: {
        0: FavoritesTab(
          topics: widget.topics,
          favoriteState: widget.favoriteState,
          refreshFavorites: widget.refreshFavorites,
          maybeRefreshFavorites: widget.maybeRefreshFavorites,
        ),
        1: ExploreTab(pinned: widget.pinned),
        2: InboxTab(
          inboxState: widget.inboxState,
          refreshInbox: widget.refreshInbox,
          maybeRefreshInbox: widget.maybeRefreshInbox,
        ),
      }[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            title: Text(''),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            title: Text(''),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inbox),
            title: Text(''),
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}

class HomePageConnector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ViewModel>(
      converter: (store) => ViewModel.fromStore(store),
      onInit: (store) => store.dispatchFuture(MaybeRefreshFavoritesAction()),
      builder: (context, vm) => HomePage(
        favoriteState: vm.favoriteState,
        topics: vm.topics,
        refreshFavorites: vm.refreshFavorites,
        maybeRefreshFavorites: vm.maybeRefreshFavorites,
        pinned: vm.pinned,
        inboxState: vm.inboxState,
        refreshInbox: vm.refreshInbox,
        maybeRefreshInbox: vm.maybeRefreshInbox,
      ),
    );
  }
}

abstract class ViewModel implements Built<ViewModel, ViewModelBuilder> {
  ViewModel._();

  factory ViewModel([Function(ViewModelBuilder) updates]) = _$ViewModel;

  FavoriteState get favoriteState;
  BuiltMap<int, TopicState> get topics;

  Future<void> Function() get refreshFavorites;
  Future<void> Function() get maybeRefreshFavorites;

  BuiltList<Category> get pinned;

  InboxState get inboxState;
  Future<void> Function() get refreshInbox;
  Future<void> Function() get maybeRefreshInbox;

  factory ViewModel.fromStore(Store<AppState> store) => ViewModel((b) => b
    ..favoriteState =
        store.state.favoriteState.toBuilder() ?? FavoriteStateBuilder()
    ..topics = store.state.topicStates.toBuilder()
    ..refreshFavorites = (() => store.dispatchFuture(RefreshFavoritesAction()))
    ..maybeRefreshFavorites =
        (() => store.dispatchFuture(MaybeRefreshFavoritesAction()))
    ..pinned = store.state.pinned.toBuilder()
    ..inboxState = store.state.inboxState.toBuilder()
    ..refreshInbox = (() => store.dispatchFuture(RefreshNotificationsAction()))
    ..maybeRefreshInbox =
        (() => store.dispatchFuture(MaybeRefreshNotificationsAction())));
}
