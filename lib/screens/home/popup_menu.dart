import 'package:flutter/material.dart';

enum Choice {
  JumpToSettingsPage,
}

class PopupMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Choice>(
      icon: const Icon(
        Icons.more_vert,
        color: Colors.black,
      ),
      itemBuilder: (context) => [
        PopupMenuItem<Choice>(
          value: Choice.JumpToSettingsPage,
          child: Text(
            "Jump to SettingsPage",
            style: Theme.of(context).textTheme.body1,
          ),
        ),
      ],
      onSelected: (choice) {
        switch (choice) {
          case Choice.JumpToSettingsPage:
            Navigator.pushNamed(context, "/s");
        }
      },
    );
  }
}
