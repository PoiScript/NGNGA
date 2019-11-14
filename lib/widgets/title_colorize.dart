import 'package:flutter/material.dart';

import 'package:html_unescape/html_unescape.dart';

final unescape = HtmlUnescape();

class TitleColorize extends StatelessWidget {
  final String content;
  final int maxLines;
  final TextOverflow overflow;

  TitleColorize(
    String content, {
    this.maxLines,
    this.overflow,
  }) : content = unescape.convert(content);

  @override
  Widget build(BuildContext context) {
    List<InlineSpan> _spans = [];

    var lastEnd = 0;

    while (true) {
      var start = content.indexOf("[", lastEnd);

      if (start == -1) {
        break;
      }

      var end = content.indexOf("]", start);

      if (end == -1) {
        break;
      }

      if (lastEnd != start) {
        _spans.add(TextSpan(
          text: content.substring(lastEnd, start),
          style: Theme.of(context).textTheme.body1,
        ));
      }

      if (content.substring(start + 1, end) == "专楼") {
        _spans.add(TextSpan(
          text: content.substring(start, end + 1),
          style:
              Theme.of(context).textTheme.body1.copyWith(color: Colors.purple),
        ));
      } else {
        _spans.add(TextSpan(
          text: content.substring(start, end + 1),
          style: Theme.of(context).textTheme.body1.copyWith(color: Colors.grey),
        ));
      }

      lastEnd = end + 1;
    }

    if (lastEnd != content.length) {
      _spans.add(TextSpan(
        text: content.substring(lastEnd),
        style: Theme.of(context).textTheme.body1,
      ));
    }

    return RichText(
      text: TextSpan(children: _spans),
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}
