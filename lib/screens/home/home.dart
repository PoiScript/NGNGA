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
  final PageController _pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );

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
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: <Widget>[
          FavoritesConnector(),
          ExploreConnector(),
          InboxConnector(),
        ],
      ),
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
        onTap: _onTap,
      ),
    );
  }

  _onPageChanged(int index) {
    setState(() => _selectedIndex = index);
  }

  _onTap(int index) {
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }
}
