import 'dart:collection';

enum BBCodeTagType {
  // [quote] or [/quote]
  Quote,
  // [table] or [/table]
  Table,
  // [collapse] or [/collapse]
  Collapse,
  // [b] or [/b]
  Bold,
  // [font] or [/font]
  Font,
  // [color] or [/color]
  Color,
  // [size] or [/size]
  Size,
  // [u] or [/u]
  Underline,
  // [i] or [/i]
  Italics,
  // [del] or [/del]
  Delete,
  // [img] or [/img]
  Image,
  // [url] or [/url]
  Link,
  PlainLink,
  // [s:xxx]
  Sticker,
  // [h] or [/h]
  Heading,
  // [tr] or [/tr]
  TableRow,
  // [td] or [/td]
  TableCell,
  // [@xxxx]
  Metions,
  // [hr]
  Rule,
  // [pid] or [/pid]
  Pid,
  // [uid] or [/uid]
  Uid,
  // [align] or [/align]
  Align,
  Text,
  Paragraph,
}

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
  r"\[collapse(=[^\s\]]*)?\](.*?)\[/collapse\]",
  multiLine: true,
  dotAll: true,
);

RegExp metionsRegExp = RegExp(r"\[@([^\s\]]*?)\]");
RegExp fontRegExp = RegExp(r"\[font(=[^\s\]]*)?\](.*?)\[/font\]");
RegExp imageRegExp = RegExp(r"\[img\](.*?)\[/img\]");
RegExp stickerRegExp = RegExp(r"\[s:([^\s\]]*?)\]");
RegExp linkRegExp = RegExp(r"\[url(=[^\s\]]*)?\](.*?)\[/url\]");

class BBCodeTag extends LinkedListEntry<BBCodeTag> {
  final BBCodeTagType type;
  final bool beg;
  final String content;

  BBCodeTag._(this.type, this.beg, this.content);

  BBCodeTag.beg(BBCodeTagType type, [String content])
      : this._(type, true, content);
  BBCodeTag.end(BBCodeTagType type, [String content])
      : this._(type, false, content);
  BBCodeTag.leaf(BBCodeTagType type, [String content])
      : this._(type, null, content);

  BBCodeTag.collapseBeg([String content])
      : this.beg(BBCodeTagType.Collapse, content);
  BBCodeTag.collapseEnd() : this.end(BBCodeTagType.Collapse);
  BBCodeTag.quoteBeg() : this.beg(BBCodeTagType.Quote);
  BBCodeTag.quoteEnd() : this.end(BBCodeTagType.Quote);
  BBCodeTag.tableBeg() : this.beg(BBCodeTagType.Table);
  BBCodeTag.tableEnd() : this.end(BBCodeTagType.Table);
  BBCodeTag.boldBeg() : this.beg(BBCodeTagType.Bold);
  BBCodeTag.boldEnd() : this.end(BBCodeTagType.Bold);
  BBCodeTag.colorBeg(String content) : this.beg(BBCodeTagType.Color, content);
  BBCodeTag.colorEnd() : this.end(BBCodeTagType.Color);
  BBCodeTag.deleteBeg() : this.beg(BBCodeTagType.Delete);
  BBCodeTag.deleteEnd() : this.end(BBCodeTagType.Delete);
  BBCodeTag.fontBeg(String content) : this.beg(BBCodeTagType.Font, content);
  BBCodeTag.fontEnd() : this.end(BBCodeTagType.Font);
  BBCodeTag.headingBeg() : this.beg(BBCodeTagType.Heading);
  BBCodeTag.headingEnd() : this.end(BBCodeTagType.Heading);
  BBCodeTag.image(String content) : this.leaf(BBCodeTagType.Image, content);
  BBCodeTag.italicsBeg() : this.beg(BBCodeTagType.Italics);
  BBCodeTag.italicsEnd() : this.end(BBCodeTagType.Italics);
  BBCodeTag.metions(String content) : this.leaf(BBCodeTagType.Metions, content);
  BBCodeTag.sizeBeg(String content) : this.beg(BBCodeTagType.Size, content);
  BBCodeTag.sizeEnd() : this.end(BBCodeTagType.Size);
  BBCodeTag.sticker(String content) : this.leaf(BBCodeTagType.Sticker, content);
  BBCodeTag.tableRowBeg() : this.beg(BBCodeTagType.TableRow);
  BBCodeTag.tableRowEnd() : this.end(BBCodeTagType.TableRow);
  BBCodeTag.tableCellBeg(String content)
      : this.beg(BBCodeTagType.TableCell, content);
  BBCodeTag.tableCellEnd() : this.end(BBCodeTagType.TableCell);
  BBCodeTag.underlineBeg() : this.beg(BBCodeTagType.Underline);
  BBCodeTag.underlineEnd() : this.end(BBCodeTagType.Underline);
  BBCodeTag.plainLink(String content)
      : this.leaf(BBCodeTagType.PlainLink, content);
  BBCodeTag.linkBeg(String content) : this.beg(BBCodeTagType.Link, content);
  BBCodeTag.linkEnd() : this.end(BBCodeTagType.Link);
  BBCodeTag.rule() : this.leaf(BBCodeTagType.Rule);
  BBCodeTag.uidBeg(String content) : this.beg(BBCodeTagType.Uid, content);
  BBCodeTag.uidEnd() : this.end(BBCodeTagType.Uid);
  BBCodeTag.pid(String content) : this.leaf(BBCodeTagType.Pid, content);
  BBCodeTag.text(String content) : this.leaf(BBCodeTagType.Text, content);
  BBCodeTag.paragraphBeg() : this.beg(BBCodeTagType.Paragraph);
  BBCodeTag.paragraphEnd() : this.end(BBCodeTagType.Paragraph);

  bool operator ==(t) {
    return t is BBCodeTag &&
        t.type == type &&
        t.beg == beg &&
        t.content == content;
  }

  int get hashCode {
    return type.hashCode & beg.hashCode & content.hashCode;
  }

  @override
  String toString() {
    return '$type${beg != null ? (beg ? 'Start' : 'End') : ''}: "${content ?? ''}"';
  }
}

LinkedList<BBCodeTag> parseBBCode(String content) {
  LinkedList<BBCodeTag> tags = LinkedList();

  _parseBlock(content, tags);

  var _pre = tags.first;

  while (_pre != null) {
    var pre = _pre.next;
    if (_pre.type == BBCodeTagType.Text) {
      _parseInlines(_pre.content, _pre);
    }
    _pre = pre;
  }

  return tags;
}

_parseBlock(String content, LinkedList<BBCodeTag> tags) {
  List<_TagWithPosition> _tags = List();

  for (RegExpMatch match in quoteRegExp.allMatches(content)) {
    _tags.add(_TagWithPosition(
      BBCodeTag.quoteBeg(),
      match.start,
      match.start + "[quote]".length,
    ));
    _tags.add(_TagWithPosition(
      BBCodeTag.quoteEnd(),
      match.end - "[/quote]".length,
      match.end,
    ));
  }

  for (RegExpMatch match in collapseRegExp.allMatches(content)) {
    _tags.add(_TagWithPosition(
      BBCodeTag.collapseBeg(),
      match.start,
      match.start + "[collapse]".length + (match[1]?.length ?? 0),
    ));
    _tags.add(_TagWithPosition(
      BBCodeTag.collapseEnd(),
      match.end - "[/collapse]".length,
      match.end,
    ));
  }

  for (RegExpMatch match in boldRegExp.allMatches(content)) {
    _tags.add(_TagWithPosition(
      BBCodeTag.boldBeg(),
      match.start,
      match.start + "[b]".length,
    ));
    _tags.add(_TagWithPosition(
      BBCodeTag.boldEnd(),
      match.end - "[/b]".length,
      match.end,
    ));
  }

  for (RegExpMatch match in italicsRegExp.allMatches(content)) {
    _tags.add(_TagWithPosition(
      BBCodeTag.italicsBeg(),
      match.start,
      match.start + "[i]".length,
    ));
    _tags.add(_TagWithPosition(
      BBCodeTag.italicsEnd(),
      match.end - "[/i]".length,
      match.end,
    ));
  }

  for (RegExpMatch match in deleteRegExp.allMatches(content)) {
    _tags.add(_TagWithPosition(
      BBCodeTag.deleteBeg(),
      match.start,
      match.start + "[del]".length,
    ));
    _tags.add(_TagWithPosition(
      BBCodeTag.deleteEnd(),
      match.end - "[/del]".length,
      match.end,
    ));
  }

  for (RegExpMatch match in underlineRegExp.allMatches(content)) {
    _tags.add(_TagWithPosition(
      BBCodeTag.deleteBeg(),
      match.start,
      match.start + "[u]".length,
    ));
    _tags.add(_TagWithPosition(
      BBCodeTag.deleteEnd(),
      match.end - "[/u]".length,
      match.end,
    ));
  }

  for (RegExpMatch match in sizeRegExp.allMatches(content)) {
    _tags.add(_TagWithPosition(
      BBCodeTag.sizeBeg(match[1]),
      match.start,
      match.start + "[size=]".length + (match[1]?.length ?? 0),
    ));
    _tags.add(_TagWithPosition(
      BBCodeTag.sizeEnd(),
      match.end - "[/size]".length,
      match.end,
    ));
  }

  for (RegExpMatch match in colorRegExp.allMatches(content)) {
    _tags.add(_TagWithPosition(
      BBCodeTag.sizeBeg(match[1]),
      match.start,
      match.start + "[color=]".length + (match[1]?.length ?? 0),
    ));
    _tags.add(_TagWithPosition(
      BBCodeTag.sizeEnd(),
      match.end - "[/color]".length,
      match.end,
    ));
  }

  if (_tags.isEmpty) {
    tags.add(BBCodeTag.paragraphBeg());
    tags.add(BBCodeTag.text(content));
    tags.add(BBCodeTag.paragraphEnd());
  } else {
    _tags.sort((a, b) => a.start.compareTo(b.start));

    int lastEnd = 0;
    bool openingParagraph = false;

    for (_TagWithPosition tagWihtPosition in _tags) {
      if (tagWihtPosition.start != lastEnd) {
        if (!openingParagraph) {
          tags.add(BBCodeTag.paragraphBeg());
          openingParagraph = true;
        }
        tags.add(
          BBCodeTag.text(content.substring(lastEnd, tagWihtPosition.start)),
        );
      }
      lastEnd = tagWihtPosition.end;

      switch (tagWihtPosition.tag.type) {
        case BBCodeTagType.Collapse:
        case BBCodeTagType.Align:
        case BBCodeTagType.Table:
        case BBCodeTagType.Quote:
          if (openingParagraph) {
            tags.add(BBCodeTag.paragraphEnd());
            openingParagraph = false;
          }
          break;
        default: // inlines
          if (!openingParagraph) {
            tags.add(BBCodeTag.paragraphBeg());
            openingParagraph = true;
          }
          break;
      }

      tags.add(tagWihtPosition.tag);
    }

    if (openingParagraph) {
      tags.add(BBCodeTag.paragraphEnd());
    }
  }
}

_parseInlines(String content, BBCodeTag previous) {
  List<_TagWithPosition> _tags = List();

  for (RegExpMatch match in linkRegExp.allMatches(content)) {
    if (match[1] == null) {
      _tags.add(_TagWithPosition(
        BBCodeTag.plainLink(match[2]),
        match.start,
        match.end,
      ));
    } else {
      _tags.add(_TagWithPosition(
        BBCodeTag.linkBeg(match[1]),
        match.start,
        match.start + "[url]".length + match[1].length,
      ));
      _tags.add(_TagWithPosition(
        BBCodeTag.text(match[2]),
        match.start + "[url]".length + match[1].length,
        match.end - "[/url]".length,
      ));
      _tags.add(_TagWithPosition(
        BBCodeTag.linkEnd(),
        match.end - "[/url]".length,
        match.end,
      ));
    }
  }

  for (RegExpMatch match in metionsRegExp.allMatches(content)) {
    _tags.add(_TagWithPosition(
      BBCodeTag.metions(match[1]),
      match.start,
      match.end,
    ));
  }

  for (RegExpMatch match in stickerRegExp.allMatches(content)) {
    _tags.add(_TagWithPosition(
      BBCodeTag.sticker(match[1]),
      match.start,
      match.end,
    ));
  }

  for (RegExpMatch match in imageRegExp.allMatches(content)) {
    _tags.add(_TagWithPosition(
      BBCodeTag.image(match[1]),
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
        var tag =
            BBCodeTag.text(content.substring(lastEnd, tagWihtPosition.start));
        _pre.insertAfter(tag);
        _pre = tag;
      }
      lastEnd = tagWihtPosition.end;
      _pre.insertAfter(tagWihtPosition.tag);
      _pre = tagWihtPosition.tag;
    }

    previous.unlink();
  }
}

_parseLinkContent(String content, BBCodeTag previous) {
  List<_TagWithPosition> _tags = List();

  for (RegExpMatch match in metionsRegExp.allMatches(content)) {
    _tags.add(_TagWithPosition(
      BBCodeTag.metions(match[1]),
      match.start,
      match.end,
    ));
  }

  for (RegExpMatch match in stickerRegExp.allMatches(content)) {
    _tags.add(_TagWithPosition(
      BBCodeTag.sticker(match[1]),
      match.start,
      match.end,
    ));
  }

  for (RegExpMatch match in imageRegExp.allMatches(content)) {
    _tags.add(_TagWithPosition(
      BBCodeTag.image(match[1]),
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
  final BBCodeTag tag;
  final int start;
  final int end;

  _TagWithPosition(this.tag, this.start, this.end);
}
