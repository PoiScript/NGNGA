import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';

import 'package:ngnga/models/topic.dart';

final HtmlUnescape unescape = HtmlUnescape();

class TitleColorize extends StatelessWidget {
  final Topic topic;
  final int maxLines;
  final TextOverflow overflow;
  final bool displayLabel;

  TitleColorize(
    this.topic, {
    this.maxLines,
    this.overflow,
    this.displayLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    List<InlineSpan> spans = [];

    final content = unescape.convert(topic.title);
    var lastEnd = 0;

    final base = Theme.of(context).textTheme.body1.copyWith(
          fontWeight: topic.isBold ? FontWeight.w500 : FontWeight.w400,
          fontStyle: topic.isItalic ? FontStyle.italic : FontStyle.normal,
          fontFamily: 'Noto Sans CJK SC',
          decoration: topic.isUnderline
              ? TextDecoration.underline
              : TextDecoration.none,
        );

    var color = base.color;

    switch (topic.titleColor) {
      case TitleColor.red:
        color = Colors.red;
        break;
      case TitleColor.blue:
        color = Colors.blue;
        break;
      case TitleColor.green:
        color = Colors.green;
        break;
      case TitleColor.orange:
        color = Colors.orange;
        break;
      case TitleColor.silver:
        color = Colors.grey;
        break;
      case TitleColor.none:
        break;
    }

    while (true) {
      var start = content.indexOf('[', lastEnd);

      if (start == -1) {
        break;
      }

      var end = content.indexOf(']', start);

      if (end == -1) {
        break;
      }

      if (lastEnd != start) {
        spans.add(
          TextSpan(
            text: content.substring(lastEnd, start).trim(),
            style: base.copyWith(color: color),
          ),
        );
      }

      if (content.substring(start + 1, end) == '专楼') {
        spans.add(TextSpan(
          text: content.substring(start, end + 1),
          style: base.copyWith(color: Colors.purple),
        ));
      } else {
        spans.add(TextSpan(
          text: content.substring(start, end + 1),
          style: base.copyWith(color: Colors.grey),
        ));
      }

      lastEnd = end + 1;
    }

    if (lastEnd != content.length) {
      spans.add(TextSpan(
        text: content.substring(lastEnd).trim(),
        style: base.copyWith(color: color),
      ));
    }

    if (displayLabel && topic.isLocked) {
      spans.add(TextSpan(
        text: ' [锁定]',
        style:
            Theme.of(context).textTheme.body2.copyWith(color: Colors.red[700]),
      ));
    }

    if (displayLabel && topic.label != null) {
      spans.add(WidgetSpan(
        child: Container(
          margin: EdgeInsets.only(left: 2.0),
          padding: EdgeInsets.symmetric(horizontal: 2.0, vertical: 1.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
          ),
          child: Text(
            topic.label,
            style: Theme.of(context).textTheme.caption,
            textAlign: TextAlign.center,
          ),
        ),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}
