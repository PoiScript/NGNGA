import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:ngnga/widgets/bbcode_render.dart';

class PreviewDialog extends StatelessWidget {
  final String content;

  const PreviewDialog({
    Key key,
    @required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(8.0),
          alignment: Alignment.centerLeft,
          child: BBCodeRender(
            raw: content,
            openLink: (x) => {},
            openPost: (x, y, z) => {},
            openUser: (x) => {},
          ),
        ),
      ],
    );
  }
}
