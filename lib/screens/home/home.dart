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
          _selectedIndex == 0
              ? AppLocalizations.of(context).favorites
              : _selectedIndex == 1
                  ? AppLocalizations.of(context).explore
                  : AppLocalizations.of(context).inbox,
          style: Theme.of(context).textTheme.body2,
        ),
        actions: <Widget>[
          PopupMenu(),
        ],
        backgroundColor: Theme.of(context).cardColor,
      ),
      body: _selectedIndex == 0
          ? FavoritesConnector()
          : _selectedIndex == 1 ? ExploreConnector() : InboxConnector(),
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
