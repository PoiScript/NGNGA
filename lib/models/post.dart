import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';

import 'attachment.dart';

part 'post.g.dart';

enum Vendor { android, apple, windows, none }

abstract class PostItem {}

abstract class Post extends PostItem implements Built<Post, PostBuilder> {
  Post._();

  factory Post([Function(PostBuilder) updates]) = _$Post;

  int get id => postId == 0 ? 2 ^ 32 - topicId : postId;

  int get postId;
  int get index;
  int get categoryId;
  int get topicId;
  int get userId;
  @nullable
  int get replyTo;
  @nullable
  int get commentTo;
  DateTime get createdAt;
  @nullable
  DateTime get editedAt;
  @nullable
  String get editedBy;
  String get content;
  String get subject;
  Vendor get vendor;
  String get vendorDetail;
  int get vote;
  BuiltList<Attachment> get attachments;
  BuiltList<int> get commentIds;
  BuiltList<int> get topReplyIds;

  static void _initializeBuilder(PostBuilder b) => b
    ..vendor = Vendor.none
    ..vendorDetail = '';

  static PostBuilder fromJson(Map<String, dynamic> json) {
    PostBuilder b = PostBuilder();

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
            b.editedAt = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
          }
          if (words.last != '0') {
            b.editedBy = words.last;
          }
        }
      }
    }

    if (json['from_client'] is String && json['from_client'].isNotEmpty) {
      var space = json['from_client'].indexOf(' ');
      if (space != -1) {
        switch (int.parse(json['from_client'].substring(0, space))) {
          case 7:
          case 101:
            b.vendor = Vendor.apple;
            b.vendorDetail = json['from_client'].substring(space + 1).trim();
            break;
          case 8:
          case 100:
            b.vendor = Vendor.android;
            b.vendorDetail = json['from_client'].substring(space + 1).trim();
            break;
          case 9:
          case 103:
            b.vendor = Vendor.windows;
            b.vendorDetail = json['from_client'].substring(space + 1).trim();
            break;
          default:
            break;
        }
      }
    }

    if (json['attachs'] is List) {
      b.attachments.addAll(
        List.of(json['attachs']).map((value) => Attachment.fromJson(value)),
      );
    } else if (json['attachs'] is Map) {
      b.attachments.addAll(
        Map.of(json['attachs'])
            .values
            .map((value) => Attachment.fromJson(value)),
      );
    }

    if (json['comment_id'] is List) {
      for (String id in json['comment_id']) {
        b.commentIds.add(int.parse(id));
      }
    }

    if (json['comment_to_id'] is int) {
      b.commentTo = json['comment_to_id'];
    }

    b.topReplyIds.addAll(((json['17'] ?? '') as String)
        .split(',')
        .where((i) => i.isNotEmpty)
        .map(int.parse));

    b.postId = json['pid'];
    b.topicId = json['tid'];
    b.categoryId = json['fid'];
    b.userId = json['authorid'];
    b.replyTo = json['reply_to'];
    b.createdAt = DateTime.fromMillisecondsSinceEpoch(
      (json['postdatetimestamp'] ?? 0) * 1000,
    );
    b.subject = json['subject'] ?? '';
    b.content = json['content'];
    b.vote = json['score'];
    b.index = json['lou'];

    return b;
  }
}

abstract class Comment extends PostItem
    implements Built<Comment, CommentBuilder> {
  Comment._();

  factory Comment([Function(CommentBuilder) updates]) = _$Comment;

  int get index;
  int get userId;
  int get postId;
  int get commentTo;

  static CommentBuilder fromJson(Map<String, dynamic> json) => CommentBuilder()
    ..index = json['lou']
    ..userId = json['authorid']
    ..postId = json['pid']
    ..commentTo = json['comment_to_id'];
}
