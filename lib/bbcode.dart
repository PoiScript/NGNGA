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
  Url,
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
  Text,
}

class BBCodeTag extends LinkedListEntry<BBCodeTag> {
  final BBCodeTagType type;
  final bool beg;
  final String content;

  BBCodeTag(this.type, this.beg, this.content);
  BBCodeTag.beg(BBCodeTagType type, String content) : this(type, true, content);
  BBCodeTag.end(BBCodeTagType type, String content)
      : this(type, false, content);

  BBCodeTag.collapseBeg(String content)
      : this.beg(BBCodeTagType.Collapse, content);
  BBCodeTag.collapseEnd() : this.end(BBCodeTagType.Collapse, null);
  BBCodeTag.quoteBeg() : this.beg(BBCodeTagType.Quote, null);
  BBCodeTag.quoteEnd() : this.end(BBCodeTagType.Quote, null);
  BBCodeTag.tableBeg() : this.beg(BBCodeTagType.Table, null);
  BBCodeTag.tableEnd() : this.end(BBCodeTagType.Table, null);
  BBCodeTag.boldBeg() : this.beg(BBCodeTagType.Bold, null);
  BBCodeTag.boldEnd() : this.end(BBCodeTagType.Bold, null);
  BBCodeTag.colorBeg(String content) : this.beg(BBCodeTagType.Color, content);
  BBCodeTag.colorEnd() : this.end(BBCodeTagType.Color, null);
  BBCodeTag.deleteBeg() : this.beg(BBCodeTagType.Delete, null);
  BBCodeTag.deleteEnd() : this.end(BBCodeTagType.Delete, null);
  BBCodeTag.fontBeg(String content) : this.beg(BBCodeTagType.Font, content);
  BBCodeTag.fontEnd() : this.end(BBCodeTagType.Font, null);
  BBCodeTag.headingBeg() : this.beg(BBCodeTagType.Heading, null);
  BBCodeTag.headingEnd() : this.end(BBCodeTagType.Heading, null);
  BBCodeTag.imageBeg() : this.beg(BBCodeTagType.Image, null);
  BBCodeTag.imageEnd() : this.end(BBCodeTagType.Image, null);
  BBCodeTag.italicsBeg() : this.beg(BBCodeTagType.Italics, null);
  BBCodeTag.italicsEnd() : this.end(BBCodeTagType.Italics, null);
  BBCodeTag.metions(String content)
      : this(BBCodeTagType.Metions, null, content);
  BBCodeTag.sizeBeg(String content) : this.beg(BBCodeTagType.Size, content);
  BBCodeTag.sizeEnd() : this.end(BBCodeTagType.Size, null);
  BBCodeTag.sticker(String content)
      : this(BBCodeTagType.Sticker, null, content);
  BBCodeTag.tableRowBeg() : this.beg(BBCodeTagType.TableRow, null);
  BBCodeTag.tableRowEnd() : this.end(BBCodeTagType.TableRow, null);
  BBCodeTag.tableCellBeg(String content)
      : this.beg(BBCodeTagType.TableCell, content);
  BBCodeTag.tableCellEnd() : this.end(BBCodeTagType.TableCell, null);
  BBCodeTag.underlineBeg() : this.beg(BBCodeTagType.Underline, null);
  BBCodeTag.underlineEnd() : this.end(BBCodeTagType.Underline, null);
  BBCodeTag.urlBeg(String content) : this.beg(BBCodeTagType.Url, content);
  BBCodeTag.urlEnd() : this.end(BBCodeTagType.Url, null);
  BBCodeTag.text(String content) : this(BBCodeTagType.Text, null, content);
  BBCodeTag.rule() : this(BBCodeTagType.Rule, null, null);

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
    return 'BBCodeTag{type: $type, beg: $beg, content: $content}';
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
    _parse(_parseCollapse);
    _parse(_parseQuote);
    _parse(_parseTable);
    _parse(_parseHeading);
    _parse(_parseBold);
    _parse(_parseColor);
    _parse(_parseDelete);
    _parse(_parseFont);
    _parse(_parseImage);
    _parse(_parseItalics);
    _parse(_parseMetions);
    _parse(_parseSize);
    _parse(_parseSticker);
    _parse(_parseUnderline);
    _parse(_parseUrl);
    return tags;
  }

  _insert(BBCodeTag tag) {
    _previous.insertAfter(tag);
    _previous = tag;
  }

  _parse(Function(BBCodeTag tag) parseFn) {
    var tag = tags.first;
    while (tag != null) {
      var next = tag.next;
      if (tag.type == BBCodeTagType.Text) {
        _previous = tag;
        if (tag.content != null) {
          parseFn(tag);
        }
      }
      tag = next;
    }
  }

  static RegExp quoteRegExp = RegExp(
    r"\[quote\](.*?)\[/quote\]",
    multiLine: true,
  );

  _parseQuote(BBCodeTag tag) {
    int lastEnd = 0;

    for (var match in collapseRegExp.allMatches(tag.content)) {
      if (match.start != lastEnd) {
        _insert(BBCodeTag.text(tag.content.substring(lastEnd, match.start)));
      }
      lastEnd = match.end;
      _insert(BBCodeTag.quoteBeg());
      _insert(BBCodeTag.text(match.group(1)));
      _insert(BBCodeTag.quoteEnd());
    }

    if (lastEnd != 0) {
      if (lastEnd != tag.content.length) {
        _insert(BBCodeTag.text(tag.content.substring(lastEnd)));
      }
      tag.unlink();
    }
  }

  static RegExp tableRegExp = RegExp(
    r"\[table\](.*?)\[/table\]",
    multiLine: true,
  );

  _parseTable(BBCodeTag tag) {
    int lastEnd = 0;

    for (var match in tableRegExp.allMatches(tag.content)) {
      if (match.start != lastEnd) {
        _insert(BBCodeTag.text(tag.content.substring(lastEnd, match.start)));
      }
      lastEnd = match.end;
      _insert(BBCodeTag.tableBeg());
      _insert(BBCodeTag.text(match.group(1)));
      _insert(BBCodeTag.tableEnd());
    }

    if (lastEnd != 0) {
      if (lastEnd != tag.content.length) {
        _insert(BBCodeTag.text(tag.content.substring(lastEnd)));
      }
      tag.unlink();
    }
  }

  static RegExp collapseRegExp = RegExp(
    r"\[collapse(=[^\s\]]*)?\](.*?)\[/collapse\]",
    multiLine: true,
    dotAll: true,
    unicode: true,
  );

  _parseCollapse(BBCodeTag tag) {
    int lastEnd = 0;

    for (var match in tableRegExp.allMatches(tag.content)) {
      if (match.start != lastEnd) {
        _insert(BBCodeTag.text(tag.content.substring(lastEnd, match.start)));
      }
      lastEnd = match.end;
      _insert(BBCodeTag.collapseBeg(match.group(1)));
      _insert(BBCodeTag.text(match.group(2)));
      _insert(BBCodeTag.tableEnd());
    }

    if (lastEnd != 0) {
      if (lastEnd != tag.content.length) {
        _insert(BBCodeTag.text(tag.content.substring(lastEnd)));
      }
      tag.unlink();
    }
  }

  static RegExp boldRegExp = RegExp(
    r"\[b\](.*?)\[/b\]",
    multiLine: true,
  );

  _parseBold(BBCodeTag tag) {
    int lastEnd = 0;

    for (var match in boldRegExp.allMatches(tag.content)) {
      if (match.start != lastEnd) {
        _insert(BBCodeTag.text(tag.content.substring(lastEnd, match.start)));
      }
      lastEnd = match.end;
      _insert(BBCodeTag.boldBeg());
      _insert(BBCodeTag.text(match.group(1)));
      _insert(BBCodeTag.boldEnd());
    }

    if (lastEnd != 0) {
      if (lastEnd != tag.content.length) {
        _insert(BBCodeTag.text(tag.content.substring(lastEnd)));
      }
      tag.unlink();
    }
  }

  static RegExp italicsRegExp = RegExp(
    r"\[i\](.*?)\[/i\]",
    multiLine: true,
  );

  _parseItalics(BBCodeTag tag) {
    int lastEnd = 0;

    for (var match in italicsRegExp.allMatches(tag.content)) {
      if (match.start != lastEnd) {
        _insert(BBCodeTag.text(tag.content.substring(lastEnd, match.start)));
      }
      lastEnd = match.end;
      _insert(BBCodeTag.italicsBeg());
      _insert(BBCodeTag.text(match.group(1)));
      _insert(BBCodeTag.italicsEnd());
    }

    if (lastEnd != 0) {
      if (lastEnd != tag.content.length) {
        _insert(BBCodeTag.text(tag.content.substring(lastEnd)));
      }
      tag.unlink();
    }
  }

  static RegExp deleteRegExp = RegExp(
    r"\[del\](.*?)\[/del\]",
    multiLine: true,
  );

  _parseDelete(BBCodeTag tag) {
    int lastEnd = 0;

    for (var match in deleteRegExp.allMatches(tag.content)) {
      if (match.start != lastEnd) {
        _insert(BBCodeTag.text(tag.content.substring(lastEnd, match.start)));
      }
      lastEnd = match.end;
      _insert(BBCodeTag.deleteBeg());
      _insert(BBCodeTag.text(match.group(1)));
      _insert(BBCodeTag.deleteEnd());
    }

    if (lastEnd != 0) {
      if (lastEnd != tag.content.length) {
        _insert(BBCodeTag.text(tag.content.substring(lastEnd)));
      }
      tag.unlink();
    }
  }

  static RegExp underlineRegExp = RegExp(
    r"\[u\](.*?)\[/u\]",
    multiLine: true,
  );

  _parseUnderline(BBCodeTag tag) {
    int lastEnd = 0;

    for (var match in underlineRegExp.allMatches(tag.content)) {
      if (match.start != lastEnd) {
        _insert(BBCodeTag.text(tag.content.substring(lastEnd, match.start)));
      }
      lastEnd = match.end;
      _insert(BBCodeTag.underlineBeg());
      _insert(BBCodeTag.text(match.group(1)));
      _insert(BBCodeTag.underlineEnd());
    }

    if (lastEnd != 0) {
      if (lastEnd != tag.content.length) {
        _insert(BBCodeTag.text(tag.content.substring(lastEnd)));
      }
      tag.unlink();
    }
  }

  static RegExp headingRegExp = RegExp(
    r"\[h\](.*?)\[/h\]",
    multiLine: true,
  );

  _parseHeading(BBCodeTag tag) {
    int lastEnd = 0;

    for (var match in headingRegExp.allMatches(tag.content)) {
      if (match.start != lastEnd) {
        _insert(BBCodeTag.text(tag.content.substring(lastEnd, match.start)));
      }
      lastEnd = match.end;
      _insert(BBCodeTag.headingBeg());
      _insert(BBCodeTag.text(match.group(1)));
      _insert(BBCodeTag.headingEnd());
    }

    if (lastEnd != 0) {
      if (lastEnd != tag.content.length) {
        _insert(BBCodeTag.text(tag.content.substring(lastEnd)));
      }
      tag.unlink();
    }
  }

  static RegExp imageRegExp = RegExp(r"\[img\](.*?)\[/img\]");

  _parseImage(BBCodeTag tag) {
    int lastEnd = 0;

    for (var match in imageRegExp.allMatches(tag.content)) {
      if (match.start != lastEnd) {
        _insert(BBCodeTag.text(tag.content.substring(lastEnd, match.start)));
      }
      lastEnd = match.end;
      _insert(BBCodeTag.imageBeg());
      _insert(BBCodeTag.text(match.group(1)));
      _insert(BBCodeTag.imageEnd());
    }

    if (lastEnd != 0) {
      if (lastEnd != tag.content.length) {
        _insert(BBCodeTag.text(tag.content.substring(lastEnd)));
      }
      tag.unlink();
    }
  }

  static RegExp stickerRegExp = RegExp(r"\[s:([^\s\]]*?)\]");

  _parseSticker(BBCodeTag tag) {
    int lastEnd = 0;

    for (var match in stickerRegExp.allMatches(tag.content)) {
      if (match.start != lastEnd) {
        _insert(BBCodeTag.text(tag.content.substring(lastEnd, match.start)));
      }
      lastEnd = match.end;
      _insert(BBCodeTag.sticker(match.group(1)));
    }

    if (lastEnd != 0) {
      if (lastEnd != tag.content.length) {
        _insert(BBCodeTag.text(tag.content.substring(lastEnd)));
      }
      tag.unlink();
    }
  }

  static RegExp urlRegExp = RegExp(r"\[url(=[^\s\]]*)?\](.*?)\[/url\]");

  _parseUrl(BBCodeTag tag) {
    int lastEnd = 0;

    for (var match in urlRegExp.allMatches(tag.content)) {
      if (match.start != lastEnd) {
        _insert(BBCodeTag.text(tag.content.substring(lastEnd, match.start)));
      }
      lastEnd = match.end;
      _insert(BBCodeTag.urlBeg(match.group(1)));
      _insert(BBCodeTag.text(match.group(2)));
      _insert(BBCodeTag.urlEnd());
    }

    if (lastEnd != 0) {
      if (lastEnd != tag.content.length) {
        _insert(BBCodeTag.text(tag.content.substring(lastEnd)));
      }
      tag.unlink();
    }
  }

  static RegExp fontRegExp = RegExp(r"\[font(=[^\s\]]*)?\](.*?)\[/font\]");

  _parseFont(BBCodeTag tag) {
    int lastEnd = 0;

    for (var match in fontRegExp.allMatches(tag.content)) {
      if (match.start != lastEnd) {
        _insert(BBCodeTag.text(tag.content.substring(lastEnd, match.start)));
      }
      lastEnd = match.end;
      _insert(BBCodeTag.fontBeg(match.group(1)));
      _insert(BBCodeTag.text(match.group(2)));
      _insert(BBCodeTag.fontEnd());
    }

    if (lastEnd != 0) {
      if (lastEnd != tag.content.length) {
        _insert(BBCodeTag.text(tag.content.substring(lastEnd)));
      }
      tag.unlink();
    }
  }

  static RegExp colorRegExp = RegExp(r"\[color(=[^\s\]]*)?\](.*?)\[/color\]");

  _parseColor(BBCodeTag tag) {
    int lastEnd = 0;

    for (var match in colorRegExp.allMatches(tag.content)) {
      if (match.start != lastEnd) {
        _insert(BBCodeTag.text(tag.content.substring(lastEnd, match.start)));
      }
      lastEnd = match.end;
      _insert(BBCodeTag.colorBeg(match.group(1)));
      _insert(BBCodeTag.text(match.group(2)));
      _insert(BBCodeTag.colorEnd());
    }

    if (lastEnd != 0) {
      if (lastEnd != tag.content.length) {
        _insert(BBCodeTag.text(tag.content.substring(lastEnd)));
      }
      tag.unlink();
    }
  }

  static RegExp sizeRegExp = RegExp(r"\[size(=[^\s\]]*)?\](.*?)\[/size\]");

  _parseSize(BBCodeTag tag) {
    int lastEnd = 0;

    for (var match in sizeRegExp.allMatches(tag.content)) {
      if (match.start != lastEnd) {
        _insert(BBCodeTag.text(tag.content.substring(lastEnd, match.start)));
      }
      lastEnd = match.end;
      _insert(BBCodeTag.sizeBeg(match.group(1)));
      _insert(BBCodeTag.text(match.group(2)));
      _insert(BBCodeTag.sizeEnd());
    }

    if (lastEnd != 0) {
      if (lastEnd != tag.content.length) {
        _insert(BBCodeTag.text(tag.content.substring(lastEnd)));
      }
      tag.unlink();
    }
  }

  static RegExp metionsRegExp = RegExp(r"\[@([^\s\]]*?)\]");

  _parseMetions(BBCodeTag tag) {
    int lastEnd = 0;

    for (var match in metionsRegExp.allMatches(tag.content)) {
      if (match.start != lastEnd) {
        _insert(BBCodeTag.text(tag.content.substring(lastEnd, match.start)));
      }
      lastEnd = match.end;
      _insert(BBCodeTag.metions(match.group(1)));
    }

    if (lastEnd != 0) {
      if (lastEnd != tag.content.length) {
        _insert(BBCodeTag.text(tag.content.substring(lastEnd)));
      }
      tag.unlink();
    }
  }
}
