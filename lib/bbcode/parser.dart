import 'package:html_unescape/html_unescape.dart';

import 'sticker.dart';
import 'tag.dart';

final RegExp headingRegExp = RegExp(r'===(.*?)===');

final RegExp alignStartRegExp = RegExp(r'\[align=([^\s\]]*)\]');
final RegExp sizeStartRegExp = RegExp(r'\[size=([^\s\]]*)\]');
final RegExp fontStartRegExp = RegExp(r'\[font=([^\s\]]*)\]');
final RegExp colorStartRegExp = RegExp(r'\[color=([^\s\]]*)\]');
final RegExp collapseStartRegExp = RegExp(r'\[collapse(=[^\]]*)?\]');
final RegExp linkRegExp = RegExp(r'\[url(=[^\s\]]*)?\]([^\[\]]*?)\[/url\]');

final RegExp uidRegExp = RegExp(r'\[uid=(\d*)\](.*?)\[/uid\]');
final RegExp pidRegExp = RegExp(r'\[pid=(\d*),(\d*),(\d*)\](.*?)\[/pid\]');
final RegExp metionsRegExp = RegExp(r'\[@([^\s\]]*?)\]');
final RegExp imageRegExp = RegExp(r'\[img\]([^\[\]]*?)\[/img\]');
final RegExp stickerRegExp = RegExp(r'\[s:([^\s\]]*?)\]');

final RegExp ruleRegExp = RegExp(r'^\s*={5,}\s*$', multiLine: true);

// [pid=xxx,xxx,xxx]Reply[/pid] [b]Post by [uid=xxx]xxx[/uid] (xx-xx-xx xx:xx):[/b]
RegExp replyRegExp1 = RegExp(
  r'\[pid=(\d*),(\d*),(\d*)\]Reply\[/pid\] \[b\]Post by \[uid=(\d*)\](.*?)\[/uid\] \((\d{4}-\d{2}-\d{2} \d{2}:\d{2})\):\[/b\]',
);

// [b]Reply to [pid=xxxx,xxxx,xxx]Reply[/pid] Post by [uid=xxx]xxxx[/uid] (xx-xx-xx xx:xx)[/b]
RegExp replyRegExp2 = RegExp(
  r'\[b\]Reply to \[pid=(\d*),(\d*),(\d*)\]Reply\[/pid\] Post by \[uid=(\d*)\](.*?)\[/uid\] \((\d{4}-\d{2}-\d{2} \d{2}:\d{2})\)\[/b\]',
);

// [pid=xxx,xxx,xxx]Reply[/pid] [b]Post by [uid]xxx[/uid][color=gray](xxx楼)[/color] (xx-xx-xx xx:xx):[/b]
RegExp replyRegExp3 = RegExp(
  r'\[pid=(\d*),(\d*),(\d*)\]Reply\[/pid\] \[b\]Post by \[uid\](.*?)\[/uid\]\[color=gray\]\(\d*楼\)\[/color\] \((\d{4}-\d{2}-\d{2} \d{2}:\d{2})\):\[/b\]',
);

// [pid=xxx,xxx,xxx]Reply[/pid] [b]Post by [uid=-xxx]xxx[/uid][color=gray](xxx楼)[/color] (xx-xx-xx xx:xx):[/b]
RegExp replyRegExp4 = RegExp(
  r'\[pid=(\d*),(\d*),(\d*)\]Reply\[/pid\] \[b\]Post by \[uid=(-\d*)\](.*?)\[/uid\]\[color=gray\]\(\d*楼\)\[/color\] \((\d{4}-\d{2}-\d{2} \d{2}:\d{2})\):\[/b\]',
);

// [b]Reply to [pid=xxxx,xxxx,xxx]Reply[/pid] Post by [uid]xxxx[/uid][color=gray](xxx楼)[/color] (xx-xx-xx xx:xx)[/b]
RegExp replyRegExp5 = RegExp(
  r'\[b\]Reply to \[pid=(\d*),(\d*),(\d*)\]Reply\[/pid\] Post by \[uid\](.*?)\[/uid\]\[color=gray\]\(\d*楼\)\[/color\] \((\d{4}-\d{2}-\d{2} \d{2}:\d{2})\)\[/b\]',
);

// [tid=xxx]Topic[/tid] [b]Post by [uid=xxx]xxx[/uid] (xx-xx-xx xx:xx):[/b]
RegExp replyRegExp6 = RegExp(
  r'\[tid=(\d*)\]Topic\[/tid\] \[b\]Post by \[uid=(\d*)\](.*?)\[/uid\] \((\d{4}-\d{2}-\d{2} \d{2}:\d{2})\):\[/b\]',
);

// [b]Reply to [tid=xxx]Topic[/tid] Post by [uid=xxx]xxx[/uid] (xxxx-xx-xx xx:xx)[/b]
RegExp replyRegExp7 = RegExp(
  r'\[b\]Reply to \[tid=(\d*)\]Topic\[/tid\] Post by \[uid=(\d*)\](.*?)\[/uid\] \((\d{4}-\d{2}-\d{2} \d{2}:\d{2})\)\[/b\]',
);

final HtmlUnescape unescape = HtmlUnescape();

List<Tag> parseBBCode(String raw) {
  List<_TagSpan> spans = [];

  String content = unescape.convert(unescape.convert(raw));

  while (true) {
    var match = replyRegExp1.firstMatch(content);

    if (match == null) break;

    spans.add(_TagSpan(
      ReplyTag(
        postId: int.parse(match[1]),
        topicId: int.parse(match[2]),
        pageIndex: int.parse(match[3]),
        userId: int.parse(match[4]),
        username: match[5],
        dateTime: DateTime.parse(match[6]),
      ),
      match.start,
      match.start + 1,
      removed: false,
    ));
    content =
        '${content.substring(0, match.start)}_${content.substring(match.end)}';
  }

  while (true) {
    var match = replyRegExp2.firstMatch(content);

    if (match == null) break;

    spans.add(_TagSpan(
      ReplyTag(
        postId: int.parse(match[1]),
        topicId: int.parse(match[2]),
        pageIndex: int.parse(match[3]),
        userId: int.parse(match[4]),
        username: match[5],
        dateTime: DateTime.parse(match[6]),
      ),
      match.start,
      match.start + 1,
      removed: false,
    ));
    content =
        '${content.substring(0, match.start)}_${content.substring(match.end)}';
  }

  while (true) {
    var match = replyRegExp3.firstMatch(content);

    if (match == null) break;

    spans.add(_TagSpan(
      ReplyTag(
        postId: int.parse(match[1]),
        topicId: int.parse(match[2]),
        pageIndex: int.parse(match[3]),
        dateTime: DateTime.parse(match[5]),
      ),
      match.start,
      match.start + 1,
      removed: false,
    ));
    content =
        '${content.substring(0, match.start)}_${content.substring(match.end)}';
  }

  while (true) {
    var match = replyRegExp4.firstMatch(content);

    if (match == null) break;

    spans.add(_TagSpan(
      ReplyTag(
        postId: int.parse(match[1]),
        topicId: int.parse(match[2]),
        pageIndex: int.parse(match[3]),
        userId: int.parse(match[4]),
        dateTime: DateTime.parse(match[6]),
      ),
      match.start,
      match.start + 1,
      removed: false,
    ));
    content =
        '${content.substring(0, match.start)}_${content.substring(match.end)}';
  }

  while (true) {
    var match = replyRegExp5.firstMatch(content);

    if (match == null) break;

    spans.add(_TagSpan(
      ReplyTag(
        postId: int.parse(match[1]),
        topicId: int.parse(match[2]),
        pageIndex: int.parse(match[3]),
        dateTime: DateTime.parse(match[5]),
      ),
      match.start,
      match.start + 1,
      removed: false,
    ));
    content =
        '${content.substring(0, match.start)}_${content.substring(match.end)}';
  }

  while (true) {
    var match = replyRegExp6.firstMatch(content);

    if (match == null) break;

    spans.add(_TagSpan(
      ReplyTag(
        postId: 0,
        topicId: int.parse(match[1]),
        userId: int.parse(match[2]),
        username: match[3],
        dateTime: DateTime.parse(match[4]),
      ),
      match.start,
      match.start + 1,
      removed: false,
    ));
    content =
        '${content.substring(0, match.start)}_${content.substring(match.end)}';
  }

  while (true) {
    var match = replyRegExp7.firstMatch(content);

    if (match == null) break;

    spans.add(_TagSpan(
      ReplyTag(
        postId: 0,
        topicId: int.parse(match[1]),
        userId: int.parse(match[2]),
        username: match[3],
        dateTime: DateTime.parse(match[4]),
      ),
      match.start,
      match.start + 1,
      removed: false,
    ));
    content =
        '${content.substring(0, match.start)}_${content.substring(match.end)}';
  }

  spans
    // styling
    ..addAll('[b]'.allMatches(content).map(
          (match) => _TagSpan.fromMatch(BoldStartTag(), match, removed: false),
        ))
    ..addAll('[/b]'.allMatches(content).map(
          (match) => _TagSpan.fromMatch(BoldEndTag(), match, removed: true),
        ))
    ..addAll('[i]'.allMatches(content).map(
          (match) =>
              _TagSpan.fromMatch(ItalicStartTag(), match, removed: false),
        ))
    ..addAll('[/i]'.allMatches(content).map(
          (match) => _TagSpan.fromMatch(ItalicEndTag(), match, removed: true),
        ))
    ..addAll('[u]'.allMatches(content).map(
          (match) =>
              _TagSpan.fromMatch(UnderlineStartTag(), match, removed: false),
        ))
    ..addAll('[/u]'.allMatches(content).map(
          (match) =>
              _TagSpan.fromMatch(UnderlineEndTag(), match, removed: true),
        ))
    ..addAll('[del]'.allMatches(content).map(
          (match) =>
              _TagSpan.fromMatch(DeleteStartTag(), match, removed: false),
        ))
    ..addAll('[/del]'.allMatches(content).map(
          (match) => _TagSpan.fromMatch(DeleteEndTag(), match, removed: true),
        ))
    ..addAll(sizeStartRegExp.allMatches(content).map(
          (match) => _TagSpan.fromMatch(SizeStartTag(), match, removed: false),
        ))
    ..addAll('[/size]'.allMatches(content).map(
          (match) => _TagSpan.fromMatch(SizeEndTag(), match, removed: true),
        ))
    ..addAll(fontStartRegExp.allMatches(content).map(
          (match) => _TagSpan.fromMatch(FontStartTag(), match, removed: false),
        ))
    ..addAll('[/font]'.allMatches(content).map(
          (match) => _TagSpan.fromMatch(FontEndTag(), match, removed: true),
        ))
    ..addAll(colorStartRegExp.allMatches(content).map(
          (match) => _TagSpan.fromMatch(ColorStartTag(match[1]), match,
              removed: false),
        ))
    ..addAll('[/color]'.allMatches(content).map(
          (match) => _TagSpan.fromMatch(ColorEndTag(), match, removed: true),
        ))
    ..addAll('[h]'.allMatches(content).map(
          (match) =>
              _TagSpan.fromMatch(HeadingStartTag(), match, removed: false),
        ))
    ..addAll('[/h]'.allMatches(content).map(
          (match) => _TagSpan.fromMatch(HeadingEndTag(), match, removed: true),
        ))
    // containers
    // ..addAll(alignStartRegExp.allMatches(content).map(
    //       (match) => _TagSpan.fromMatch(AlignStart(), match, false),
    //     ))
    // ..addAll('[/align]'.allMatches(content).map(
    //       (match) => _TagSpan.fromMatch(AlignEnd(), match, true),
    //     ))
    // ..addAll(headingRegExp.allMatches(content).expand((match) => [
    //       _TagSpan(HeadingStart(), match.start, match.start + 3, false),
    //       _TagSpan(HeadingEnd(), match.end - 3, match.end, true),
    //     ]))
    ..addAll('[quote]'.allMatches(content).map(
          (match) => _TagSpan.fromMatch(QuoteStartTag(), match, removed: false),
        ))
    ..addAll('[/quote]'.allMatches(content).map(
          (match) => _TagSpan.fromMatch(QuoteEndTag(), match, removed: true),
        ))
    ..addAll(collapseStartRegExp.allMatches(content).map(
          (match) => _TagSpan.fromMatch(
              CollapseStartTag(match[1]?.substring(1)), match,
              removed: false),
        ))
    ..addAll('[/collapse]'.allMatches(content).map(
          (match) => _TagSpan.fromMatch(CollapseEndTag(), match, removed: true),
        ))
    ..addAll(linkRegExp.allMatches(content).expand((match) => [
          _TagSpan(
            LinkStartTag(match[1]?.substring(1) ?? match[2]),
            match.start,
            match.start + 5 + (match[1]?.length ?? 0),
            removed: false,
          ),
          _TagSpan(LinkEndTag(), match.end - 6, match.end, removed: false),
        ]))
    // inline objects
    ..addAll(ruleRegExp.allMatches(content).map(
          (match) => _TagSpan.fromMatch(RuleTag(), match, removed: false),
        ))
    ..addAll(uidRegExp.allMatches(content).map(
          (match) => _TagSpan.fromMatch(
              UidTag(int.parse(match[1]), match[2]), match,
              removed: false),
        ))
    ..addAll(metionsRegExp.allMatches(content).map(
          (match) =>
              _TagSpan.fromMatch(MetionsTag(match[1]), match, removed: false),
        ))
    ..addAll(imageRegExp.allMatches(content).map(
          (match) => _TagSpan.fromMatch(
            imageUrlToName.containsKey(match[1])
                ? StickerTag(imageUrlToName[match[1]])
                : ImageTag(match[1]),
            match,
            removed: false,
          ),
        ))
    ..addAll(stickerRegExp
        .allMatches(content)
        .where((match) => stickerNames.contains(match[1]))
        .map(
          (match) =>
              _TagSpan.fromMatch(StickerTag(match[1]), match, removed: false),
        ))
    ..addAll(pidRegExp.allMatches(content).map(
          (match) => _TagSpan.fromMatch(
            PidTag(int.parse(match[2]), int.parse(match[3]),
                int.parse(match[4]), match[5]),
            match,
            removed: false,
          ),
        ));

  if (spans.isEmpty) {
    return [
      ParagraphStartTag(),
      TextTag(content),
      ParagraphEndTag(),
    ];
  }

  spans.sort((a, b) => a.start.compareTo(b.start));

  for (int i = 0; i < spans.length; i++) {
    if (spans[i].removed) continue;

    if (spans[i].tag is QuoteStartTag) {
      _findQuoteEndTag(spans, i);
    } else if (spans[i].tag is LinkStartTag) {
      _findLinkEndTag(spans, i);
    } else if (spans[i].tag is CollapseStartTag) {
      _findCollapseEndTag(spans, i);
    } else if (spans[i].tag is BoldStartTag) {
      _findStylingEndTag<BoldStartTag, BoldEndTag>(spans, i);
    } else if (spans[i].tag is FontStartTag) {
      _findStylingEndTag<FontStartTag, FontEndTag>(spans, i);
    } else if (spans[i].tag is ColorStartTag) {
      _findStylingEndTag<ColorStartTag, ColorEndTag>(spans, i);
    } else if (spans[i].tag is SizeStartTag) {
      _findStylingEndTag<SizeStartTag, SizeEndTag>(spans, i);
    } else if (spans[i].tag is UnderlineStartTag) {
      _findStylingEndTag<UnderlineStartTag, UnderlineEndTag>(spans, i);
    } else if (spans[i].tag is ItalicStartTag) {
      _findStylingEndTag<ItalicStartTag, ItalicEndTag>(spans, i);
    } else if (spans[i].tag is DeleteStartTag) {
      _findStylingEndTag<DeleteStartTag, DeleteEndTag>(spans, i);
    } else if (spans[i].tag is HeadingStartTag) {
      _findStylingEndTag<HeadingStartTag, HeadingEndTag>(spans, i);
    } else if (spans[i].tag is TableStartTag) {
      // TODO: Handle this case.
    } else if (spans[i].tag is TableRowStartTag) {
      // TODO: Handle this case.
    } else if (spans[i].tag is TableCellStartTag) {
      // TODO: Handle this case.
    } else if (spans[i].tag is AlignStartTag) {
      _findAlignEndTag(spans, i);
    }
  }

  for (int i = 0; i < spans.length; i++) {
    if (spans[i].removed) continue;

    if (spans[i].tag is AlignStartTag) {
      _handleAlignMisnested(spans, i);
    } else if (spans[i].tag is QuoteStartTag) {
      _handleQuoteMisnested(spans, i);
    } else if (spans[i].tag is TableStartTag) {
      // TODO: Handle this case.
    } else if (spans[i].tag is TableRowStartTag) {
      // TODO: Handle this case.
    } else if (spans[i].tag is TableCellStartTag) {
      // TODO: Handle this case.
    }
  }

  List<Tag> tags = [];
  int lastEnd = 0;
  bool openingParagraph = false;

  for (_TagSpan span in spans) {
    if (span.removed) continue;

    if (span.start != lastEnd) {
      String text = content.substring(lastEnd, span.start).trim();
      if (text.isNotEmpty) {
        if (!openingParagraph) {
          tags.add(ParagraphStartTag());
          openingParagraph = true;
        }
        tags.add(TextTag(text));
      }
    }

    lastEnd = span.end;

    if (span.tag is HeadingStartTag ||
        span.tag is HeadingEndTag ||
        span.tag is ReplyTag ||
        span.tag is RuleTag ||
        span.tag is CollapseStartTag ||
        span.tag is CollapseEndTag ||
        span.tag is AlignStartTag ||
        span.tag is AlignEndTag ||
        span.tag is TableStartTag ||
        span.tag is TableEndTag ||
        span.tag is QuoteStartTag ||
        span.tag is QuoteEndTag) {
      if (openingParagraph) {
        tags.add(ParagraphEndTag());
        openingParagraph = false;
      }
    } else if (!openingParagraph) {
      tags.add(ParagraphStartTag());
      openingParagraph = true;
    }

    tags.add(span.tag);
  }

  if (lastEnd < content.length) {
    String text = content.substring(lastEnd).trim();
    if (text.isNotEmpty) {
      if (!openingParagraph) {
        tags.add(ParagraphStartTag());
        openingParagraph = true;
      }
      tags.add(TextTag(text));
    }
  }

  if (openingParagraph) {
    tags.add(ParagraphEndTag());
  }

  return tags;
}

_findStylingEndTag<StartTag, EndTag>(List<_TagSpan> spans, int start) {
  int end = _findEndTag<StartTag, EndTag>(spans, start);

  if (end == -1 || !spans[end].removed) {
    spans[start].removed = true;
  } else {
    spans[end].removed = false;
  }
}

_findAlignEndTag(List<_TagSpan> spans, int start) {
  int end = _findEndTag<AlignStartTag, AlignEndTag>(spans, start);

  if (end == -1 || !spans[end].removed) {
    spans[start].removed = true;
  } else {
    spans[end].removed = false;
  }
}

_handleAlignMisnested(List<_TagSpan> spans, int start) {
  int end = _findEndTag<AlignStartTag, AlignEndTag>(spans, start);

  List<_TagSpan> opening = [];

  for (int i = start + 1; i < end; i++) {
    _TagSpan span = spans[i];

    if (span.removed) continue;

    if (span.tag is CollapseStartTag || span.tag is QuoteStartTag) {
      opening.add(span);
    } else if (span.tag is CollapseEndTag) {
      int collapseStart =
          opening.lastIndexWhere((span) => span.tag is CollapseStartTag);

      if (collapseStart != -1) {
        opening.removeAt(collapseStart);
      } else {
        spans[end].removed = true;
        spans[start].removed = true;
        return;
      }
    } else if (span.tag is QuoteEndTag) {
      int quoteStart =
          opening.lastIndexWhere((span) => span.tag is QuoteEndTag);

      if (quoteStart != -1) {
        opening.removeAt(quoteStart);
      } else {
        spans[end].removed = true;
        spans[start].removed = true;
        return;
      }
    }
  }

  if (opening.isNotEmpty) {
    spans[end].removed = true;
    spans[start].removed = true;
  }
}

_findCollapseEndTag(List<_TagSpan> spans, int start) {
  int end = spans.indexWhere((t) => t.tag is CollapseEndTag, start);

  if (end != -1 && spans[end].removed) {
    spans[end].removed = false;
  } else {
    spans[start].removed = true;
  }
}

_findQuoteEndTag(List<_TagSpan> spans, int start) {
  int end = _findEndTag<QuoteStartTag, QuoteEndTag>(spans, start);

  if (end == -1 || !spans[end].removed) {
    spans[start].removed = true;
  } else {
    spans[end].removed = false;
  }
}

_handleQuoteMisnested(List<_TagSpan> spans, int start) {
  int end = _findEndTag<QuoteStartTag, QuoteEndTag>(spans, start);

  List<_TagSpan> opening = [];

  for (int i = start + 1; i < end; i++) {
    _TagSpan span = spans[i];

    if (span.removed) continue;

    if (span.tag is CollapseStartTag) {
      opening.add(span);
    } else if (span.tag is CollapseEndTag) {
      int collapseStart =
          opening.lastIndexWhere((span) => span.tag is CollapseStartTag);

      if (collapseStart != -1) {
        opening.removeAt(collapseStart);
      } else {
        spans[end].removed = true;
        spans[start].removed = true;
        return;
      }
    }
  }

  if (opening.isNotEmpty) {
    spans[end].removed = true;
    spans[start].removed = true;
  }
}

_findLinkEndTag(List<_TagSpan> spans, int start) {
  int end = _findEndTag<LinkStartTag, LinkEndTag>(spans, start);

  for (int i = start; i < end - start; i++) {
    final span = spans[i];
    if (!span.removed &&
        span.tag is! BoldStartTag &&
        span.tag is! BoldEndTag &&
        span.tag is! FontStartTag &&
        span.tag is! FontEndTag &&
        span.tag is! ColorStartTag &&
        span.tag is! ColorEndTag &&
        span.tag is! SizeStartTag &&
        span.tag is! SizeEndTag &&
        span.tag is! UnderlineStartTag &&
        span.tag is! UnderlineEndTag &&
        span.tag is! ItalicStartTag &&
        span.tag is! ItalicEndTag &&
        span.tag is! DeleteStartTag &&
        span.tag is! DeleteEndTag &&
        span.tag is! ImageTag) {
      spans[start].removed = true;
      spans[end].removed = true;
      break;
    }
  }
}

int _findEndTag<StartTag, EndTag>(List<_TagSpan> spans, int start) {
  int depth = 1;
  for (int i = start; i < spans.length; i++) {
    if (spans[i].tag is StartTag) {
      depth += 1;
    } else if (spans[i].tag is EndTag) {
      if (depth == 2) return i;
      depth -= 1;
    }
  }
  return -1;
}

class _TagSpan {
  final Tag tag;
  final int start;
  final int end;

  bool removed = false;

  _TagSpan(this.tag, this.start, this.end, {this.removed});

  _TagSpan.fromMatch(this.tag, Match match, {this.removed})
      : start = match.start,
        end = match.end;

  @override
  String toString() {
    return '$tag($start, $end)';
  }
}
