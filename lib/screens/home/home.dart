import 'package:flutter/material.dart';
import 'package:ngnga/localizations.dart';

import 'explore.dart';
import 'favorites.dart';
import 'inbox.dart';
import 'popup_menu.dart';

class HomePage extends StatefulWidget {
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _appBarTitle(_selectedIndex),
          style: Theme.of(context).textTheme.body2,
        ),
        actions: <Widget>[
          PopupMenu(),
        ],
        backgroundColor: Theme.of(context).cardColor,
      ),
      body: _content(_selectedIndex),
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

  String _appBarTitle(int index) {
    switch (index) {
      case 0:
        return AppLocalizations.of(context).explore;
      case 1:
        return AppLocalizations.of(context).favorites;
      case 2:
        return AppLocalizations.of(context).inbox;
    }
    return null;
  }

  Widget _content(int index) {
    switch (index) {
      case 0:
        return FavoritesConnector();
      case 1:
        return ExploreConnector();
      case 2:
        return InboxConnector();
    }
    return null;
  }
}
