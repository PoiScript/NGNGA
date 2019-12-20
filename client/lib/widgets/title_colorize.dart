import 'package:html_unescape/html_unescape.dart';
import 'package:flutter/material.dart';

import 'package:business/models/topic.dart';

final _unescape = HtmlUnescape();

class TitleColorize extends StatelessWidget {
  final Topic topic;
  final int maxLines;
  final TextOverflow overflow;
  final bool displayLabel;

  const TitleColorize(
    this.topic, {
    this.maxLines,
    this.overflow,
    this.displayLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    List<InlineSpan> spans = [];

    final content = _unescape.convert(topic.title);
    var lastEnd = 0;

    TextStyle base = Theme.of(context).textTheme.body1.copyWith(
          fontFamily: 'Noto Sans CJK SC',
          fontWeight: topic.decorations.contains(TopicDecoration.boldStyle)
              ? FontWeight.w500
              : FontWeight.w400,
          fontStyle: topic.decorations.contains(TopicDecoration.italicStyle)
              ? FontStyle.italic
              : FontStyle.normal,
          decoration: topic.decorations.contains(TopicDecoration.underlineStyle)
              ? TextDecoration.underline
              : TextDecoration.none,
        );

    if (topic.decorations.contains(TopicDecoration.redColor)) {
      base = base.copyWith(color: Colors.red);
    }
    if (topic.decorations.contains(TopicDecoration.blueColor)) {
      base = base.copyWith(color: Colors.blue);
    }
    if (topic.decorations.contains(TopicDecoration.greenColor)) {
      base = base.copyWith(color: Colors.green);
    }
    if (topic.decorations.contains(TopicDecoration.orangeColor)) {
      base = base.copyWith(color: Colors.orange);
    }
    if (topic.decorations.contains(TopicDecoration.silverColor)) {
      base = base.copyWith(color: Colors.grey);
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
            style: base,
          ),
        );
      }

      // TODO(enhancement): topic key
      // https://github.com/PoiScript/NGNGA/issues/8
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
        style: base,
      ));
    }

    TextStyle body2 = Theme.of(context).textTheme.body2;

    if (topic.decorations.contains(TopicDecoration.locked)) {
      spans.add(TextSpan(
        text: ' [锁定]',
        style: body2.copyWith(color: Colors.red[700]),
      ));
    }
    if (topic.decorations.contains(TopicDecoration.category)) {
      spans.add(TextSpan(
        text: ' [版面]',
        style: body2.copyWith(color: Colors.red[700]),
      ));
    }
    if (topic.decorations.contains(TopicDecoration.subcategory)) {
      spans.add(TextSpan(
        text: ' [合集]',
        style: body2.copyWith(color: Colors.red[700]),
      ));
    }
    if (topic.decorations.contains(TopicDecoration.allHideen)) {
      spans.add(TextSpan(
        text: ' [全隐]',
        style: body2.copyWith(color: Colors.red[700]),
      ));
    }
    if (topic.decorations.contains(TopicDecoration.allAnonymous)) {
      spans.add(TextSpan(
        text: ' [全匿]',
        style: body2.copyWith(color: Colors.red[700]),
      ));
    }
    if (topic.decorations.contains(TopicDecoration.reverseOrder)) {
      spans.add(TextSpan(
        text: ' [倒序]',
        style: body2.copyWith(color: Colors.red[700]),
      ));
    }
    if (topic.decorations.contains(TopicDecoration.singleReply)) {
      spans.add(TextSpan(
        text: ' [单贴]',
        style: body2.copyWith(color: Colors.red[700]),
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
