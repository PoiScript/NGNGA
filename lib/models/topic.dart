import 'dart:convert';

import 'package:ngnga/models/category.dart';

// used for `type`
const int _lockedMask = 1024;
const int _attachmentMask = 8192;
const int _subcategoryMask = 32768;
const int _categoryMask = 2097152;

// used for `topic_misc`
const int _colorRedMask = 1;
const int _colorBlueMask = 2;
const int _colorGreenMask = 4;
const int _colorOrangeMas = 8;
const int _colorSliverMask = 16;

const int _styleBoldMask = 32;
const int _styleItalicMask = 64;
const int _styleUnderlineMask = 128;

// const int _allAnonymousMask = 2097152;
const int _allHideenMask = 33554432;
const int _singleReplyMask = 1073741824;
const int _reverseOrderMask = 262144;

abstract class TopicItem {}

enum TopicDecoration {
  redColor,
  blueColor,
  greenColor,
  orangeColor,
  silverColor,
  boldStyle,
  italicStyle,
  underlineStyle,
  locked,
  attachment,
  subcategory,
  category,
  allAnonymous,
  allHideen,
  singleReply,
  reverseOrder,
}

class Topic extends TopicItem {
  final int id;

  final String title;

  final List<TopicDecoration> decorations;

  final String author;
  final DateTime createdAt;

  final String lastPoster;
  final DateTime lastPostedAt;

  final int postsCount;

  final String label;

  final Category category;

  Topic({
    this.id,
    this.title,
    this.decorations,
    this.createdAt,
    this.lastPostedAt,
    this.postsCount,
    this.label,
    this.author,
    this.lastPoster,
    this.category,
  })  : assert(id != null),
        assert(title != null),
        assert(decorations != null),
        assert(createdAt != null),
        assert(lastPostedAt != null),
        assert(postsCount != null);

  factory Topic.fromJson(Map<String, dynamic> json) {
    String label;

    if (json['parent'] is List) {
      label = json['parent'].last;
    } else if (json['parent'] is Map) {
      label = json['parent']['2'];
    }

    Category category;
    List<TopicDecoration> decorations = [];

    Map<String, int> topicMisc =
        _decodeTopicMiscString(json['topic_misc'] ?? '')
          ..addAll(json['topic_misc_var'] is Map
              ? Map<String, int>.from(json['topic_misc_var'])
              : {});

    if (topicMisc.containsKey('1')) {
      int bits = topicMisc['1'];
      _parseTopicMiscBits(bits, decorations);
    }

    if (topicMisc.containsKey('3')) {
      int bits = topicMisc['3'];
      category = Category(
        id: bits,
        title: json['subject'],
        isSubcategory: false,
      );
    }

    int type = json['type'];

    if (type & _lockedMask == _lockedMask) {
      decorations.add(TopicDecoration.locked);
    }
    if (type & _attachmentMask == _attachmentMask) {
      decorations.add(TopicDecoration.attachment);
    }
    if (type & _subcategoryMask == _subcategoryMask) {
      category = Category(
        id: json['tid'],
        title: json['subject'],
        isSubcategory: true,
      );
      decorations.add(TopicDecoration.subcategory);
    }
    if (type & _categoryMask == _categoryMask) {
      decorations.add(TopicDecoration.category);
    }

    return Topic(
      id: json['tid'],
      title: json['subject'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        json['postdate'] * 1000,
      ),
      lastPostedAt: DateTime.fromMillisecondsSinceEpoch(
        json['lastpost'] * 1000,
      ),
      postsCount: json['replies'],
      label: label,
      author: json['authorid'] is int
          ? (json['author'] is String
              ? json['author']
              : 'UID${json['authorid']}')
          : '#ANONYMOUS#',
      lastPoster: json['lastposter'],
      decorations: decorations,
      category: category,
    );
  }
}

Map<String, int> _decodeTopicMiscString(String topicMsic) {
  Map<String, int> map = {};
  int len = topicMsic.length;
  final bytes = base64.decode(topicMsic.padRight(
    len % 4 == 3 ? len + 1 : (len % 4 == 2 ? len + 2 : len),
    '=',
  ));

  var index = 0;

  while (index < bytes.length) {
    if (bytes[index] == 1 && index + 4 < bytes.length) {
      map['1'] = (bytes[index + 1] << 24) +
          (bytes[index + 2] << 16) +
          (bytes[index + 3] << 8) +
          bytes[index + 4];
      index += 5;
    } else if (bytes[index] == 3 && index + 4 < bytes.length) {
      map['3'] = (bytes[index + 1] << 24) +
          (bytes[index + 2] << 16) +
          (bytes[index + 3] << 8) +
          bytes[index + 4];
      index += 5;
    } else {
      index += 1;
    }
  }
  return map;
}

_parseTopicMiscBits(int bits, List<TopicDecoration> decorations) {
  if (bits & _colorRedMask == _colorRedMask) {
    decorations.add(TopicDecoration.redColor);
  }
  if (bits & _colorBlueMask == _colorBlueMask) {
    decorations.add(TopicDecoration.blueColor);
  }
  if (bits & _colorGreenMask == _colorGreenMask) {
    decorations.add(TopicDecoration.greenColor);
  }
  if (bits & _colorOrangeMas == _colorOrangeMas) {
    decorations.add(TopicDecoration.orangeColor);
  }
  if (bits & _colorSliverMask == _colorSliverMask) {
    decorations.add(TopicDecoration.silverColor);
  }
  if (bits & _styleBoldMask == _styleBoldMask) {
    decorations.add(TopicDecoration.boldStyle);
  }
  if (bits & _styleItalicMask == _styleItalicMask) {
    decorations.add(TopicDecoration.italicStyle);
  }
  if (bits & _styleUnderlineMask == _styleUnderlineMask) {
    decorations.add(TopicDecoration.underlineStyle);
  }
  // if (bits & _allAnonymousMask == _allAnonymousMask) {
  //   decorations.add(TopicDecoration.allAnonymous);
  // }
  if (bits & _allHideenMask == _allHideenMask) {
    decorations.add(TopicDecoration.allHideen);
  }
  if (bits & _singleReplyMask == _singleReplyMask) {
    decorations.add(TopicDecoration.singleReply);
  }
  if (bits & _reverseOrderMask == _reverseOrderMask) {
    decorations.add(TopicDecoration.reverseOrder);
  }
}
