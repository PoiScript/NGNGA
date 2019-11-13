import 'package:flutter/material.dart';

class LinkDialog extends StatelessWidget {
  final String url;

  LinkDialog(this.url) : assert(url != null);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "Opening Link",
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.subtitle,
      ),
      content: Text(
        url,
        textAlign: TextAlign.center,
        style:
            Theme.of(context).textTheme.body2.copyWith(color: Colors.lightBlue),
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: null,
          child: Text("Ok"),
        )
      ],
    );
  }
}
