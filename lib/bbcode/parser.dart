import 'package:html_unescape/html_unescape.dart';

import 'sticker.dart';
import 'tag.dart';

final _bbcodeTagRegExp = RegExp(r'\[([^=\s\[\]]*?)(=[^\]]*?)?\]');

final _ruleRegExp = RegExp(r'^\s*={5,}\s*$', multiLine: true);
final _headingRegExp = RegExp(r'^\s*={3,}(.*?)={3,}\s*$', multiLine: true);

final _replyRegExp0 = RegExp(
  // [b]Reply to [pid=xxxx,xxxx,xxx]Reply[/pid] Post by [uid=xxx]xxxx[/uid] (xx-xx-xx xx:xx)[/b]
  r'\[b\]Reply to \[pid=(\d*),(\d*),(\d*)\]Reply\[/pid\] Post by \[uid=(\d*)\](.*?)\[/uid\] \((\d{4}-\d{2}-\d{2} \d{2}:\d{2})\)\[/b\]',
);

final _replyRegExp1 = RegExp(
  // [b]Reply to [pid=xxxx,xxxx,xxx]Reply[/pid] Post by [uid]xxxx[/uid][color=gray](xxx楼)[/color] (xx-xx-xx xx:xx)[/b]
  r'\[b\]Reply to \[pid=(\d*),(\d*),(\d*)\]Reply\[/pid\] Post by \[uid\](.*?)\[/uid\]\[color=gray\]\(\d*楼\)\[/color\] \((\d{4}-\d{2}-\d{2} \d{2}:\d{2})\)\[/b\]',
);

final _replyRegExp2 = RegExp(
  // [b]Reply to [tid=xxx]Topic[/tid] Post by [uid=xxx]xxx[/uid] (xxxx-xx-xx xx:xx)[/b]
  r'\[b\]Reply to \[tid=(\d*)\]Topic\[/tid\] Post by \[uid=(\d*)\](.*?)\[/uid\] \((\d{4}-\d{2}-\d{2} \d{2}:\d{2})\)\[/b\]',
);

final _replyRegExp3 = RegExp(
  // [pid=xxx,xxx,xxx]Reply[/pid] [b]Post by [uid=xxx]xxx[/uid] (xx-xx-xx xx:xx):[/b]
  r'\[pid=(\d*),(\d*),(\d*)\]Reply\[/pid\] \[b\]Post by \[uid=(\d*)\](.*?)\[/uid\] \((\d{4}-\d{2}-\d{2} \d{2}:\d{2})\):\[/b\]',
);

final _replyRegExp4 = RegExp(
  // [pid=xxx,xxx,xxx]Reply[/pid] [b]Post by [uid]xxx[/uid][color=gray](xxx楼)[/color] (xx-xx-xx xx:xx):[/b]
  r'\[pid=(\d*),(\d*),(\d*)\]Reply\[/pid\] \[b\]Post by \[uid\](.*?)\[/uid\]\[color=gray\]\(\d*楼\)\[/color\] \((\d{4}-\d{2}-\d{2} \d{2}:\d{2})\):\[/b\]',
);

final _replyRegExp5 = RegExp(
  // [pid=xxx,xxx,xxx]Reply[/pid] [b]Post by [uid=-xxx]xxx[/uid][color=gray](xxx楼)[/color] (xx-xx-xx xx:xx):[/b]
  r'\[pid=(\d*),(\d*),(\d*)\]Reply\[/pid\] \[b\]Post by \[uid=(-\d*)\](.*?)\[/uid\]\[color=gray\]\(\d*楼\)\[/color\] \((\d{4}-\d{2}-\d{2} \d{2}:\d{2})\):\[/b\]',
);

final _replyRegExp6 = RegExp(
  // [tid=xxx]Topic[/tid] [b]Post by [uid=xxx]xxx[/uid] (xx-xx-xx xx:xx):[/b]
  r'\[tid=(\d*)\]Topic\[/tid\] \[b\]Post by \[uid=(\d*)\](.*?)\[/uid\] \((\d{4}-\d{2}-\d{2} \d{2}:\d{2})\):\[/b\]',
);

final HtmlUnescape unescape = HtmlUnescape();

Iterable<Tag> parseBBCode(String raw) sync* {
  bool openingParagraph = false;
  String content = unescape
      .convert(raw)
      .replaceAll(_ruleRegExp, '[hr]')
      .replaceAllMapped(_headingRegExp, (Match m) => '[h]${m[1]}[/h]');

  for (Tag tag in _parseTags(content)) {
    if (tag is HeadingStartTag ||
        tag is ReplyTag ||
        tag is RuleTag ||
        tag is CollapseStartTag ||
        tag is AlignStartTag ||
        tag is TableStartTag ||
        tag is QuoteStartTag ||
        tag is ListItemStartTag) {
      if (openingParagraph) {
        yield ParagraphEndTag();
        openingParagraph = false;
      }
    } else if (tag is HeadingEndTag ||
        tag is ReplyTag ||
        tag is RuleTag ||
        tag is CollapseEndTag ||
        tag is AlignEndTag ||
        tag is TableEndTag ||
        tag is QuoteEndTag ||
        tag is ListItemEndTag) {
      if (openingParagraph) {
        yield ParagraphEndTag();
        openingParagraph = false;
      }
    } else if (!openingParagraph) {
      yield ParagraphStartTag();
      openingParagraph = true;
    }
    yield tag;
  }

  if (openingParagraph) {
    yield ParagraphEndTag();
  }
}

Iterable<Tag> _parseTags(String content, {bool linkContent = false}) sync* {
  String tail = content;

  outerloop:
  while (true) {
    for (Match match in _bbcodeTagRegExp.allMatches(tail)) {
      if (match[0] == '[b]') {
        RegExpMatch regexMatch =
            _replyRegExp0.firstMatch(tail.substring(match.start));

        if (regexMatch != null) {
          yield ReplyTag(
            postId: int.parse(regexMatch[1]),
            topicId: int.parse(regexMatch[2]),
            pageIndex: int.parse(regexMatch[3]),
            userId: int.parse(regexMatch[4]),
            username: regexMatch[5],
            dateTime: DateTime.parse(regexMatch[6]),
          );
          tail = tail.substring(match.start + regexMatch.end).trimLeft();
          continue outerloop;
        }

        regexMatch = _replyRegExp1.firstMatch(tail.substring(match.start));

        if (regexMatch != null) {
          yield ReplyTag(
            postId: int.parse(regexMatch[1]),
            topicId: int.parse(regexMatch[2]),
            pageIndex: int.parse(regexMatch[3]),
            dateTime: DateTime.parse(regexMatch[5]),
          );
          tail = tail.substring(match.start + regexMatch.end).trimLeft();
          continue outerloop;
        }

        regexMatch = _replyRegExp2.firstMatch(tail.substring(match.start));

        if (regexMatch != null) {
          yield ReplyTag(
            postId: 0,
            topicId: int.parse(regexMatch[1]),
            userId: int.parse(regexMatch[2]),
            username: regexMatch[3],
            dateTime: DateTime.parse(regexMatch[4]),
          );
          tail = tail.substring(match.start + regexMatch.end).trimLeft();
          continue outerloop;
        }
      }

      if (match[1] == 'pid' && match[2] != null) {
        RegExpMatch regexMatch =
            _replyRegExp3.firstMatch(tail.substring(match.start));

        if (regexMatch != null) {
          yield ReplyTag(
            postId: int.parse(regexMatch[1]),
            topicId: int.parse(regexMatch[2]),
            pageIndex: int.parse(regexMatch[3]),
            userId: int.parse(regexMatch[4]),
            username: regexMatch[5],
            dateTime: DateTime.parse(regexMatch[6]),
          );
          tail = tail.substring(match.start + regexMatch.end).trimLeft();
          continue outerloop;
        }

        regexMatch = _replyRegExp4.firstMatch(tail.substring(match.start));

        if (regexMatch != null) {
          yield ReplyTag(
            postId: int.parse(regexMatch[1]),
            topicId: int.parse(regexMatch[2]),
            pageIndex: int.parse(regexMatch[3]),
            dateTime: DateTime.parse(regexMatch[5]),
          );
          tail = tail.substring(match.start + regexMatch.end).trimLeft();
          continue outerloop;
        }

        regexMatch = _replyRegExp5.firstMatch(tail.substring(match.start));

        if (regexMatch != null) {
          yield ReplyTag(
            postId: int.parse(regexMatch[1]),
            topicId: int.parse(regexMatch[2]),
            pageIndex: int.parse(regexMatch[3]),
            userId: int.parse(regexMatch[4]),
            dateTime: DateTime.parse(regexMatch[6]),
          );
          tail = tail.substring(match.start + regexMatch.end).trimLeft();
          continue outerloop;
        }
      }

      if (match[1] == 'tid' && match[2] != null) {
        RegExpMatch regexMatch =
            _replyRegExp6.firstMatch(tail.substring(match.start));

        if (regexMatch != null) {
          yield ReplyTag(
            postId: 0,
            topicId: int.parse(regexMatch[1]),
            userId: int.parse(regexMatch[2]),
            username: regexMatch[3],
            dateTime: DateTime.parse(regexMatch[4]),
          );
          tail = tail.substring(match.start + regexMatch.end).trimLeft();
          continue outerloop;
        }
      }

      int end;
      if (match[0] == '[b]' &&
          (end = _findEndTag(tail, match.end, 'b')) != -1) {
        if (match.start > 0) {
          yield* _parseTags(tail.substring(0, match.start));
        }
        yield BoldStartTag();
        yield* _parseTags(tail.substring(match.end, end));
        yield BoldEndTag();
        tail = tail.substring(end + 4);
        continue outerloop;
      }

      if (match[0] == '[i]' &&
          (end = _findEndTag(tail, match.end, 'i')) != -1) {
        if (match.start > 0) {
          yield* _parseTags(tail.substring(0, match.start));
        }
        yield ItalicStartTag();
        yield* _parseTags(tail.substring(match.end, end).trim());
        yield ItalicEndTag();
        tail = tail.substring(end + 4);
        continue outerloop;
      }

      if (match[0] == '[u]' &&
          (end = _findEndTag(tail, match.end, 'u')) != -1) {
        if (match.start > 0) {
          yield* _parseTags(tail.substring(0, match.start));
        }
        yield UnderlineStartTag();
        yield* _parseTags(tail.substring(match.end, end).trim());
        yield UnderlineEndTag();
        tail = tail.substring(end + 4);
        continue outerloop;
      }

      if (match[0] == '[del]' &&
          (end = _findEndTag(tail, match.end, 'del')) != -1) {
        if (match.start > 0) {
          yield* _parseTags(tail.substring(0, match.start));
        }
        yield DeleteStartTag();
        yield* _parseTags(tail.substring(match.end, end).trim());
        yield DeleteEndTag();
        tail = tail.substring(end + 6);
        continue outerloop;
      }

      if (match[1] == 'size' &&
          match[2] != null &&
          (end = _findEndTag(tail, match.end, 'size')) != -1) {
        if (match.start > 0) {
          yield* _parseTags(tail.substring(0, match.start));
        }
        yield SizeStartTag(match[2].substring(1));
        yield* _parseTags(tail.substring(match.end, end));
        yield SizeEndTag();
        tail = tail.substring(end + 7);
        continue outerloop;
      }

      if (match[1] == 'color' &&
          match[2] != null &&
          (end = _findEndTag(tail, match.end, 'color')) != -1) {
        if (match.start > 0) {
          yield* _parseTags(tail.substring(0, match.start));
        }
        yield ColorStartTag(match[2].substring(1));
        yield* _parseTags(tail.substring(match.end, end));
        yield ColorEndTag();
        tail = tail.substring(end + 8);
        continue outerloop;
      }

      if (match[1] == 'font' &&
          match[2] != null &&
          (end = _findEndTag(tail, match.end, 'font')) != -1) {
        if (match.start > 0) {
          yield* _parseTags(tail.substring(0, match.start));
        }
        yield FontStartTag(match[2].substring(1));
        yield* _parseTags(tail.substring(match.end, end));
        yield FontEndTag();
        tail = tail.substring(end + 8);
        continue outerloop;
      }

      if (!linkContent &&
          match[1] == 'collapse' &&
          (end = tail.indexOf('[/collapse]', match.end)) != -1) {
        if (match.start > 0) {
          yield* _parseTags(tail.substring(0, match.start).trimRight());
        }
        yield CollapseStartTag(match[2]?.substring(1));
        yield* _parseTags(tail.substring(match.end, end).trim());
        yield CollapseEndTag();
        tail = tail.substring(end + 11).trimLeft();
        continue outerloop;
      }

      if (!linkContent &&
          match[0] == '[quote]' &&
          (end = _findEndTag(tail, match.end, 'quote')) != -1) {
        if (match.start > 0) {
          yield* _parseTags(tail.substring(0, match.start).trimRight());
        }
        yield QuoteStartTag();
        yield* _parseTags(tail.substring(match.end, end).trim());
        yield QuoteEndTag();
        tail = tail.substring(end + 8).trimLeft();
        continue outerloop;
      }

      if (!linkContent &&
          match[0] == '[list]' &&
          (end = _findEndTag(tail, match.end, 'list')) != -1) {
        if (match.start > 0) {
          yield* _parseTags(tail.substring(0, match.start).trimRight());
        }
        for (String item in tail
            .substring(match.end, end)
            .split('[*]')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)) {
          yield ListItemStartTag();
          yield* _parseTags(item);
          yield ListItemEndTag();
        }
        tail = tail.substring(end + 7).trimLeft();
        continue outerloop;
      }

      if (!linkContent &&
          (match[0] == '[align=center]' ||
              match[0] == '[align=left]' ||
              match[0] == '[align=right]') &&
          (end = _findEndTag(tail, match.end, 'align')) != -1) {
        if (match.start > 0) {
          yield* _parseTags(tail.substring(0, match.start).trimRight());
        }
        yield AlignStartTag(match[1].substring(1));
        yield* _parseTags(tail.substring(match.end, end).trim());
        yield AlignEndTag();
        tail = tail.substring(end + 8).trimLeft();
        continue outerloop;
      }

      if (!linkContent &&
          match[0] == '[h]' &&
          (end = _findEndTag(tail, match.end, 'h')) != -1) {
        if (match.start > 0) {
          yield* _parseTags(tail.substring(0, match.start).trimRight());
        }
        yield HeadingStartTag();
        yield* _parseTags(tail.substring(match.end, end).trim());
        yield HeadingEndTag();
        tail = tail.substring(end + 4).trimLeft();
        continue outerloop;
      }

      if (match[0] == '[hr]') {
        if (match.start > 0) {
          yield* _parseTags(tail.substring(0, match.start));
        }
        yield RuleTag();
        tail = tail.substring(match.end).trimLeft();
        continue outerloop;
      }

      if (match[1] == 'url' &&
          (end = tail.indexOf('[/url]', match.end)) != -1) {
        if (match.start > 0) {
          yield TextTag(tail.substring(0, match.start));
        }
        if (match[2] != null) {
          yield LinkStartTag(match[2].trim());
          yield* _parseTags(tail.substring(match.end, end), linkContent: true);
          yield LinkEndTag();
          tail = tail.substring(end + 6);
        } else {
          yield LinkStartTag(tail.substring(match.end, end));
          yield TextTag(tail.substring(match.end, end));
          yield LinkEndTag();
          tail = tail.substring(end + 6);
        }
        continue outerloop;
      }

      if (match[0] == '[img]' &&
          (end = tail.indexOf('[/img]', match.end)) != -1) {
        if (match.start > 0) {
          yield TextTag(tail.substring(0, match.start));
        }
        String name = urlToName(tail.substring(match.end, end));
        if (name != null) {
          yield StickerTag(name);
        } else {
          yield ImageTag(tail.substring(match.end, end));
        }
        tail = tail.substring(end + 6);
        continue outerloop;
      }

      if (match[1].startsWith('s:') &&
          stickerNames.contains(match[1].substring(2))) {
        if (match.start > 0) {
          yield TextTag(tail.substring(0, match.start));
        }
        yield StickerTag(match[1].substring(2));
        tail = tail.substring(match.end);
        continue outerloop;
      }

      if (match[1].startsWith('@')) {
        if (match.start > 0) {
          yield TextTag(tail.substring(0, match.start));
        }
        yield MetionsTag(match[1].substring(1).trim());
        tail = tail.substring(match.end);
        continue outerloop;
      }
    }
    break;
  }

  if (tail.isNotEmpty) {
    yield TextTag(tail);
  }
}

int _findEndTag(String content, int start, String tag) {
  int depth = 1;
  for (Match match in _bbcodeTagRegExp.allMatches(content, start)) {
    if (match[1] == tag) {
      depth += 1;
    } else if (match[2] == null &&
        match[1].startsWith('/') &&
        match[1].substring(1) == tag) {
      if (depth == 1) return match.start;
      depth -= 1;
    }
  }
  return -1;
}
