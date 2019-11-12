import 'package:flutter/material.dart';

enum Choice {
  jumpToEditorPage,
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
          value: Choice.jumpToEditorPage,
          child: Text(
            "Jump to EditorPage",
            style: Theme.of(context).textTheme.body1,
          ),
        ),
      ],
      onSelected: (choice) {
        switch (choice) {
          case Choice.jumpToEditorPage:
            Navigator.pushNamed(context, "/e");
            break;
        }
      },
    );
  }
}
