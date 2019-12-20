import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';

import 'package:business/favorites/models/favorite_state.dart';
import 'package:business/inbox/models/inbox_state.dart';
import 'package:business/models/category.dart';
import 'package:business/topic/models/topic_state.dart';

import 'package:ngnga/localizations.dart';

import 'explore_tab.dart';
import 'favorites_tab.dart';
import 'inbox_tab.dart';
import 'popup_menu.dart';

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
