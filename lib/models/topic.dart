import 'dart:convert';

import 'package:ngnga/models/category.dart';

const int _locakedMask = 1024;
const int _attachmentMask = 8192;
const int _subcategoryMask = 32768;

const int _colorRedMask = 1;
const int _colorBlueMask = 2;
const int _colorGreenMask = 4;
const int _colorOrangeMas = 8;
const int _colorSliverMask = 16;

const int _styleBoldMask = 32;
const int _styleItalicMask = 64;
const int _styleUnderlineMask = 128;

enum TitleColor { none, red, blue, green, orange, silver }

enum TitleStyle { none, bold, italic, underline }

class Topic {
  final int id;

  final String title;
  final TitleColor titleColor;
  final TitleStyle titleStyle;

  final String author;
  final DateTime createdAt;

  final String lastPoster;
  final DateTime lastPostedAt;

  final int postsCount;

  final String label;

  final bool isLocked;
  final bool hasAttachment;
  final Category category;

  Topic({
    this.id,
    this.title,
    this.titleColor,
    this.titleStyle,
    this.createdAt,
    this.lastPostedAt,
    this.postsCount,
    this.label,
    this.author,
    this.lastPoster,
    this.isLocked,
    this.hasAttachment,
    this.category,
  })  : assert(id != null),
        assert(title != null),
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

    TitleColor titleColor;
    TitleStyle titleStyle;
    Category category;

    if (json['topic_misc'] is String) {
      final bytes = base64.decode(
        json['topic_misc'].length % 4 == 3
            ? '${json['topic_misc']}='
            : json['topic_misc'].length % 4 == 2
                ? '${json['topic_misc']}=='
                : json['topic_misc'],
      );

      var index = 0;

      while (index < bytes.length) {
        if (bytes[index] == 1 && index + 4 < bytes.length) {
          final bits = (bytes[index + 1] << 24) +
              (bytes[index + 2] << 16) +
              (bytes[index + 3] << 8) +
              bytes[index + 4];

          if (bits != null) {
            if (bits & _colorRedMask == _colorRedMask) {
              titleColor = TitleColor.red;
            } else if (bits & _colorBlueMask == _colorBlueMask) {
              titleColor = TitleColor.blue;
            } else if (bits & _colorGreenMask == _colorGreenMask) {
              titleColor = TitleColor.green;
            } else if (bits & _colorOrangeMas == _colorOrangeMas) {
              titleColor = TitleColor.orange;
            } else if (bits & _colorSliverMask == _colorSliverMask) {
              titleColor = TitleColor.silver;
            }

            if (bits & _styleBoldMask == _styleBoldMask) {
              titleStyle = TitleStyle.bold;
            } else if (bits & _styleItalicMask == _styleItalicMask) {
              titleStyle = TitleStyle.italic;
            } else if (bits & _styleUnderlineMask == _styleUnderlineMask) {
              titleStyle = TitleStyle.underline;
            }
          }

          index += 5;
        } else if (bytes[index] == 3 && index + 4 < bytes.length) {
          final bits = (bytes[index + 1] << 24) +
              (bytes[index + 2] << 16) +
              (bytes[index + 3] << 8) +
              bytes[index + 4];

          category = Category(
            id: bits,
            title: json['subject'],
            isSubcategory: false,
          );

          index += 5;
        } else {
          index += 1;
        }
      }
    }

    if (json['topic_misc_var'] is Map) {
      Map<String, int> misc = Map<String, int>.from(json['topic_misc_var']);

      if (misc['1'] != null) {
        if (misc['1'] & _colorRedMask == _colorRedMask) {
          titleColor = TitleColor.red;
        } else if (misc['1'] & _colorBlueMask == _colorBlueMask) {
          titleColor = TitleColor.blue;
        } else if (misc['1'] & _colorGreenMask == _colorGreenMask) {
          titleColor = TitleColor.green;
        } else if (misc['1'] & _colorOrangeMas == _colorOrangeMas) {
          titleColor = TitleColor.orange;
        } else if (misc['1'] & _colorSliverMask == _colorSliverMask) {
          titleColor = TitleColor.silver;
        }

        if (misc['1'] & _styleBoldMask == _styleBoldMask) {
          titleStyle = TitleStyle.bold;
        } else if (misc['1'] & _styleItalicMask == _styleItalicMask) {
          titleStyle = TitleStyle.italic;
        } else if (misc['1'] & _styleUnderlineMask == _styleUnderlineMask) {
          titleStyle = TitleStyle.underline;
        }
      }

      if (misc['3'] != null) {
        category = Category(
          id: misc['3'],
          title: json['subject'],
          isSubcategory: false,
        );
      }
    }

    int type = json['type'];

    if (type & _subcategoryMask == _subcategoryMask) {
      category = Category(
        id: json['tid'],
        title: json['subject'],
        isSubcategory: true,
      );
    }

    return Topic(
      id: json['tid'],
      title: json['subject'],
      titleColor: titleColor,
      titleStyle: titleStyle,
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
      isLocked: type & _locakedMask == _locakedMask,
      category: category,
      hasAttachment: type & _attachmentMask == _attachmentMask,
    );
  }

  bool get isBold => titleStyle == TitleStyle.bold;
  bool get isItalic => titleStyle == TitleStyle.italic;
  bool get isUnderline => titleStyle == TitleStyle.underline;
}
