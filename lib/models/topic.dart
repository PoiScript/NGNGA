import 'dart:convert';

import 'package:ngnga/models/category.dart';

const int _MASK_LOCKED = 1024;
const int _MASK_ATTACHMENT = 8192;
const int _MASK_SUBCATEGORY = 32768;

const int _MASK_COLOR_RED = 1;
const int _MASK_COLOR_BLUE = 2;
const int _MASK_COLOR_GREEN = 4;
const int _MASK_COLOR_ORANGE = 8;
const int _MASK_COLOR_SILVER = 16;

const int _MASK_STYLE_BOLD = 32;
const int _MASK_STYLE_ITALIC = 64;
const int _MASK_STYLE_UNDERLINE = 128;

enum TitleColor {
  Default,
  Red,
  Blue,
  Green,
  Orange,
  Silver,
}

enum TitleStyle {
  None,
  Bold,
  Italic,
  Underline,
}

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
            ? "${json['topic_misc']}="
            : json['topic_misc'].length % 4 == 2
                ? "${json['topic_misc']}=="
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
            if (bits & _MASK_COLOR_RED == _MASK_COLOR_RED) {
              titleColor = TitleColor.Red;
            } else if (bits & _MASK_COLOR_BLUE == _MASK_COLOR_BLUE) {
              titleColor = TitleColor.Blue;
            } else if (bits & _MASK_COLOR_GREEN == _MASK_COLOR_GREEN) {
              titleColor = TitleColor.Green;
            } else if (bits & _MASK_COLOR_ORANGE == _MASK_COLOR_ORANGE) {
              titleColor = TitleColor.Orange;
            } else if (bits & _MASK_COLOR_SILVER == _MASK_COLOR_SILVER) {
              titleColor = TitleColor.Silver;
            }

            if (bits & _MASK_STYLE_BOLD == _MASK_STYLE_BOLD) {
              titleStyle = TitleStyle.Bold;
            } else if (bits & _MASK_STYLE_ITALIC == _MASK_STYLE_ITALIC) {
              titleStyle = TitleStyle.Italic;
            } else if (bits & _MASK_STYLE_UNDERLINE == _MASK_STYLE_UNDERLINE) {
              titleStyle = TitleStyle.Underline;
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

      if (misc["1"] != null) {
        if (misc["1"] & _MASK_COLOR_RED == _MASK_COLOR_RED) {
          titleColor = TitleColor.Red;
        } else if (misc["1"] & _MASK_COLOR_BLUE == _MASK_COLOR_BLUE) {
          titleColor = TitleColor.Blue;
        } else if (misc["1"] & _MASK_COLOR_GREEN == _MASK_COLOR_GREEN) {
          titleColor = TitleColor.Green;
        } else if (misc["1"] & _MASK_COLOR_ORANGE == _MASK_COLOR_ORANGE) {
          titleColor = TitleColor.Orange;
        } else if (misc["1"] & _MASK_COLOR_SILVER == _MASK_COLOR_SILVER) {
          titleColor = TitleColor.Silver;
        }

        if (misc["1"] & _MASK_STYLE_BOLD == _MASK_STYLE_BOLD) {
          titleStyle = TitleStyle.Bold;
        } else if (misc["1"] & _MASK_STYLE_ITALIC == _MASK_STYLE_ITALIC) {
          titleStyle = TitleStyle.Italic;
        } else if (misc["1"] & _MASK_STYLE_UNDERLINE == _MASK_STYLE_UNDERLINE) {
          titleStyle = TitleStyle.Underline;
        }
      }

      if (misc["3"] != null) {
        category = Category(
          id: misc["3"],
          title: json['subject'],
          isSubcategory: false,
        );
      }
    }

    int type = json['type'];

    if (type & _MASK_SUBCATEGORY == _MASK_SUBCATEGORY) {
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
              : "UID${json['authorid']}")
          : "#ANONYMOUS#",
      lastPoster: json['lastposter'],
      isLocked: type & _MASK_LOCKED == _MASK_LOCKED,
      category: category,
      hasAttachment: type & _MASK_ATTACHMENT == _MASK_ATTACHMENT,
    );
  }

  bool get isBold => titleStyle == TitleStyle.Bold;
  bool get isItalic => titleStyle == TitleStyle.Italic;
  bool get isUnderline => titleStyle == TitleStyle.Underline;
}
