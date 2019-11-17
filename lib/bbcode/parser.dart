import 'dart:collection';

import 'package:html_unescape/html_unescape.dart';

import 'tag.dart';
import 'sticker.dart';

RegExp uidRegExp = RegExp(r"(Post by )?\[uid=(\d*)\](.*?)\[/uid\]");
RegExp pidRegExp =
    RegExp(r"(Reply to )?\[pid=(\d*),(\d*),(\d*)\](.*?)\[/pid\]");
RegExp metionsRegExp = RegExp(r"\[@([^\s\]]*?)\]");
RegExp fontRegExp = RegExp(r"\[font(=[^\s\]]*)?\](.*?)\[/font\]");
RegExp imageRegExp = RegExp(r"\[img\](.*?)\[/img\]");
RegExp stickerRegExp = RegExp(r"\[s:([^\s\]]*?)\]");
RegExp linkRegExp = RegExp(r"\[url(=[^\s\]]*)?\](.*?)\[/url\]");

RegExp replyRegExp1 = RegExp(
    r"\[pid=(\d*),(\d*),(\d*)\]Reply\[/pid\] \[b\]Post by \[uid=(\d*)\](.*?)\[/uid\] \((\d{4}-\d{2}-\d{2} \d{2}:\d{2})\):\[/b\]");
RegExp replyRegExp2 = RegExp(
    r"\[b\]Reply to \[pid=(\d*),(\d*),(\d*)\]Reply\[/pid\] Post by \[uid=(\d*)\](.*?)\[/uid\] \((\d{4}-\d{2}-\d{2} \d{2}:\d{2})\)\[/b\]");

LinkedList<Tag> parseBBCode(String content) {
  LinkedList<Tag> tags = LinkedList();

  var unescape = new HtmlUnescape();
  var unescaped = unescape.convert(content);

  _parseBlock(unescaped, tags);

  var _pre = tags.first;

  while (_pre != null) {
    var pre = _pre.next;
    if (_pre.type == TagType.Text) {
      _parseInlines((_pre as Text).content, _pre);
    }
    _pre = pre;
  }

  return tags;
}

_parseBlock(String content, LinkedList<Tag> tags) {
  List<_TagWithPosition> _tags = List();

  for (var match in replyRegExp1.allMatches(content)) {
    _tags.add(_TagWithPosition(
      Reply(
        postId: int.parse(match[1]),
        topicId: int.parse(match[2]),
        pageIndex: int.parse(match[3]),
        userId: int.parse(match[4]),
        username: match[5],
        dateTime: DateTime.parse(match[6]),
      ),
      match.start,
      match.end,
    ));
    content =
        "${content.substring(0, match.start)}${'_' * (match.end - match.start)}${content.substring(match.end)}";
  }

  for (var match in replyRegExp2.allMatches(content)) {
    _tags.add(_TagWithPosition(
      Reply(
        postId: int.parse(match[1]),
        topicId: int.parse(match[2]),
        pageIndex: int.parse(match[3]),
        userId: int.parse(match[4]),
        username: match[5],
        dateTime: DateTime.parse(match[6]),
      ),
      match.start,
      match.end,
    ));
    content =
        "${content.substring(0, match.start)}${'_' * (match.end - match.start)}${content.substring(match.end)}";
  }

  var lastEnd = 0;

  while (true) {
    var start = content.indexOf("[quote]", lastEnd);

    if (start == -1) {
      break;
    }

    var end = content.indexOf("[/quote]", start);

    if (end == -1) {
      break;
    }

    _tags.add(_TagWithPosition(QuoteStart(), start, start + "[quote]".length));
    _tags.add(_TagWithPosition(QuoteEnd(), end, end + "[/quote]".length));

    lastEnd = end + "[/quote]".length;
  }

  lastEnd = 0;

  while (true) {
    var start = content.indexOf("[collapse", lastEnd);

    if (start == -1) {
      break;
    }

    var bracketEnd = content.indexOf("]", start + "[collapse".length);

    if (bracketEnd == -1) {
      break;
    }

    String description;

    if (bracketEnd != start + "[collapse".length) {
      if (content[start + "[collapse".length] != "=") {
        lastEnd = bracketEnd;
        continue;
      }
      description = content.substring(start + "[collapse=".length, bracketEnd);
    }

    var end = content.indexOf("[/collapse]", bracketEnd + 1);

    if (end == -1) {
      break;
    }

    _tags.add(
        _TagWithPosition(CollapseStart(description), start, bracketEnd + 1));
    _tags.add(_TagWithPosition(CollapseEnd(), end, end + "[/collapse]".length));

    lastEnd = end + "[/collapse]".length;
  }

  lastEnd = 0;

  while (true) {
    var start = content.indexOf("[b]", lastEnd);

    if (start == -1) {
      break;
    }

    var end = content.indexOf("[/b]", start);

    if (end == -1) {
      break;
    }

    _tags.add(_TagWithPosition(BoldStart(), start, start + "[b]".length));
    _tags.add(_TagWithPosition(BoldEnd(), end, end + "[/b]".length));

    lastEnd = end + "[/b]".length;
  }

  lastEnd = 0;

  while (true) {
    var start = content.indexOf("[i]", lastEnd);

    if (start == -1) {
      break;
    }

    var end = content.indexOf("[/i]", start);

    if (end == -1) {
      break;
    }

    _tags.add(_TagWithPosition(ItalicStart(), start, start + "[i]".length));
    _tags.add(_TagWithPosition(ItalicEnd(), end, end + "[/i]".length));

    lastEnd = end + "[/i]".length;
  }

  lastEnd = 0;

  while (true) {
    var start = content.indexOf("[del]", lastEnd);

    if (start == -1) {
      break;
    }

    var end = content.indexOf("[/del]", start);

    if (end == -1) {
      break;
    }

    _tags.add(_TagWithPosition(DeleteStart(), start, start + "[del]".length));
    _tags.add(_TagWithPosition(DeleteEnd(), end, end + "[/del]".length));

    lastEnd = end + "[/del]".length;
  }

  lastEnd = 0;

  while (true) {
    var start = content.indexOf("[u]", lastEnd);

    if (start == -1) {
      break;
    }

    var end = content.indexOf("[/u]", start);

    if (end == -1) {
      break;
    }

    _tags.add(_TagWithPosition(UnderlineStart(), start, start + "[u]".length));
    _tags.add(_TagWithPosition(UnderlineEnd(), end, end + "[/u]".length));

    lastEnd = end + "[/u]".length;
  }

  lastEnd = 0;

  while (true) {
    var start = content.indexOf("[size=", lastEnd);

    if (start == -1) {
      break;
    }

    var bracketEnd = content.indexOf("]", start);

    var sizeStr = content.substring(start + "[size=".length, bracketEnd).trim();

    if (bracketEnd == -1) {
      break;
    }

    if (sizeStr.endsWith("%")) {
      sizeStr = sizeStr.substring(0, sizeStr.length - 1);
    }

    int size = int.tryParse(sizeStr);

    if (size == null) {
      lastEnd = bracketEnd;
      continue;
    }

    var end = content.indexOf("[/size]", start);

    if (end == -1) {
      break;
    }

    _tags.add(_TagWithPosition(SizeStart(), start, bracketEnd + 1));
    _tags.add(_TagWithPosition(SizeEnd(), end, end + "[/size]".length));

    lastEnd = end + "[/size]".length;
  }

  lastEnd = 0;

  while (true) {
    var start = content.indexOf("[color=", lastEnd);

    if (start == -1) {
      break;
    }

    var bracketEnd = content.indexOf("]", start);

    if (bracketEnd == -1) {
      break;
    }

    var end = content.indexOf("[/color]", start);

    if (end == -1) {
      break;
    }

    _tags.add(_TagWithPosition(
      ColorStart(
        content.substring(start + "[color=".length, bracketEnd).trim(),
      ),
      start,
      bracketEnd + 1,
    ));
    _tags.add(_TagWithPosition(ColorEnd(), end, end + "[/color]".length));

    lastEnd = end + "[/color]".length;
  }

  if (_tags.isEmpty) {
    tags.add(ParagraphStart());
    tags.add(Text(content));
    tags.add(ParagraphEnd());
  } else {
    _tags.sort((a, b) => a.start.compareTo(b.start));

    int lastEnd = 0;
    bool openingParagraph = false;

    for (_TagWithPosition tagWihtPosition in _tags) {
      if (tagWihtPosition.start != lastEnd) {
        var text = content.substring(lastEnd, tagWihtPosition.start).trim();
        if (text.isNotEmpty) {
          if (!openingParagraph) {
            tags.add(ParagraphStart());
            openingParagraph = true;
          }
          tags.add(Text(text));
        }
      }

      lastEnd = tagWihtPosition.end;

      switch (tagWihtPosition.tag.type) {
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

      tags.add(tagWihtPosition.tag);
    }

    if (lastEnd < content.length) {
      var text = content.substring(lastEnd).trim();
      if (text.isNotEmpty) {
        if (!openingParagraph) {
          tags.add(ParagraphStart());
          openingParagraph = true;
        }
        tags.add(Text(text));
      }
    }

    if (openingParagraph) {
      tags.add(ParagraphEnd());
    }
  }
}

_parseInlines(String content, Tag previous) {
  List<_TagWithPosition> _tags = List();

  var lastEnd = 0;

  while (true) {
    var start = content.indexOf("[url", lastEnd);

    if (start == -1) {
      break;
    }

    var bracketEnd = content.indexOf("]", start);

    if (bracketEnd == -1) {
      break;
    }

    String url;

    if (bracketEnd != start + "[url".length) {
      if (content[start + "[url".length] != "=") {
        lastEnd = bracketEnd;
        continue;
      }
      url = content.substring(start + "[url".length, bracketEnd).trim();
    }

    var end = content.indexOf("[/url]", bracketEnd);

    if (end == -1) {
      break;
    }

    if (url == null) {
      _tags.add(_TagWithPosition(
        PlainLink(content.substring(bracketEnd + 1, end)),
        start,
        end + "[/url]".length,
      ));
    } else {
      // TODO: call parse_link_content
      _tags.add(_TagWithPosition(LinkStart(url), start, bracketEnd));
      _tags.add(_TagWithPosition(
          Text(content.substring(bracketEnd + 1, end)), bracketEnd, end));
      _tags.add(_TagWithPosition(LinkEnd(), end, end + "[/url]".length));
    }

    lastEnd = end + "[/url]".length;
  }

  lastEnd = 0;

  while (true) {
    var start = content.indexOf("[@", lastEnd);

    if (start == -1) {
      break;
    }

    var end = content.indexOf("]", start);

    if (end == -1) {
      break;
    }

    var username = content.substring(start + "[@".length, end);

    if (!username.contains("\n")) {
      _tags.add(_TagWithPosition(Metions(username), start, end + "]".length));
    }

    lastEnd = end + "]".length;
  }

  lastEnd = 0;

  while (true) {
    var start = content.indexOf("[s:", lastEnd);

    if (start == -1) {
      break;
    }

    var end = content.indexOf("]", start);

    if (end == -1) {
      break;
    }

    var sticker = content.substring(start + "[s:".length, end);

    var path = stickerNameToPath[sticker];
    if (path != null) {
      _tags.add(_TagWithPosition(Sticker(path), start, end + "]".length));
    }

    lastEnd = end + "]".length;
  }

  lastEnd = 0;

  while (true) {
    var start = content.indexOf("[img]", lastEnd);

    if (start == -1) {
      break;
    }

    var end = content.indexOf("[/img]", start);

    if (end == -1) {
      break;
    }

    var url = content.substring(start + "[img]".length, end);

    if (!url.contains("\n")) {
      if (imageUrlToPath[url] == null) {
        _tags.add(_TagWithPosition(Image(url), start, end + "[/img]".length));
      } else {
        _tags.add(_TagWithPosition(
            Sticker(imageUrlToPath[url]), start, end + "[/img]".length));
      }
    }

    lastEnd = end + "[/img]".length;
  }

  lastEnd = 0;

  while (true) {
    var start = content.indexOf("[uid=", lastEnd);

    if (start == -1) {
      break;
    }

    var bracketEnd = content.indexOf("]", start);

    if (bracketEnd == -1) {
      lastEnd = bracketEnd;
      continue;
    }

    var userId = int.tryParse(
        content.substring(start + "[uid=".length, bracketEnd).trim());

    if (userId == null) {
      lastEnd = bracketEnd;
      continue;
    }

    var end = content.indexOf("[/uid]", start);

    if (end == -1) {
      break;
    }

    _tags.add(_TagWithPosition(
      Uid(userId, content.substring(bracketEnd + 1, end).trim()),
      start,
      end + "[/uid]".length,
    ));

    lastEnd = end + "[/uid]".length;
  }

  for (RegExpMatch match in pidRegExp.allMatches(content)) {
    _tags.add(_TagWithPosition(
      Pid(
        int.parse(match[2]),
        int.parse(match[3]),
        int.parse(match[4]),
        match[5],
      ),
      match.start,
      match.end,
    ));
  }

  if (_tags.isNotEmpty) {
    _tags.sort((a, b) => a.start.compareTo(b.start));

    var _pre = previous;
    int lastEnd = 0;

    for (_TagWithPosition tagWihtPosition in _tags) {
      if (tagWihtPosition.start != lastEnd) {
        var tag = Text(content.substring(lastEnd, tagWihtPosition.start));
        _pre.insertAfter(tag);
        _pre = tag;
      }
      lastEnd = tagWihtPosition.end;
      _pre.insertAfter(tagWihtPosition.tag);
      _pre = tagWihtPosition.tag;
    }

    if (lastEnd != content.length) {
      _pre.insertAfter(Text(content.substring(lastEnd)));
    }

    previous.unlink();
  }
}

_parseLinkContent(String content, Tag previous) {
  List<_TagWithPosition> _tags = List();

  for (RegExpMatch match in metionsRegExp.allMatches(content)) {
    _tags.add(_TagWithPosition(
      Metions(match[1]),
      match.start,
      match.end,
    ));
  }

  for (RegExpMatch match in stickerRegExp.allMatches(content)) {
    _tags.add(_TagWithPosition(
      Sticker(match[1]),
      match.start,
      match.end,
    ));
  }

  for (RegExpMatch match in imageRegExp.allMatches(content)) {
    _tags.add(_TagWithPosition(
      Image(match[1]),
      match.start,
      match.end,
    ));
  }

  if (_tags.isNotEmpty) {
    _tags.sort((a, b) => a.start.compareTo(b.start));

    var _pre = previous;
    var iter = _tags.iterator;

    while (iter.moveNext()) {
      _pre.insertAfter(iter.current.tag);
      _pre = iter.current.tag;
    }
  }
}

class _TagWithPosition {
  final Tag tag;
  final int start;
  final int end;

  _TagWithPosition(this.tag, this.start, this.end);

  @override
  String toString() {
    return "$tag($start, $end)";
  }
}
