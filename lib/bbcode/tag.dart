import "dart:collection";

bool listEquals<T>(List<T> a, List<T> b) {
  if (a == null) return b == null;
  if (b == null || a.length != b.length) return false;
  for (int index = 0; index < a.length; index += 1) {
    if (a[index] != b[index]) return false;
  }
  return true;
}

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
  // // [list]
  // ListStart,
  // // [/list]
  // ListEnd,
  // // [*]
  // ListItemStart,
  // ListItemEnd,

  Text,
  ParagraphStart,
  ParagraphEnd,

  // [b]Reply to [pid=xxx,xxx,xxx]Reply[/pid] Post by [uid=xxx]xxx[/uid] (xxxx-xx-xx xx:xx)[/b]
  // [pid=xxx,xxx,xxx]Reply[/pid] [b]Post by [uid=xxx]xxx[/uid] (xxxx-xx-xx xx:xx):[/b]
  Reply
}

abstract class Tag extends LinkedListEntry<Tag> {
  final TagType type;
  final List<Object> props;

  Tag(this.type, {this.props = const []});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tag &&
          runtimeType == other.runtimeType &&
          listEquals(props, other.props);

  @override
  int get hashCode => runtimeType.hashCode ^ _propsHashCode;

  int get _propsHashCode {
    int hashCode = 0;
    props.forEach((Object prop) => hashCode = hashCode ^ prop.hashCode);
    return hashCode;
  }

  @override
  String toString() {
    if (props.isEmpty) {
      return "$type";
    } else {
      return "$type(${props.map((prop) => prop.toString()).join(',')})";
    }
  }
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

  CollapseStart(String description)
      : this.description = description ?? "点击显示隐藏的内容",
        super(TagType.CollapseStart, props: [description]);
}

class ColorEnd extends Tag {
  ColorEnd() : super(TagType.ColorEnd);
}

class ColorStart extends Tag {
  final String color;

  ColorStart(this.color)
      : assert(color != null),
        super(TagType.ColorStart, props: [color]);
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
        super(TagType.Image, props: [url]);
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
      : assert(url != null && url.isNotEmpty),
        super(TagType.LinkStart, props: [url]);
}

class Metions extends Tag {
  final String username;

  Metions(this.username)
      : assert(username != null),
        super(TagType.Metions, props: [username]);
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
  final int pageIndex;
  final String content;

  Pid(this.postId, this.topicId, this.pageIndex, this.content)
      : assert(postId != null),
        assert(topicId != null),
        assert(pageIndex != null),
        assert(content != null),
        super(TagType.Pid, props: [postId, topicId, pageIndex, content]);
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
  final String path;

  Sticker(this.path)
      : assert(path != null),
        super(TagType.Sticker, props: [path]);
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
      : assert(content != null),
        super(TagType.Text, props: [content]);
}

class Uid extends Tag {
  final int id;
  final String username;

  Uid(this.id, this.username)
      : assert(id != null),
        assert(username != null),
        super(TagType.Uid, props: [id, username]);
}

class UnderlineEnd extends Tag {
  UnderlineEnd() : super(TagType.UnderlineEnd);
}

class UnderlineStart extends Tag {
  UnderlineStart() : super(TagType.UnderlineStart);
}

class Reply extends Tag {
  final int topicId;
  final int pageIndex;
  final int postId;
  final int userId;
  final String username;
  final DateTime dateTime;

  Reply({
    this.topicId,
    this.pageIndex,
    this.postId,
    this.userId,
    this.username,
    this.dateTime,
  })  : assert(topicId != null),
        // assert(pageIndex != null),
        // assert(postId != null),
        // assert(userId != null),
        // assert(username != null),
        assert(dateTime != null),
        super(TagType.Reply, props: [
          topicId,
          pageIndex,
          postId,
          userId,
          username,
          dateTime,
        ]);
}

// class ListStart extends Tag {
//   ListStart() : super(TagType.ListStart);
// }

// class ListEnd extends Tag {
//   ListEnd() : super(TagType.ListEnd);
// }

// class ListItemStart extends Tag {
//   ListItemStart() : super(TagType.ListItemStart);
// }

// class ListItemEnd extends Tag {
//   ListItemEnd() : super(TagType.ListItemEnd);
// }
