import 'package:flutter/widgets.dart';

enum Vendor {
  Android,
  Apple,
  Windows,
}

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

  final int upVote;
  final int downVote;

  final List<Attachment> attachments;

  final bool isComment;

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
    this.upVote,
    this.downVote,
    this.index,
    this.editedAt,
    this.editedBy,
    this.attachments,
    this.isComment,
  })  : assert(id != null),
        assert(isComment || topicId != null),
        assert(userId != null),
        assert(index != null),
        assert(isComment || upVote != null),
        assert(isComment || createdAt != null),
        assert(isComment || content != null),
        assert(isComment || attachments != null),
        assert(editedBy == null || editedAt != null,
            "editedAt should be set if editedBy is set"),
        assert(
            (vendorDetail == null && vendor == null) ||
                (vendorDetail != null && vendor != null),
            "vendor and vendorDetail should be set at the same time");

  Post vote(int value) {
    return Post(
      id: this.id,
      topicId: this.topicId,
      userId: this.userId,
      replyTo: this.replyTo,
      createdAt: this.createdAt,
      subject: this.subject,
      content: this.content,
      vendor: this.vendor,
      vendorDetail: this.vendorDetail,
      upVote: this.upVote + value,
      downVote: this.downVote,
      index: this.index,
      editedAt: this.editedAt,
      editedBy: this.editedBy,
      attachments: this.attachments,
      isComment: this.isComment,
    );
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    // this post is actually a comment
    if (json['comment_to_id'] != null) {
      return Post(
        id: json['pid'],
        userId: json['authorid'],
        index: json['lou'],
        subject: json['subject']?.trim() ?? "",
        isComment: true,
      );
    }

    DateTime editedAt;
    String editedBy;

    if (json['alterinfo'] is String && json['alterinfo'].isNotEmpty) {
      for (var action in (json['alterinfo'] as String).split("\\t")) {
        action = action.trim();
        if (action.length <= 2) continue;
        action = action.substring(1, action.length - 1);
        var words = action.split(' ');
        if (words.first.startsWith("E")) {
          var timestamp = int.tryParse(words.first.substring(1));
          if (timestamp != null) {
            editedAt = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
          }
          if (words.last != "0") {
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
            vendor = Vendor.Apple;
            vendorDetail = json['from_client'].substring(space + 1).trim();
            break;
          case 8:
          case 100:
            vendor = Vendor.Android;
            vendorDetail = json['from_client'].substring(space + 1).trim();
            break;
          case 9:
          case 103:
            vendor = Vendor.Windows;
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

    return Post(
      id: json['pid'],
      topicId: json['tid'],
      userId: json['authorid'],
      replyTo: json['reply_to'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        json['postdatetimestamp'] * 1000,
      ),
      subject: json['subject']?.trim() ?? "",
      content: json['content'],
      upVote: json["score"],
      downVote: json["score_2"],
      index: json['lou'],
      editedAt: editedAt,
      editedBy: editedBy,
      vendor: vendor,
      vendorDetail: vendorDetail,
      attachments: attachments,
      isComment: false,
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
