import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkDialog extends StatelessWidget {
  final String url;

  LinkDialog(this.url) : assert(url != null);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(
        "链接",
        style: Theme.of(context).textTheme.subtitle,
      ),
      children: <Widget>[
        Text(
          url,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .body2
              .copyWith(color: Colors.lightBlue),
        ),
        Container(
          alignment: Alignment.centerRight,
          child: FlatButton(
            onPressed: () {
              Navigator.pop(context);
              launch(url);
            },
            child: Text("打开"),
          ),
        ),
      ],
    );
  }
}
