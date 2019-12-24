import 'package:html_unescape/html_unescape.dart';
import 'package:flutter/material.dart';

import 'package:business/models/topic.dart';

final _unescape = HtmlUnescape();

class TitleColorize extends StatelessWidget {
  final Topic topic;
  final int maxLines;
  final TextOverflow overflow;

  const TitleColorize(
    this.topic, {
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    List<InlineSpan> spans = [];

    final content = _unescape.convert(topic.title);
    var lastEnd = 0;

    TextStyle base = Theme.of(context).textTheme.body1.copyWith(
          fontFamily: 'Noto Sans CJK SC',
          fontWeight: topic.isBold ? FontWeight.w500 : FontWeight.w400,
          fontStyle: topic.isItalic ? FontStyle.italic : FontStyle.normal,
          decoration: topic.isUnderline
              ? TextDecoration.underline
              : TextDecoration.none,
        );

    switch (topic.titleColor) {
      case TopicTitleColor.red:
        base = base.copyWith(color: Colors.red);
        break;
      case TopicTitleColor.blue:
        base = base.copyWith(color: Colors.blue);
        break;
      case TopicTitleColor.green:
        base = base.copyWith(color: Colors.green);
        break;
      case TopicTitleColor.orang:
        base = base.copyWith(color: Colors.orange);
        break;
      case TopicTitleColor.sliver:
        base = base.copyWith(color: Colors.grey);
        break;
      case TopicTitleColor.none:
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

    if (topic.isLocked) {
      spans.add(TextSpan(
        text: ' [锁定]',
        style: body2.copyWith(color: Colors.red[700]),
      ));
    }
    if (topic.allHideen) {
      spans.add(TextSpan(
        text: ' [全隐]',
        style: body2.copyWith(color: Colors.red[700]),
      ));
    }
    // if (topic.allAnonymous) {
    //   spans.add(TextSpan(
    //     text: ' [全匿]',
    //     style: body2.copyWith(color: Colors.red[700]),
    //   ));
    // }
    if (topic.reverseOrder) {
      spans.add(TextSpan(
        text: ' [倒序]',
        style: body2.copyWith(color: Colors.red[700]),
      ));
    }
    if (topic.singleReply) {
      spans.add(TextSpan(
        text: ' [单贴]',
        style: body2.copyWith(color: Colors.red[700]),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}
