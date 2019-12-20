import 'dart:collection';

abstract class Tag extends LinkedListEntry<Tag> {
  final List<Object> props;

  Tag({this.props = const []});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    } else if (other is Tag && runtimeType == other.runtimeType) {
      if (props.length != other.props.length) return false;
      for (int index = 0; index < props.length; index += 1) {
        if (props[index] != other.props[index]) return false;
      }
      return true;
    } else {
      return false;
    }
  }

  @override
  int get hashCode => runtimeType.hashCode ^ _propsHashCode;

  int get _propsHashCode {
    int hashCode = 0;
    for (Object prop in props) {
      hashCode = hashCode ^ prop.hashCode;
    }
    return hashCode;
  }

  @override
  String toString() {
    if (props.isEmpty) {
      return '$runtimeType';
    } else {
      return '$runtimeType(${props.map((prop) => prop.toString()).join(',')})';
    }
  }
}

class AlignEndTag extends Tag {}

class AlignStartTag extends Tag {
  final String value;

  AlignStartTag(this.value) : super(props: [value]);
}

class BoldEndTag extends Tag {}

class BoldStartTag extends Tag {}

class CollapseEndTag extends Tag {}

class CollapseStartTag extends Tag {
  final String description;

  CollapseStartTag(String desc)
      : description = desc ?? '点击显示隐藏的内容',
        super(props: [desc]);
}

class ColorEndTag extends Tag {}

class ColorStartTag extends Tag {
  final String value;

  ColorStartTag(this.value)
      : assert(value != null),
        super(props: [value]);
}

class DeleteEndTag extends Tag {}

class DeleteStartTag extends Tag {}

class FontEndTag extends Tag {}

class FontStartTag extends Tag {
  final String value;

  FontStartTag(this.value)
      : assert(value != null),
        super(props: [value]);
}

class HeadingEndTag extends Tag {}

class HeadingStartTag extends Tag {}

class ImageTag extends Tag {
  final String url;

  ImageTag(this.url)
      : assert(url != null),
        super(props: [url]);
}

class ItalicEndTag extends Tag {}

class ItalicStartTag extends Tag {}

class LinkEndTag extends Tag {}

class LinkStartTag extends Tag {
  final String url;

  LinkStartTag(this.url)
      : assert(url != null && url.isNotEmpty),
        super(props: [url]);
}

class MetionsTag extends Tag {
  final String username;

  MetionsTag(this.username)
      : assert(username != null),
        super(props: [username]);
}

class ParagraphEndTag extends Tag {}

class ParagraphStartTag extends Tag {}

class PidTag extends Tag {
  final int postId;
  final int topicId;
  final int pageIndex;
  final String content;

  PidTag(this.postId, this.topicId, this.pageIndex, this.content)
      : assert(postId != null),
        assert(topicId != null),
        assert(pageIndex != null),
        assert(content != null),
        super(props: [postId, topicId, pageIndex, content]);
}

class QuoteEndTag extends Tag {}

class QuoteStartTag extends Tag {}

class RuleTag extends Tag {}

class SizeEndTag extends Tag {}

class SizeStartTag extends Tag {
  final String value;

  SizeStartTag(this.value)
      : assert(value != null),
        super(props: [value]);
}

class StickerTag extends Tag {
  final String filename;

  StickerTag(this.filename)
      : assert(filename != null),
        super(props: [filename]);
}

class TableCellEndTag extends Tag {}

class TableCellStartTag extends Tag {}

class TableEndTag extends Tag {}

class TableRowEndTag extends Tag {}

class TableRowStartTag extends Tag {}

class TableStartTag extends Tag {}

class TextTag extends Tag {
  final String content;

  TextTag(this.content)
      : assert(content != null),
        super(props: [content]);
}

class UidTag extends Tag {
  final int id;
  final String username;

  UidTag(this.id, this.username)
      : assert(id != null),
        assert(username != null),
        super(props: [id, username]);
}

class UnderlineEndTag extends Tag {}

class UnderlineStartTag extends Tag {}

class ReplyTag extends Tag {
  final int topicId;
  final int pageIndex;
  final int postId;
  final int userId;
  final String username;
  final DateTime dateTime;

  ReplyTag({
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
        super(props: [
          topicId,
          pageIndex,
          postId,
          userId,
          username,
          dateTime,
        ]);
}

class ListItemStartTag extends Tag {}

class ListItemEndTag extends Tag {}
