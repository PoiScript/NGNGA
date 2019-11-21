import 'package:flutter/material.dart';

import 'favorites.dart';
import 'categories.dart';
import 'inbox.dart';

class HomePage extends StatefulWidget {
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedIndex == 0
          ? FavoritesConnector()
          : _selectedIndex == 1 ? CategoriesConnector() : Inbox(),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            title: Text(''),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_day),
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
