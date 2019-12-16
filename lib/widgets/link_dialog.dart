import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ngnga/localizations.dart';

class LinkDialog extends StatelessWidget {
  final String url;

  LinkDialog(this.url) : assert(url != null);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context).linkClicked),
      content: Text(url),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            Navigator.pop(context);
            Clipboard.setData(ClipboardData(text: url));
          },
          child: Text(AppLocalizations.of(context).copyToClipboard),
        ),
        FlatButton(
          onPressed: () {
            Navigator.pop(context);
            launch(url);
          },
          child: Text(AppLocalizations.of(context).open),
        ),
      ],
    );
  }
}
