import 'package:async_redux/async_redux.dart';
import 'package:built_value/built_value.dart';
import 'package:flutter/material.dart' hide Builder;

import 'package:ngnga/localizations.dart';
import 'package:ngnga/models/category.dart';
import 'package:ngnga/models/topic.dart';
import 'package:ngnga/store/actions.dart';
import 'package:ngnga/store/favorite.dart';
import 'package:ngnga/store/inbox.dart';
import 'package:ngnga/store/state.dart';

import 'explore.dart';
import 'favorites.dart';
import 'inbox.dart';
import 'popup_menu.dart';

part 'home.g.dart';

class HomePage extends StatefulWidget {
  final FavoriteState favoriteState;
  final Map<int, Topic> topics;
  final Future<void> Function() fetchFavorites;
  final Future<void> Function() refreshFavorites;
  final List<Category> pinned;
  final InboxState inboxState;
  final Future<void> Function() fetchInbox;
  final Future<void> Function() refreshInbox;

  const HomePage({
    Key key,
    this.favoriteState,
    this.topics,
    this.fetchFavorites,
    this.refreshFavorites,
    this.pinned,
    this.inboxState,
    this.fetchInbox,
    this.refreshInbox,
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
        ),
        1: ExploreTab(pinned: widget.pinned),
        2: InboxTab(
          inboxState: widget.inboxState,
          refreshInbox: widget.refreshInbox,
        )
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
        onTap: (index) {
          setState(() => _selectedIndex = index);
          if (index == 0) {
            widget.fetchFavorites();
          } else if (index == 2) {
            widget.fetchInbox();
          }
        },
      ),
    );
  }
}

class HomePageConnector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ViewModel>(
      converter: (store) => ViewModel.fromStore(store),
      onInit: (store) => store.dispatchFuture(FetchFavoritesAction()),
      builder: (context, vm) => HomePage(
        favoriteState: vm.favoriteState,
        topics: vm.topics,
        fetchFavorites: vm.fetchFavorites,
        refreshFavorites: vm.refreshFavorites,
        pinned: vm.pinned,
        inboxState: vm.inboxState,
        fetchInbox: vm.fetchInbox,
        refreshInbox: vm.refreshInbox,
      ),
    );
  }
}

abstract class ViewModel implements Built<ViewModel, ViewModelBuilder> {
  ViewModel._();

  factory ViewModel([Function(ViewModelBuilder) updates]) = _$ViewModel;

  FavoriteState get favoriteState;
  Map<int, Topic> get topics;
  Future<void> Function() get fetchFavorites;
  Future<void> Function() get refreshFavorites;

  List<Category> get pinned;

  InboxState get inboxState;
  Future<void> Function() get fetchInbox;
  Future<void> Function() get refreshInbox;

  factory ViewModel.fromStore(Store<AppState> store) => ViewModel((b) => b
    ..favoriteState =
        store.state.favoriteState.toBuilder() ?? FavoriteStateBuilder()
    ..topics = store.state.topics.toMap()
    ..fetchFavorites = (() => store.dispatchFuture(FetchFavoritesAction()))
    ..refreshFavorites = (() => store.dispatchFuture(RefreshFavoritesAction()))
    ..pinned = store.state.pinned.toList()
    ..inboxState = store.state.inboxState.toBuilder()
    ..refreshInbox = (() => store.dispatchFuture(RefreshNotificationsAction()))
    ..fetchInbox = (() => store.dispatchFuture(FetchNotificationsAction())));
}
