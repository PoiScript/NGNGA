import 'package:flutter/material.dart';
import 'package:ngnga/screens/editor/editor.dart';

enum Choice {
  JumpToSettingsPage,
  JumpToEditorPage,
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
        PopupMenuItem<Choice>(
          value: Choice.JumpToEditorPage,
          child: Text(
            "Jump to EditorPage",
            style: Theme.of(context).textTheme.body1,
          ),
        ),
      ],
      onSelected: (choice) {
        switch (choice) {
          case Choice.JumpToSettingsPage:
            Navigator.pushNamed(context, "/s");
            break;
          case Choice.JumpToEditorPage:
            Navigator.pushNamed(context, "/e", arguments: {
              "action": ACTION_NOOP,
            });
            break;
        }
      },
    );
  }
}
