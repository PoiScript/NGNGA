import 'dart:collection';

import 'tag.dart';

RegExp boldRegExp = RegExp(
  r"\[b\](.*?)\[/b\]",
  multiLine: true,
  dotAll: true,
);

RegExp italicsRegExp = RegExp(
  r"\[i\](.*?)\[/i\]",
  multiLine: true,
  dotAll: true,
);

RegExp deleteRegExp = RegExp(
  r"\[del\](.*?)\[/del\]",
  multiLine: true,
  dotAll: true,
);

RegExp underlineRegExp = RegExp(
  r"\[u\](.*?)\[/u\]",
  multiLine: true,
  dotAll: true,
);

RegExp headingRegExp = RegExp(
  r"\[h\](.*?)\[/h\]",
  multiLine: true,
  dotAll: true,
);

RegExp colorRegExp = RegExp(
  r"\[color=([^\s\]]*)?\](.*?)\[/color\]",
  multiLine: true,
  dotAll: true,
);

RegExp sizeRegExp = RegExp(
  r"\[size=([^\s\]]*)?\](.*?)\[/size\]",
  multiLine: true,
  dotAll: true,
);

RegExp quoteRegExp = RegExp(
  r"\[quote\](.*?)\[/quote\]",
  multiLine: true,
  dotAll: true,
);

RegExp tableRegExp = RegExp(
  r"\[table\](.*?)\[/table\]",
  multiLine: true,
  dotAll: true,
);

RegExp collapseRegExp = RegExp(
  r"\[collapse(=[^\]]*)?\](.*?)\[/collapse\]",
  multiLine: true,
  dotAll: true,
);

RegExp uidRegExp = RegExp(r"(Post by )?\[uid=(\d*)\](.*?)\[/uid\]");
RegExp pidRegExp =
    RegExp(r"(Reply to )?\[pid=(\d*),(\d*),(\d*)\](.*?)\[/pid\]");
RegExp metionsRegExp = RegExp(r"\[@([^\s\]]*?)\]");
RegExp fontRegExp = RegExp(r"\[font(=[^\s\]]*)?\](.*?)\[/font\]");
RegExp imageRegExp = RegExp(r"\[img\](.*?)\[/img\]");
RegExp stickerRegExp = RegExp(r"\[s:([^\s\]]*?)\]");
RegExp linkRegExp = RegExp(r"\[url(=[^\s\]]*)?\](.*?)\[/url\]");

LinkedList<Tag> parseBBCode(String content) {
  LinkedList<Tag> tags = LinkedList();

  _parseBlock(content, tags);

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

  for (RegExpMatch match in quoteRegExp.allMatches(content)) {
    _tags.add(_TagWithPosition(
      QuoteStart(),
      match.start,
      match.start + "[quote]".length,
    ));
    _tags.add(_TagWithPosition(
      QuoteEnd(),
      match.end - "[/quote]".length,
      match.end,
    ));
  }

  for (RegExpMatch match in collapseRegExp.allMatches(content)) {
    _tags.add(_TagWithPosition(
      CollapseStart(match[1]?.substring(1)),
      match.start,
      match.start + "[collapse]".length + (match[1]?.length ?? 0),
    ));
    _tags.add(_TagWithPosition(
      CollapseEnd(),
      match.end - "[/collapse]".length,
      match.end,
    ));
  }

  for (RegExpMatch match in boldRegExp.allMatches(content)) {
    _tags.add(_TagWithPosition(
      BoldStart(),
      match.start,
      match.start + "[b]".length,
    ));
    _tags.add(_TagWithPosition(
      BoldEnd(),
      match.end - "[/b]".length,
      match.end,
    ));
  }

  for (RegExpMatch match in italicsRegExp.allMatches(content)) {
    _tags.add(_TagWithPosition(
      ItalicStart(),
      match.start,
      match.start + "[i]".length,
    ));
    _tags.add(_TagWithPosition(
      ItalicEnd(),
      match.end - "[/i]".length,
      match.end,
    ));
  }

  for (RegExpMatch match in deleteRegExp.allMatches(content)) {
    _tags.add(_TagWithPosition(
      DeleteStart(),
      match.start,
      match.start + "[del]".length,
    ));
    _tags.add(_TagWithPosition(
      DeleteEnd(),
      match.end - "[/del]".length,
      match.end,
    ));
  }

  for (RegExpMatch match in underlineRegExp.allMatches(content)) {
    _tags.add(_TagWithPosition(
      UnderlineStart(),
      match.start,
      match.start + "[u]".length,
    ));
    _tags.add(_TagWithPosition(
      UnderlineEnd(),
      match.end - "[/u]".length,
      match.end,
    ));
  }

  for (RegExpMatch match in sizeRegExp.allMatches(content)) {
    _tags.add(_TagWithPosition(
      SizeStart(),
      match.start,
      match.start + "[size=]".length + (match[1]?.length ?? 0),
    ));
    _tags.add(_TagWithPosition(
      SizeEnd(),
      match.end - "[/size]".length,
      match.end,
    ));
  }

  for (RegExpMatch match in colorRegExp.allMatches(content)) {
    _tags.add(_TagWithPosition(
      ColorStart(),
      match.start,
      match.start + "[color=]".length + (match[1]?.length ?? 0),
    ));
    _tags.add(_TagWithPosition(
      ColorEnd(),
      match.end - "[/color]".length,
      match.end,
    ));
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

  for (RegExpMatch match in linkRegExp.allMatches(content)) {
    if (match[1] == null) {
      _tags.add(_TagWithPosition(
        PlainLink(match[2]),
        match.start,
        match.end,
      ));
    } else {
      _tags.add(_TagWithPosition(
        LinkStart(match[1]),
        match.start,
        match.start + "[url]".length + match[1].length,
      ));
      _tags.add(_TagWithPosition(
        Text(match[2]),
        match.start + "[url]".length + match[1].length,
        match.end - "[/url]".length,
      ));
      _tags.add(_TagWithPosition(
        LinkEnd(),
        match.end - "[/url]".length,
        match.end,
      ));
    }
  }

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

  for (RegExpMatch match in uidRegExp.allMatches(content)) {
    _tags.add(_TagWithPosition(
      Uid(int.parse(match[2]), match[3]),
      match.start,
      match.end,
    ));
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
}
