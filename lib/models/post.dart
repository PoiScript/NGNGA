import 'package:flutter/widgets.dart';

enum Vendor { android, apple, windows }

class Post {
  final int id;
  final int topicId;
  final int userId;
  final int replyTo;
  final DateTime createdAt;
  final DateTime editedAt;
  final String editedBy;
  final String content;
  final String subject;
  final Vendor vendor;
  final String vendorDetail;

  final int index;

  final int vote;

  final List<Attachment> attachments;

  final List<int> commentIds;
  final int commentTo;

  Post({
    this.id,
    this.topicId,
    this.userId,
    this.replyTo,
    this.createdAt,
    this.subject,
    this.content,
    this.vendor,
    this.vendorDetail,
    this.vote,
    this.index,
    this.editedAt,
    this.editedBy,
    this.attachments,
    this.commentTo,
    this.commentIds,
  })  : assert(id != null),
        assert(topicId != null),
        assert(userId != null),
        assert(index != null),
        assert(vote != null),
        assert(createdAt != null),
        assert(content != null),
        assert(attachments != null),
        assert(editedBy == null || editedAt != null,
            'editedAt should be set if editedBy is set'),
        assert(
            (vendorDetail == null && vendor == null) ||
                (vendorDetail != null && vendor != null),
            'vendor and vendorDetail should be set at the same time');

  Post copy({
    int id,
    int topicId,
    int userId,
    int replyTo,
    DateTime createdAt,
    String subject,
    String content,
    Vendor vendor,
    String vendorDetail,
    int vote,
    int index,
    DateTime editedAt,
    String editedBy,
    List<Attachment> attachments,
    int commentTo,
    List<int> commentIds,
  }) =>
      Post(
        id: id ?? this.id,
        topicId: topicId ?? this.topicId,
        userId: userId ?? this.userId,
        replyTo: replyTo ?? this.replyTo,
        createdAt: createdAt ?? this.createdAt,
        subject: subject ?? this.subject,
        content: content ?? this.content,
        vendor: vendor ?? this.vendor,
        vendorDetail: vendorDetail ?? this.vendorDetail,
        vote: vote ?? this.vote,
        index: index ?? this.index,
        editedAt: editedAt ?? this.editedAt,
        editedBy: editedBy ?? this.editedBy,
        attachments: attachments ?? this.attachments,
        commentTo: commentTo ?? this.commentTo,
        commentIds: commentIds ?? this.commentIds,
      );

  factory Post.fromJson(Map<String, dynamic> json) {
    DateTime editedAt;
    String editedBy;

    if (json['alterinfo'] is String) {
      for (var info in (json['alterinfo'] as String)
          .split('\\t')
          .map((s) => s.trim())
          .where((s) => s.length >= 2)
          .map((s) => s.substring(1, s.length - 1))) {
        var words = info.split(' ');
        if (words.first.startsWith('E')) {
          var timestamp = int.tryParse(words.first.substring(1));
          if (timestamp != null) {
            editedAt = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
          }
          if (words.last != '0') {
            editedBy = words.last;
          }
        }
      }
    }

    Vendor vendor;
    String vendorDetail;

    if (json['from_client'] is String && json['from_client'].isNotEmpty) {
      var space = json['from_client'].indexOf(' ');
      if (space != -1) {
        switch (int.parse(json['from_client'].substring(0, space))) {
          case 7:
          case 101:
            vendor = Vendor.apple;
            vendorDetail = json['from_client'].substring(space + 1).trim();
            break;
          case 8:
          case 100:
            vendor = Vendor.android;
            vendorDetail = json['from_client'].substring(space + 1).trim();
            break;
          case 9:
          case 103:
            vendor = Vendor.windows;
            vendorDetail = json['from_client'].substring(space + 1).trim();
            break;
          default:
            break;
        }
      }
    }

    List<Attachment> attachments = [];

    if (json['attachs'] is List) {
      for (final item in json['attachs']) {
        attachments.add(Attachment.fromJson(item));
      }
    } else if (json['attachs'] is Map) {
      for (final value in json['attachs'].values) {
        attachments.add(Attachment.fromJson(value));
      }
    }

    List<int> commentIds = [];

    if (json['comment_id'] is List) {
      for (String id in json['comment_id']) {
        commentIds.add(int.parse(id));
      }
    }

    return Post(
      id: json['pid'],
      topicId: json['tid'],
      userId: json['authorid'],
      replyTo: json['reply_to'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        json['postdatetimestamp'] * 1000,
      ),
      subject: json['subject']?.trim() ?? '',
      content: json['content'],
      vote: json['score'],
      index: json['lou'],
      editedAt: editedAt,
      editedBy: editedBy,
      vendor: vendor,
      vendorDetail: vendorDetail,
      attachments: attachments,
      commentIds: commentIds,
      commentTo: json['comment_to_id'],
    );
  }
}

class Attachment {
  final String url;
  final String name;

  Attachment({
    @required this.url,
    @required this.name,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      name: json['url_utf8_org_name'],
      url: json['attachurl'],
    );
  }
}
