import 'package:html_unescape/html_unescape.dart';

import 'tag.dart';
import 'sticker.dart';

final RegExp headingRegExp = RegExp(r"===(.*?)===");

final RegExp alignStartRegExp = RegExp(r"\[align=([^\s\]]*)\]");
final RegExp sizeStartRegExp = RegExp(r"\[size=([^\s\]]*)\]");
final RegExp fontStartRegExp = RegExp(r"\[font=([^\s\]]*)\]");
final RegExp colorStartRegExp = RegExp(r"\[color=([^\s\]]*)\]");
final RegExp collapseStartRegExp = RegExp(r"\[collapse(=[^\]]*)?\]");
final RegExp linkRegExp = RegExp(r"\[url(=[^\s\]]*)?\]([^\[\]]*?)\[/url\]");

final RegExp uidRegExp = RegExp(r"\[uid=(\d*)\](.*?)\[/uid\]");
final RegExp pidRegExp = RegExp(r"\[pid=(\d*),(\d*),(\d*)\](.*?)\[/pid\]");
final RegExp metionsRegExp = RegExp(r"\[@([^\s\]]*?)\]");
final RegExp imageRegExp = RegExp(r"\[img\]([^\[\]]*?)\[/img\]");
final RegExp stickerRegExp = RegExp(r"\[s:([^\s\]]*?)\]");

final RegExp ruleRegExp = RegExp(r"^\s*={5,}\s*$", multiLine: true);

// [pid=xxx,xxx,xxx]Reply[/pid] [b]Post by [uid=xxx]xxx[/uid] (xx-xx-xx xx:xx):[/b]
RegExp replyRegExp1 = RegExp(
  r"\[pid=(\d*),(\d*),(\d*)\]Reply\[/pid\] \[b\]Post by \[uid=(\d*)\](.*?)\[/uid\] \((\d{4}-\d{2}-\d{2} \d{2}:\d{2})\):\[/b\]",
);

// [b]Reply to [pid=xxxx,xxxx,xxx]Reply[/pid] Post by [uid=xxx]xxxx[/uid] (xx-xx-xx xx:xx)[/b]
RegExp replyRegExp2 = RegExp(
  r"\[b\]Reply to \[pid=(\d*),(\d*),(\d*)\]Reply\[/pid\] Post by \[uid=(\d*)\](.*?)\[/uid\] \((\d{4}-\d{2}-\d{2} \d{2}:\d{2})\)\[/b\]",
);

// [pid=xxx,xxx,xxx]Reply[/pid] [b]Post by [uid]xxx[/uid][color=gray](xxx楼)[/color] (xx-xx-xx xx:xx):[/b]
RegExp replyRegExp3 = RegExp(
  r"\[pid=(\d*),(\d*),(\d*)\]Reply\[/pid\] \[b\]Post by \[uid\](.*?)\[/uid\]\[color=gray\]\(\d*楼\)\[/color\] \((\d{4}-\d{2}-\d{2} \d{2}:\d{2})\):\[/b\]",
);

// [pid=xxx,xxx,xxx]Reply[/pid] [b]Post by [uid=-xxx]xxx[/uid][color=gray](xxx楼)[/color] (xx-xx-xx xx:xx):[/b]
RegExp replyRegExp4 = RegExp(
  r"\[pid=(\d*),(\d*),(\d*)\]Reply\[/pid\] \[b\]Post by \[uid=(-\d*)\](.*?)\[/uid\]\[color=gray\]\(\d*楼\)\[/color\] \((\d{4}-\d{2}-\d{2} \d{2}:\d{2})\):\[/b\]",
);

// [b]Reply to [pid=xxxx,xxxx,xxx]Reply[/pid] Post by [uid]xxxx[/uid][color=gray](xxx楼)[/color] (xx-xx-xx xx:xx)[/b]
RegExp replyRegExp5 = RegExp(
  r"\[b\]Reply to \[pid=(\d*),(\d*),(\d*)\]Reply\[/pid\] Post by \[uid\](.*?)\[/uid\]\[color=gray\]\(\d*楼\)\[/color\] \((\d{4}-\d{2}-\d{2} \d{2}:\d{2})\)\[/b\]",
);

// [tid=xxx]Topic[/tid] [b]Post by [uid=xxx]xxx[/uid] (xx-xx-xx xx:xx):[/b]
RegExp replyRegExp6 = RegExp(
  r"\[tid=(\d*)\]Topic\[/tid\] \[b\]Post by \[uid=(\d*)\](.*?)\[/uid\] \((\d{4}-\d{2}-\d{2} \d{2}:\d{2})\):\[/b\]",
);

// [b]Reply to [tid=xxx]Topic[/tid] Post by [uid=xxx]xxx[/uid] (xxxx-xx-xx xx:xx)[/b]
RegExp replyRegExp7 = RegExp(
  r"\[b\]Reply to \[tid=(\d*)\]Topic\[/tid\] Post by \[uid=(\d*)\](.*?)\[/uid\] \((\d{4}-\d{2}-\d{2} \d{2}:\d{2})\)\[/b\]",
);

final unescape = new HtmlUnescape();

List<Tag> parseBBCode(String raw) {
  List<_TagSpan> spans = List();

  String content = unescape.convert(unescape.convert(raw));

  while (true) {
    var match = replyRegExp1.firstMatch(content);

    if (match == null) break;

    spans.add(_TagSpan(
      Reply(
        postId: int.parse(match[1]),
        topicId: int.parse(match[2]),
        pageIndex: int.parse(match[3]),
        userId: int.parse(match[4]),
        username: match[5],
        dateTime: DateTime.parse(match[6]),
      ),
      match.start,
      match.start + 1,
      false,
    ));
    content =
        "${content.substring(0, match.start)}_${content.substring(match.end)}";
  }

  while (true) {
    var match = replyRegExp2.firstMatch(content);

    if (match == null) break;

    spans.add(_TagSpan(
      Reply(
        postId: int.parse(match[1]),
        topicId: int.parse(match[2]),
        pageIndex: int.parse(match[3]),
        userId: int.parse(match[4]),
        username: match[5],
        dateTime: DateTime.parse(match[6]),
      ),
      match.start,
      match.start + 1,
      false,
    ));
    content =
        "${content.substring(0, match.start)}_${content.substring(match.end)}";
  }

  while (true) {
    var match = replyRegExp3.firstMatch(content);

    if (match == null) break;

    spans.add(_TagSpan(
      Reply(
        postId: int.parse(match[1]),
        topicId: int.parse(match[2]),
        pageIndex: int.parse(match[3]),
        dateTime: DateTime.parse(match[5]),
      ),
      match.start,
      match.start + 1,
      false,
    ));
    content =
        "${content.substring(0, match.start)}_${content.substring(match.end)}";
  }

  while (true) {
    var match = replyRegExp4.firstMatch(content);

    if (match == null) break;

    spans.add(_TagSpan(
      Reply(
        postId: int.parse(match[1]),
        topicId: int.parse(match[2]),
        pageIndex: int.parse(match[3]),
        userId: int.parse(match[4]),
        dateTime: DateTime.parse(match[6]),
      ),
      match.start,
      match.start + 1,
      false,
    ));
    content =
        "${content.substring(0, match.start)}_${content.substring(match.end)}";
  }

  while (true) {
    var match = replyRegExp5.firstMatch(content);

    if (match == null) break;

    spans.add(_TagSpan(
      Reply(
        postId: int.parse(match[1]),
        topicId: int.parse(match[2]),
        pageIndex: int.parse(match[3]),
        dateTime: DateTime.parse(match[5]),
      ),
      match.start,
      match.start + 1,
      false,
    ));
    content =
        "${content.substring(0, match.start)}_${content.substring(match.end)}";
  }

  while (true) {
    var match = replyRegExp6.firstMatch(content);

    if (match == null) break;

    spans.add(_TagSpan(
      Reply(
        postId: 0,
        topicId: int.parse(match[1]),
        userId: int.parse(match[2]),
        username: match[3],
        dateTime: DateTime.parse(match[4]),
      ),
      match.start,
      match.start + 1,
      false,
    ));
    content =
        "${content.substring(0, match.start)}_${content.substring(match.end)}";
  }

  while (true) {
    var match = replyRegExp7.firstMatch(content);

    if (match == null) break;

    spans.add(_TagSpan(
      Reply(
        postId: 0,
        topicId: int.parse(match[1]),
        userId: int.parse(match[2]),
        username: match[3],
        dateTime: DateTime.parse(match[4]),
      ),
      match.start,
      match.start + 1,
      false,
    ));
    content =
        "${content.substring(0, match.start)}_${content.substring(match.end)}";
  }

  spans
    // styling
    ..addAll("[b]".allMatches(content).map(
          (match) => _TagSpan.fromMatch(BoldStart(), match, false),
        ))
    ..addAll("[/b]".allMatches(content).map(
          (match) => _TagSpan.fromMatch(BoldEnd(), match, true),
        ))
    ..addAll("[i]".allMatches(content).map(
          (match) => _TagSpan.fromMatch(ItalicStart(), match, false),
        ))
    ..addAll("[/i]".allMatches(content).map(
          (match) => _TagSpan.fromMatch(ItalicEnd(), match, true),
        ))
    ..addAll("[u]".allMatches(content).map(
          (match) => _TagSpan.fromMatch(UnderlineStart(), match, false),
        ))
    ..addAll("[/u]".allMatches(content).map(
          (match) => _TagSpan.fromMatch(UnderlineEnd(), match, true),
        ))
    ..addAll("[del]".allMatches(content).map(
          (match) => _TagSpan.fromMatch(DeleteStart(), match, false),
        ))
    ..addAll("[/del]".allMatches(content).map(
          (match) => _TagSpan.fromMatch(DeleteEnd(), match, true),
        ))
    ..addAll(sizeStartRegExp.allMatches(content).map(
          (match) => _TagSpan.fromMatch(SizeStart(), match, false),
        ))
    ..addAll("[/size]".allMatches(content).map(
          (match) => _TagSpan.fromMatch(SizeEnd(), match, true),
        ))
    ..addAll(fontStartRegExp.allMatches(content).map(
          (match) => _TagSpan.fromMatch(FontStart(), match, false),
        ))
    ..addAll("[/font]".allMatches(content).map(
          (match) => _TagSpan.fromMatch(FontEnd(), match, true),
        ))
    ..addAll(colorStartRegExp.allMatches(content).map(
          (match) => _TagSpan.fromMatch(ColorStart(match[1]), match, false),
        ))
    ..addAll("[/color]".allMatches(content).map(
          (match) => _TagSpan.fromMatch(ColorEnd(), match, true),
        ))
    ..addAll("[h]".allMatches(content).map(
          (match) => _TagSpan.fromMatch(HeadingStart(), match, false),
        ))
    ..addAll("[/h]".allMatches(content).map(
          (match) => _TagSpan.fromMatch(HeadingEnd(), match, true),
        ))
    // containers
    // ..addAll(alignStartRegExp.allMatches(content).map(
    //       (match) => _TagSpan.fromMatch(AlignStart(), match, false),
    //     ))
    // ..addAll("[/align]".allMatches(content).map(
    //       (match) => _TagSpan.fromMatch(AlignEnd(), match, true),
    //     ))
    // ..addAll(headingRegExp.allMatches(content).expand((match) => [
    //       _TagSpan(HeadingStart(), match.start, match.start + 3, false),
    //       _TagSpan(HeadingEnd(), match.end - 3, match.end, true),
    //     ]))
    ..addAll("[quote]".allMatches(content).map(
          (match) => _TagSpan.fromMatch(QuoteStart(), match, false),
        ))
    ..addAll("[/quote]".allMatches(content).map(
          (match) => _TagSpan.fromMatch(QuoteEnd(), match, true),
        ))
    ..addAll(collapseStartRegExp.allMatches(content).map(
          (match) => _TagSpan.fromMatch(
              CollapseStart(match[1]?.substring(1)), match, false),
        ))
    ..addAll("[/collapse]".allMatches(content).map(
          (match) => _TagSpan.fromMatch(CollapseEnd(), match, true),
        ))
    ..addAll(linkRegExp.allMatches(content).expand((match) => [
          _TagSpan(
            LinkStart(match[1]?.substring(1) ?? match[2]),
            match.start,
            match.start + 5 + (match[1]?.length ?? 0),
            false,
          ),
          _TagSpan(LinkEnd(), match.end - 6, match.end, false),
        ]))
    // inline objects
    ..addAll(ruleRegExp.allMatches(content).map(
          (match) => _TagSpan.fromMatch(Rule(), match, false),
        ))
    ..addAll(uidRegExp.allMatches(content).map(
          (match) => _TagSpan.fromMatch(
              Uid(int.parse(match[1]), match[2]), match, false),
        ))
    ..addAll(metionsRegExp.allMatches(content).map(
          (match) => _TagSpan.fromMatch(Metions(match[1]), match, false),
        ))
    ..addAll(imageRegExp.allMatches(content).map(
          (match) => _TagSpan.fromMatch(
            imageUrlToPath.containsKey(match[1])
                ? Sticker(imageUrlToPath[match[1]])
                : Image(match[1]),
            match,
            false,
          ),
        ))
    ..addAll(stickerRegExp
        .allMatches(content)
        .where((match) => stickerNameToPath.containsKey(match[1]))
        .map(
          (match) => _TagSpan.fromMatch(
              Sticker(stickerNameToPath[match[1]]), match, false),
        ))
    ..addAll(pidRegExp.allMatches(content).map(
          (match) => _TagSpan.fromMatch(
            Pid(int.parse(match[2]), int.parse(match[3]), int.parse(match[4]),
                match[5]),
            match,
            false,
          ),
        ));

  if (spans.isEmpty) return [ParagraphStart(), Text(content), ParagraphEnd()];

  spans.sort((a, b) => a.start.compareTo(b.start));

  for (int i = 0; i < spans.length; i++) {
    if (spans[i].removed) continue;

    switch (spans[i].tag.type) {
      case TagType.QuoteStart:
        _findQuoteEndTag(spans, i);
        break;
      case TagType.CollapseStart:
        _findCollapseEndTag(spans, i);
        break;
      case TagType.BoldStart:
        _findStylingEndTag(spans, i, TagType.BoldStart, TagType.BoldEnd);
        break;
      case TagType.FontStart:
        _findStylingEndTag(spans, i, TagType.FontStart, TagType.FontEnd);
        break;
      case TagType.ColorStart:
        _findStylingEndTag(spans, i, TagType.ColorStart, TagType.ColorEnd);
        break;
      case TagType.SizeStart:
        _findStylingEndTag(spans, i, TagType.SizeStart, TagType.SizeEnd);
        break;
      case TagType.UnderlineStart:
        _findStylingEndTag(
            spans, i, TagType.UnderlineStart, TagType.UnderlineEnd);
        break;
      case TagType.ItalicStart:
        _findStylingEndTag(spans, i, TagType.ItalicStart, TagType.ItalicEnd);
        break;
      case TagType.DeleteStart:
        _findStylingEndTag(spans, i, TagType.DeleteStart, TagType.DeleteEnd);
        break;
      case TagType.HeadingStart:
        _findStylingEndTag(spans, i, TagType.HeadingStart, TagType.HeadingEnd);
        break;
      case TagType.TableStart:
        // TODO: Handle this case.
        break;
      case TagType.TableRowStart:
        // TODO: Handle this case.
        break;
      case TagType.TableCellStart:
        // TODO: Handle this case.
        break;
      case TagType.AlignStart:
        _findAlignEndTag(spans, i);
        break;
      default:
        break;
    }
  }

  for (int i = 0; i < spans.length; i++) {
    if (spans[i].removed) continue;

    switch (spans[i].tag.type) {
      case TagType.AlignStart:
        _handleAlignMisnested(spans, i);
        break;
      case TagType.QuoteStart:
        _handleQuoteMisnested(spans, i);
        break;
      case TagType.TableStart:
        // TODO: Handle this case.
        break;
      case TagType.TableRowStart:
        // TODO: Handle this case.
        break;
      case TagType.TableCellStart:
        // TODO: Handle this case.
        break;
      default:
        break;
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
          tags.add(ParagraphStart());
          openingParagraph = true;
        }
        tags.add(Text(text));
      }
    }

    lastEnd = span.end;

    switch (span.tag.type) {
      case TagType.HeadingStart:
      case TagType.HeadingEnd:
      case TagType.Reply:
      case TagType.Rule:
      case TagType.CollapseStart:
      case TagType.CollapseEnd:
      case TagType.AlignStart:
      case TagType.AlignEnd:
      case TagType.TableStart:
      case TagType.TableEnd:
      case TagType.QuoteStart:
      case TagType.QuoteEnd:
        if (openingParagraph) {
          tags.add(ParagraphEnd());
          openingParagraph = false;
        }
        break;
      default: // inlines
        if (!openingParagraph) {
          tags.add(ParagraphStart());
          openingParagraph = true;
        }
        break;
    }

    tags.add(span.tag);
  }

  if (lastEnd < content.length) {
    String text = content.substring(lastEnd).trim();
    if (text.isNotEmpty) {
      if (!openingParagraph) {
        tags.add(ParagraphStart());
        openingParagraph = true;
      }
      tags.add(Text(text));
    }
  }

  if (openingParagraph) tags.add(ParagraphEnd());

  return tags;
}

_findStylingEndTag(
    List<_TagSpan> spans, int start, TagType startTag, TagType endTag) {
  int end = _findEndTag(spans, start, startTag, endTag);

  if (end == -1 || !spans[end].removed) {
    spans[start].removed = true;
  } else {
    spans[end].removed = false;
  }
}

_findAlignEndTag(List<_TagSpan> spans, int start) {
  int end = _findEndTag(spans, start, TagType.AlignStart, TagType.AlignEnd);

  if (end == -1 || !spans[end].removed) {
    spans[start].removed = true;
  } else {
    spans[end].removed = false;
  }
}

_handleAlignMisnested(List<_TagSpan> spans, int start) {
  int end = _findEndTag(spans, start, TagType.AlignStart, TagType.AlignEnd);

  List<_TagSpan> opening = [];

  for (int i = start + 1; i < end; i++) {
    _TagSpan span = spans[i];

    if (span.removed) continue;

    if (span.tag.type == TagType.CollapseStart ||
        span.tag.type == TagType.QuoteStart) {
      opening.add(span);
    } else if (span.tag.type == TagType.CollapseEnd) {
      int collapseStart = opening
          .lastIndexWhere((span) => span.tag.type == TagType.CollapseStart);

      if (collapseStart != -1) {
        opening.removeAt(collapseStart);
      } else {
        spans[end].removed = true;
        spans[start].removed = true;
        return;
      }
    } else if (span.tag.type == TagType.QuoteEnd) {
      int quoteStart =
          opening.lastIndexWhere((span) => span.tag.type == TagType.QuoteEnd);

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
  int end = spans.indexWhere((t) => t.tag.type == TagType.CollapseEnd, start);

  if (end != -1 && spans[end].removed) {
    spans[end].removed = false;
  } else {
    spans[start].removed = true;
  }
}

_findQuoteEndTag(List<_TagSpan> spans, int start) {
  int end = _findEndTag(spans, start, TagType.QuoteStart, TagType.QuoteEnd);

  if (end == -1 || !spans[end].removed) {
    spans[start].removed = true;
  } else {
    spans[end].removed = false;
  }
}

_handleQuoteMisnested(List<_TagSpan> spans, int start) {
  int end = _findEndTag(spans, start, TagType.QuoteStart, TagType.QuoteEnd);

  List<_TagSpan> opening = [];

  for (int i = start + 1; i < end; i++) {
    _TagSpan span = spans[i];

    if (span.removed) continue;

    if (span.tag.type == TagType.CollapseStart) {
      opening.add(span);
    } else if (span.tag.type == TagType.CollapseEnd) {
      int collapseStart = opening
          .lastIndexWhere((span) => span.tag.type == TagType.CollapseStart);

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
  const allowedChildren = [
    BoldStart,
    BoldEnd,
    FontStart,
    FontEnd,
    ColorStart,
    ColorEnd,
    SizeStart,
    SizeEnd,
    UnderlineStart,
    UnderlineEnd,
    ItalicStart,
    ItalicEnd,
    DeleteStart,
    DeleteEnd,
    Image,
  ];

  int end = _findEndTag(spans, start, TagType.LinkStart, TagType.LinkEnd);

  for (int i = start; i < end - start; i++) {
    final tag = spans[i];
    if (!tag.removed && !allowedChildren.contains(tag.tag.type)) {
      spans[start].removed = true;
      spans[end].removed = true;
      break;
    }
  }
}

int _findEndTag(
  List<_TagSpan> spans,
  int start,
  TagType startTag,
  TagType endTag,
) {
  int depth = 1;
  for (int i = start; i < spans.length; i++) {
    if (spans[i].tag.type == startTag) {
      depth += 1;
    } else if (spans[i].tag.type == endTag) {
      depth -= 1;

      if (depth == 1) return i;
    }
  }
  return -1;
}

class _TagSpan {
  final Tag tag;
  final int start;
  final int end;

  bool removed = false;

  _TagSpan(this.tag, this.start, this.end, this.removed);

  _TagSpan.fromMatch(this.tag, Match match, this.removed)
      : start = match.start,
        end = match.end;

  @override
  String toString() {
    return "$tag($start, $end)";
  }
}
