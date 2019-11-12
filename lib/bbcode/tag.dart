import "dart:collection";

enum TagType {
  // [quote]
  QuoteStart,
  // [/quote]
  QuoteEnd,
  // [table]
  TableStart,
  // [/table]
  TableEnd,
  // [collapse] or [collapse=xxxx]
  CollapseStart,
  // [/collapse]
  CollapseEnd,
  // [b]
  BoldStart,
  // [/b]
  BoldEnd,
  // [font=xxx]
  FontStart,
  // [/font]
  FontEnd,
  // [color=xxx]
  ColorStart,
  // [/color]
  ColorEnd,
  // [size=xxx]
  SizeStart,
  // [/size]
  SizeEnd,
  // [u]
  UnderlineStart,
  // [/u]
  UnderlineEnd,
  // [i]
  ItalicStart,
  // [/i]
  ItalicEnd,
  // [del]
  DeleteStart,
  // [/del]
  DeleteEnd,
  // [img]xxx[/img]
  Image,
  // [url=xxx]
  LinkStart,
  // [/url]
  LinkEnd,
  // [url]xxx[/url]
  PlainLink,
  // [s:xxx]
  Sticker,
  // [h]
  HeadingStart,
  // [/h]
  HeadingEnd,
  // [tr]
  TableRowStart,
  // [/tr]
  TableRowEnd,
  // [td]
  TableCellStart,
  // [/td]
  TableCellEnd,
  // [@xxxx]
  Metions,
  // [hr]
  Rule,
  // [pid=xxx]xxx[/pid]
  Pid,
  // [uid=xxx]xxx[/uid]
  Uid,
  // [align]
  AlignStart,
  // [/align]
  AlignEnd,
  Text,
  ParagraphStart,
  ParagraphEnd,
}

abstract class Tag extends LinkedListEntry<Tag> {
  final TagType type;

  Tag(this.type);

  bool operator ==(t) => t is Tag && t.type == type;

  int get hashCode {
    return type.hashCode;
  }

  @override
  String toString() => "$type";
}

class AlignEnd extends Tag {
  AlignEnd() : super(TagType.AlignEnd);
}

class AlignStart extends Tag {
  AlignStart() : super(TagType.AlignStart);
}

class BoldEnd extends Tag {
  BoldEnd() : super(TagType.BoldEnd);
}

class BoldStart extends Tag {
  BoldStart() : super(TagType.BoldStart);
}

class CollapseEnd extends Tag {
  CollapseEnd() : super(TagType.CollapseEnd);
}

class CollapseStart extends Tag {
  final String description;

  CollapseStart(this.description) : super(TagType.CollapseStart);

  bool operator ==(t) =>
      t is CollapseStart && t.type == type && t.description == description;

  int get hashCode {
    return type.hashCode;
  }

  @override
  String toString() => "$type($description)";
}

class ColorEnd extends Tag {
  ColorEnd() : super(TagType.ColorEnd);
}

class ColorStart extends Tag {
  ColorStart() : super(TagType.ColorStart);
}

class DeleteEnd extends Tag {
  DeleteEnd() : super(TagType.DeleteEnd);
}

class DeleteStart extends Tag {
  DeleteStart() : super(TagType.DeleteStart);
}

class FontEnd extends Tag {
  FontEnd() : super(TagType.FontEnd);
}

class FontStart extends Tag {
  FontStart() : super(TagType.FontStart);
}

class HeadingEnd extends Tag {
  HeadingEnd() : super(TagType.HeadingEnd);
}

class HeadingStart extends Tag {
  HeadingStart() : super(TagType.HeadingStart);
}

class Image extends Tag {
  final String url;

  Image(this.url)
      : assert(url != null),
        super(TagType.Image);

  bool operator ==(t) => t is Image && t.type == type && t.url == url;

  int get hashCode {
    return type.hashCode;
  }

  @override
  String toString() => "$type($url)";
}

class ItalicEnd extends Tag {
  ItalicEnd() : super(TagType.ItalicEnd);
}

class ItalicStart extends Tag {
  ItalicStart() : super(TagType.ItalicStart);
}

class LinkEnd extends Tag {
  LinkEnd() : super(TagType.LinkEnd);
}

class LinkStart extends Tag {
  final String url;

  LinkStart(this.url)
      : assert(url != null),
        super(TagType.LinkStart);

  bool operator ==(t) => t is LinkStart && t.type == type && t.url == url;

  int get hashCode {
    return type.hashCode ^ url.hashCode;
  }

  @override
  String toString() => "$type($url)";
}

class Metions extends Tag {
  final String username;

  Metions(this.username)
      : assert(username != null),
        super(TagType.Metions);

  bool operator ==(t) =>
      t is Metions && t.type == type && t.username == username;

  int get hashCode {
    return type.hashCode ^ username.hashCode;
  }

  @override
  String toString() => "$type($username)";
}

class ParagraphEnd extends Tag {
  ParagraphEnd() : super(TagType.ParagraphEnd);
}

class ParagraphStart extends Tag {
  ParagraphStart() : super(TagType.ParagraphStart);
}

class Pid extends Tag {
  final int postId;
  final int topicId;
  final int page;
  final String content;

  Pid(this.postId, this.topicId, this.page, this.content) : super(TagType.Pid);
}

class PlainLink extends Tag {
  final String url;

  PlainLink(this.url)
      : assert(url != null),
        super(TagType.PlainLink);

  bool operator ==(t) => t is PlainLink && t.type == type && t.url == url;

  int get hashCode {
    return type.hashCode ^ url.hashCode;
  }

  @override
  String toString() => "$type($url)";
}

class QuoteEnd extends Tag {
  QuoteEnd() : super(TagType.QuoteEnd);
}

class QuoteStart extends Tag {
  QuoteStart() : super(TagType.QuoteStart);
}

class Rule extends Tag {
  Rule() : super(TagType.Rule);
}

class SizeEnd extends Tag {
  SizeEnd() : super(TagType.SizeEnd);
}

class SizeStart extends Tag {
  SizeStart() : super(TagType.SizeStart);
}

class Sticker extends Tag {
  final String name;

  Sticker(this.name)
      : assert(name != null),
        super(TagType.Sticker);

  bool operator ==(t) => t is Sticker && t.type == type && t.name == name;

  int get hashCode {
    return type.hashCode ^ name.hashCode;
  }

  @override
  String toString() => "$type($name)";
}

class TableCellEnd extends Tag {
  TableCellEnd() : super(TagType.TableCellEnd);
}

class TableCellStart extends Tag {
  TableCellStart() : super(TagType.TableCellStart);
}

class TableEnd extends Tag {
  TableEnd() : super(TagType.TableEnd);
}

class TableRowEnd extends Tag {
  TableRowEnd() : super(TagType.TableRowEnd);
}

class TableRowStart extends Tag {
  TableRowStart() : super(TagType.TableRowStart);
}

class TableStart extends Tag {
  TableStart() : super(TagType.TableStart);
}

class Text extends Tag {
  final String content;

  Text(this.content)
      : assert(content != null && content.isNotEmpty),
        super(TagType.Text);

  bool operator ==(t) => t is Text && t.type == type && t.content == content;

  int get hashCode {
    return type.hashCode ^ content.hashCode;
  }

  @override
  String toString() => "$type($content)";
}

class Uid extends Tag {
  final int id;
  final String username;

  Uid(this.id, this.username) : super(TagType.Uid);

  bool operator ==(t) =>
      t is Uid && t.type == type && t.id == id && t.username == username;

  int get hashCode {
    return type.hashCode ^ id.hashCode ^ username.hashCode;
  }

  @override
  String toString() => "$type($id, $username)";
}

class UnderlineEnd extends Tag {
  UnderlineEnd() : super(TagType.UnderlineEnd);
}

class UnderlineStart extends Tag {
  UnderlineStart() : super(TagType.UnderlineStart);
}
