import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:ngnga/localizations.dart';
import 'package:ngnga/screens/editor/editor.dart';

enum Choice {
  jumpToSettingsPage,
  jumpToEditorPage,
}

class PopupMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Choice>(
      icon: Icon(
        Icons.more_vert,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
      ),
      itemBuilder: (context) => [
        PopupMenuItem<Choice>(
          value: Choice.jumpToSettingsPage,
          child: Text(
            AppLocalizations.of(context).settings,
            style: Theme.of(context).textTheme.body1,
          ),
        ),
        // a noop editor, used for debugging only
        if (kDebugMode)
          PopupMenuItem<Choice>(
            value: Choice.jumpToEditorPage,
            child: Text(
              'Editor (noop)',
              style: Theme.of(context).textTheme.body1,
            ),
          ),
      ],
      onSelected: (choice) {
        switch (choice) {
          case Choice.jumpToSettingsPage:
            Navigator.pushNamed(context, '/s');
            break;
          case Choice.jumpToEditorPage:
            Navigator.pushNamed(context, '/e', arguments: {
              'action': actionNoop,
            });
            break;
        }
      },
    );
  }
}
