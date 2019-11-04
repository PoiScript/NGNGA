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
}

RegExp boldRegExp = RegExp(
  r"\[b\](.*?)\[/b\]",
  multiLine: true,
);

RegExp italicsRegExp = RegExp(
  r"\[i\](.*?)\[/i\]",
  multiLine: true,
);

RegExp deleteRegExp = RegExp(
  r"\[del\](.*?)\[/del\]",
  multiLine: true,
);

RegExp underlineRegExp = RegExp(
  r"\[u\](.*?)\[/u\]",
  multiLine: true,
);

RegExp headingRegExp = RegExp(
  r"\[h\](.*?)\[/h\]",
  multiLine: true,
);

RegExp colorRegExp = RegExp(
  r"\[color=([^\s\]]*)?\](.*?)\[/color\]",
  multiLine: true,
);

RegExp sizeRegExp = RegExp(
  r"\[size=([^\s\]]*)?\](.*?)\[/size\]",
  multiLine: true,
);

RegExp quoteRegExp = RegExp(
  r"\[quote\](.*?)\[/quote\]",
  multiLine: true,
);

RegExp tableRegExp = RegExp(
  r"\[table\](.*?)\[/table\]",
  multiLine: true,
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
  BBCodeTag.imageBeg() : this.beg(BBCodeTagType.Image);
  BBCodeTag.imageEnd() : this.end(BBCodeTagType.Image);
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
  BBCodeTag.text(String content) : this.leaf(BBCodeTagType.Text, content);
  BBCodeTag.rule() : this.leaf(BBCodeTagType.Rule);
  BBCodeTag.uidBeg(String content) : this.beg(BBCodeTagType.Uid, content);
  BBCodeTag.uidEnd() : this.end(BBCodeTagType.Uid);
  BBCodeTag.pid(String content) : this.leaf(BBCodeTagType.Pid, content);

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

class BBCodeParser {
  LinkedList<BBCodeTag> tags;

  BBCodeTag _previous;

  BBCodeParser._(this.tags, this._previous);

  factory BBCodeParser(String content) {
    LinkedList<BBCodeTag> list = LinkedList();
    BBCodeTag tag = BBCodeTag.text(content);
    list.add(tag);
    return BBCodeParser._(list, tag);
  }

  LinkedList<BBCodeTag> parse() {
    _applyParser(_parseCollapse);
    _applyParser(_parseQuote);
    _applyParser(_parseTable);
    _applyParser(_parseHeading);

    _applyParser(_parseLink);
    _applyParser(_parseInlines);
    _applyParser(_parseFont);
    _applyParser(_parseImage);
    _applyParser(_parseMetions);
    _applyParser(_parseSticker);
    return tags;
  }

  _insert(BBCodeTag tag) {
    _previous.insertAfter(tag);
    _previous = tag;
  }

  _applyParser(bool parseFn(String content)) {
    var tag = tags.first;
    while (tag != null) {
      var next = tag.next;
      if (tag.type == BBCodeTagType.Text) {
        _previous = tag;
        if (tag.content != null) {
          if (parseFn(tag.content)) {
            tag.unlink();
          }
        }
      }
      tag = next;
    }
  }

  bool _parseQuote(String content) {
    int lastEnd = 0;

    for (var match in quoteRegExp.allMatches(content)) {
      if (match.start != lastEnd) {
        _insert(BBCodeTag.text(content.substring(lastEnd, match.start)));
      }
      lastEnd = match.end;
      _insert(BBCodeTag.quoteBeg());
      _insert(BBCodeTag.text(match[1]));
      _insert(BBCodeTag.quoteEnd());
    }

    if (lastEnd != 0) {
      if (lastEnd != content.length) {
        _insert(BBCodeTag.text(content.substring(lastEnd)));
      }

      return true;
    } else {
      return false;
    }
  }

  bool _parseTable(String content) {
    int lastEnd = 0;

    for (var match in tableRegExp.allMatches(content)) {
      if (match.start != lastEnd) {
        _insert(BBCodeTag.text(content.substring(lastEnd, match.start)));
      }
      lastEnd = match.end;

      // print(match[0]);

      _insert(BBCodeTag.tableBeg());
      _insert(BBCodeTag.text(match.group(1)));
      _insert(BBCodeTag.tableEnd());
    }

    if (lastEnd != 0) {
      if (lastEnd != content.length) {
        _insert(BBCodeTag.text(content.substring(lastEnd)));
      }

      return true;
    } else {
      return false;
    }
  }

  static RegExp collapseRegExp = RegExp(
    r"\[collapse(=[^\s\]]*)?\](.*?)\[/collapse\]",
    multiLine: true,
    dotAll: true,
    unicode: true,
  );

  bool _parseCollapse(String content) {
    int lastEnd = 0;

    for (var match in collapseRegExp.allMatches(content)) {
      if (match.start != lastEnd) {
        _insert(BBCodeTag.text(content.substring(lastEnd, match.start)));
      }
      lastEnd = match.end;

      // print(match[0]);

      if (match[1] != null) {
        _insert(BBCodeTag.collapseBeg(match[1].substring(1)));
      } else {
        _insert(BBCodeTag.collapseBeg());
      }
      _insert(BBCodeTag.text(match[2]));
      _insert(BBCodeTag.collapseEnd());
    }

    if (lastEnd != 0) {
      if (lastEnd != content.length) {
        _insert(BBCodeTag.text(content.substring(lastEnd)));
      }

      return true;
    } else {
      return false;
    }
  }

  bool _parseInlines(String content) {
    List<_InlineMatch> matches = [];

    for (var match in boldRegExp.allMatches(content)) {
      matches.add(_InlineMatch.beg(BBCodeTagType.Bold, match.start, 3));
      matches.add(_InlineMatch.end(BBCodeTagType.Bold, match.end, 4));
    }

    for (var match in italicsRegExp.allMatches(content)) {
      matches.add(_InlineMatch.beg(BBCodeTagType.Italics, match.start, 3));
      matches.add(_InlineMatch.end(BBCodeTagType.Italics, match.end, 4));
    }

    for (var match in deleteRegExp.allMatches(content)) {
      matches.add(_InlineMatch.beg(BBCodeTagType.Delete, match.start, 5));
      matches.add(_InlineMatch.end(BBCodeTagType.Delete, match.end, 6));
    }

    for (var match in underlineRegExp.allMatches(content)) {
      matches.add(_InlineMatch.beg(BBCodeTagType.Underline, match.start, 5));
      matches.add(_InlineMatch.end(BBCodeTagType.Underline, match.end, 6));
    }

    for (var match in sizeRegExp.allMatches(content)) {
      matches.add(_InlineMatch.beg(
        BBCodeTagType.Size,
        match.start,
        7 + match[1].length,
        content: match[1],
      ));
      matches.add(_InlineMatch.end(BBCodeTagType.Size, match.end, 7));
    }

    for (var match in colorRegExp.allMatches(content)) {
      matches.add(_InlineMatch.beg(
        BBCodeTagType.Color,
        match.start,
        8 + match[1].length,
        content: match[1],
      ));
      matches.add(_InlineMatch.end(BBCodeTagType.Color, match.end, 8));
    }

    if (matches.isEmpty) {
      return false;
    }

    matches.sort((a, b) => a.start.compareTo(b.start));

    int lastEnd = 0;

    for (var match in matches) {
      if (match.start != lastEnd) {
        _insert(BBCodeTag.text(content.substring(lastEnd, match.start)));
      }
      lastEnd = match.end;
      _insert(BBCodeTag._(match.type, match.begin, match.content));
    }

    if (lastEnd != content.length) {
      _insert(BBCodeTag.text(content.substring(lastEnd)));
    }

    return true;
  }

  bool _parseHeading(String content) {
    int lastEnd = 0;

    for (var match in headingRegExp.allMatches(content)) {
      if (match.start != lastEnd) {
        _insert(BBCodeTag.text(content.substring(lastEnd, match.start)));
      }
      lastEnd = match.end;
      _insert(BBCodeTag.headingBeg());
      _insert(BBCodeTag.text(match.group(1)));
      _insert(BBCodeTag.headingEnd());
    }

    if (lastEnd != 0) {
      if (lastEnd != content.length) {
        _insert(BBCodeTag.text(content.substring(lastEnd)));
      }

      return true;
    } else {
      return false;
    }
  }

  bool _parseImage(String content) {
    int lastEnd = 0;

    for (var match in imageRegExp.allMatches(content)) {
      if (match.start != lastEnd) {
        _insert(BBCodeTag.text(content.substring(lastEnd, match.start)));
      }
      lastEnd = match.end;
      _insert(BBCodeTag.imageBeg());
      _insert(BBCodeTag.text(match.group(1)));
      _insert(BBCodeTag.imageEnd());
    }

    if (lastEnd != 0) {
      if (lastEnd != content.length) {
        _insert(BBCodeTag.text(content.substring(lastEnd)));
      }

      return true;
    } else {
      return false;
    }
  }

  bool _parseSticker(String content) {
    int lastEnd = 0;

    for (var match in stickerRegExp.allMatches(content)) {
      if (match.start != lastEnd) {
        _insert(BBCodeTag.text(content.substring(lastEnd, match.start)));
      }
      lastEnd = match.end;
      _insert(BBCodeTag.sticker(match.group(1)));
    }

    if (lastEnd != 0) {
      if (lastEnd != content.length) {
        _insert(BBCodeTag.text(content.substring(lastEnd)));
      }

      return true;
    } else {
      return false;
    }
  }

  bool _parseLink(String content) {
    int lastEnd = 0;

    for (var match in linkRegExp.allMatches(content)) {
      if (match.start != lastEnd) {
        _insert(BBCodeTag.text(content.substring(lastEnd, match.start)));
      }
      lastEnd = match.end;
      if (match[1] == null) {
        _insert(BBCodeTag.plainLink(match[2]));
      } else {
        _insert(BBCodeTag.linkBeg(match[1]));
        _insert(BBCodeTag.text(match[2]));
        _insert(BBCodeTag.linkEnd());
      }
    }

    if (lastEnd != 0) {
      if (lastEnd != content.length) {
        _insert(BBCodeTag.text(content.substring(lastEnd)));
      }

      return true;
    } else {
      return false;
    }
  }

  bool _parseFont(String content) {
    int lastEnd = 0;

    for (var match in fontRegExp.allMatches(content)) {
      if (match.start != lastEnd) {
        _insert(BBCodeTag.text(content.substring(lastEnd, match.start)));
      }
      lastEnd = match.end;
      _insert(BBCodeTag.fontBeg(match.group(1)));
      _insert(BBCodeTag.text(match.group(2)));
      _insert(BBCodeTag.fontEnd());
    }

    if (lastEnd != 0) {
      if (lastEnd != content.length) {
        _insert(BBCodeTag.text(content.substring(lastEnd)));
      }

      return true;
    } else {
      return false;
    }
  }

  bool _parseMetions(String content) {
    int lastEnd = 0;

    for (var match in metionsRegExp.allMatches(content)) {
      if (match.start != lastEnd) {
        _insert(BBCodeTag.text(content.substring(lastEnd, match.start)));
      }
      lastEnd = match.end;
      _insert(BBCodeTag.metions(match.group(1)));
    }

    if (lastEnd != 0) {
      if (lastEnd != content.length) {
        _insert(BBCodeTag.text(content.substring(lastEnd)));
      }

      return true;
    } else {
      return false;
    }
  }
}

class _InlineMatch {
  final BBCodeTagType type;
  final int start;
  final int end;
  final String content;
  final bool begin;

  _InlineMatch._(this.type, this.begin, this.start, this.end, {this.content});

  _InlineMatch.beg(BBCodeTagType type, int start, int len, {String content})
      : this._(type, true, start, start + len, content: content);
  _InlineMatch.end(BBCodeTagType type, int end, int len, {String content})
      : this._(type, false, end - len, end, content: content);
}

class _BlockMatch {
  final BBCodeTagType type;
  final int start;
  final int end;
  final String content;
  final bool begin;

  _BlockMatch._(this.type, this.begin, this.start, this.end, {this.content});
  _BlockMatch.beg(BBCodeTagType type, int start, int len, {String content})
      : this._(type, true, start, start + len, content: content);
  _BlockMatch.end(BBCodeTagType type, int end, int len, {String content})
      : this._(type, false, end - len, end, content: content);
}
