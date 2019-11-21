import 'package:flutter/material.dart';

import 'popup_menu.dart';

class Inbox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          automaticallyImplyLeading: false,
          title: Text(
            "Inbox",
            style: Theme.of(context).textTheme.body2,
          ),
          actions: <Widget>[
            PopupMenu(),
          ],
          backgroundColor: Colors.white,
          pinned: true,
        ),
      ],
    );
  }
}
