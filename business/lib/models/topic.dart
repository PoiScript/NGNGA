import 'dart:convert';

import 'package:built_value/built_value.dart';
import 'package:flutter/widgets.dart' hide Builder;

import 'category.dart';

part 'topic.g.dart';

// used for `type`
const int _lockedMask = 1024;
const int _attachmentMask = 8192;
const int _subcategoryMask = 32768;
// const int _categoryMask = 2097152;

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

enum TopicTitleColor { red, blue, green, orang, sliver, none }

class RawTopic {
  final int tid;
  final int fid;
  final String subject;
  final int authorid;
  final String author;
  final int postdate;
  final String lastposter;
  final int lastpost;
  final int replies;
  final String error;
  final int type;
  final Map<String, int> topicMisc;

  RawTopic({
    @required this.tid,
    @required this.fid,
    @required this.subject,
    @required this.authorid,
    @required this.author,
    @required this.postdate,
    @required this.lastposter,
    @required this.lastpost,
    @required this.replies,
    @required this.error,
    @required this.type,
    @required this.topicMisc,
  });

  factory RawTopic.fromJson(Map<String, dynamic> json) {
    return RawTopic(
      tid: json['tid'],
      fid: json['fid'],
      subject: json['subject'],
      authorid: json['authorid'] is int ? json['authorid'] : -1,
      author: json['author'],
      postdate: json['postdate'],
      lastposter: json['lastposter'],
      lastpost: json['lastpost'],
      replies: json['replies'],
      error: json['error'],
      type: json['type'],
      topicMisc: _decodeTopicMiscString(json['topic_misc'] ?? '')
        ..addAll(Map<String, int>.from(json['topic_misc_var'] ?? {})),
    );
  }
}

abstract class Topic implements Built<Topic, TopicBuilder> {
  Topic._();

  factory Topic([Function(TopicBuilder) updates]) = _$Topic;

  int get id;

  int get categoryId;

  String get title;

  String get author;

  DateTime get createdAt;

  String get lastPoster;

  DateTime get lastPostedAt;

  int get postsCount;

  @nullable
  String get error;

  bool get isLocked;

  bool get hasAttachment;

  bool get isBold;

  bool get isItalic;

  bool get isUnderline;

  bool get allHideen;

  bool get singleReply;

  bool get reverseOrder;

  TopicTitleColor get titleColor;

  @nullable
  Category get category;

  factory Topic.fromRaw(RawTopic raw) => Topic(
        (b) => b
          ..id = raw.tid
          ..categoryId = raw.fid
          ..title = raw.subject
          ..author = raw.authorid != null
              ? (raw.author != null ? raw.author : 'UID${raw.authorid}')
              : '#ANONYMOUS#'
          ..createdAt = DateTime.fromMillisecondsSinceEpoch(raw.postdate * 1000)
          ..lastPoster = raw.lastposter
          ..lastPostedAt =
              DateTime.fromMillisecondsSinceEpoch(raw.lastpost * 1000)
          ..postsCount = raw.replies
          ..error = raw.error
          ..isLocked = _isSet(raw.type, _lockedMask)
          ..hasAttachment = _isSet(raw.type, _attachmentMask)
          ..isBold = _isSet(raw.topicMisc['1'], _styleBoldMask)
          ..isItalic = _isSet(raw.topicMisc['1'], _styleItalicMask)
          ..isUnderline = _isSet(raw.topicMisc['1'], _styleUnderlineMask)
          ..allHideen = _isSet(raw.topicMisc['1'], _allHideenMask)
          ..singleReply = _isSet(raw.topicMisc['1'], _singleReplyMask)
          ..reverseOrder = _isSet(raw.topicMisc['1'], _reverseOrderMask)
          ..titleColor = _isSet(raw.topicMisc['1'], _colorRedMask)
              ? TopicTitleColor.red
              : _isSet(raw.topicMisc['1'], _colorBlueMask)
                  ? TopicTitleColor.blue
                  : _isSet(raw.topicMisc['1'], _colorGreenMask)
                      ? TopicTitleColor.green
                      : _isSet(raw.topicMisc['1'], _colorOrangeMas)
                          ? TopicTitleColor.orang
                          : _isSet(raw.topicMisc['1'], _colorSliverMask)
                              ? TopicTitleColor.sliver
                              : TopicTitleColor.none
          ..category = _isSet(raw.type, _subcategoryMask)
              ? (CategoryBuilder()
                ..id = raw.tid
                ..title = raw.subject
                ..isSubcategory = true)
              : raw.topicMisc.containsKey('3')
                  ? (CategoryBuilder()
                    ..id = raw.topicMisc['3']
                    ..title = raw.subject
                    ..isSubcategory = false)
                  : null,
      );
}

bool _isSet(int bits, int mask) => bits != null && bits & mask == mask;

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
