import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';

import 'attachment.dart';

part 'post.g.dart';

enum Vendor { android, apple, windows, none }

class RawPost {
  final String alterinfo;
  final String fromClient;
  final int pid;
  final int tid;
  final int fid;
  final int authorid;
  final int replyTo;
  final int postdatetimestamp;
  final String subject;
  final String content;
  final int score;
  final int lou;
  final Object attachs;
  final String s17;
  final List<String> commentId;
  final int commentToId;

  RawPost({
    this.alterinfo,
    this.fromClient,
    this.pid,
    this.tid,
    this.fid,
    this.authorid,
    this.replyTo,
    this.postdatetimestamp,
    this.subject,
    this.content,
    this.score,
    this.lou,
    this.attachs,
    this.s17,
    this.commentId,
    this.commentToId,
  });

  factory RawPost.fromJson(Map<String, dynamic> json) {
    return RawPost(
      alterinfo: json['alterinfo'] ?? '',
      fromClient: json['from_client'] ?? '',
      pid: json['pid'],
      tid: json['tid'] ?? -1,
      fid: json['fid'] ?? -1,
      authorid: json['authorid'],
      replyTo: json['reply_to'],
      postdatetimestamp: json['postdatetimestamp'] ?? 0,
      subject: json['subject'] ?? '',
      content: json['content'] ?? '',
      score: json['score'] ?? 0,
      lou: json['lou'],
      attachs: json['attachs'],
      s17: json['17'] ?? '',
      commentId: List<String>.from(json['comment_id']?? []) ,
      commentToId: json['comment_to_id'],
    );
  }
}

abstract class Post implements Built<Post, PostBuilder> {
  Post._();

  factory Post([Function(PostBuilder) updates]) = _$Post;

  int get id;

  int get index;

  int get categoryId;

  int get topicId;

  int get userId;

  @nullable
  int get replyTo;

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

  @nullable
  int get commentTo;

  BuiltList<int> get topReplyIds;

  factory Post.fromRaw(RawPost raw) => Post(
        (b) => b
          ..id = raw.pid == 0 ? 2 ^ 32 - raw.tid : raw.pid
          ..index = raw.lou
          ..vendor = raw.fromClient.startsWith('7 ') || raw.fromClient.startsWith('101 ')
              ? Vendor.apple
              : raw.fromClient.startsWith('8 ') || raw.fromClient.startsWith('100 ')
                  ? Vendor.android
                  : raw.fromClient.startsWith('9 ') || raw.fromClient.startsWith('103 ')
                      ? Vendor.windows
                      : Vendor.none
          ..categoryId = raw.fid
          ..topicId = raw.tid
          ..userId = raw.authorid
          ..replyTo = raw.replyTo
          ..createdAt =
              DateTime.fromMillisecondsSinceEpoch(raw.postdatetimestamp * 1000)
          ..content = raw.content
          ..subject = raw.subject
          ..vendorDetail = raw.fromClient.startsWith('7 ') ||
                  raw.fromClient.startsWith('8 ') ||
                  raw.fromClient.startsWith('9 ')
              ? raw.fromClient.substring(2)
              : raw.fromClient.startsWith('100 ') ||
                      raw.fromClient.startsWith('101 ') ||
                      raw.fromClient.startsWith('103 ')
                  ? raw.fromClient.substring(4)
                  : ''
          ..vote = raw.score
          ..attachments = ListBuilder(raw.attachs is List
              ? List.of(raw.attachs).map((v) => Attachment.fromJson(v))
              : raw.attachs is Map
                  ? Map.of(raw.attachs)
                      .values
                      .map((v) => Attachment.fromJson(v))
                  : [])
          ..commentIds = ListBuilder(raw.commentId.map(int.parse))
          ..commentTo = raw.commentToId
          ..topReplyIds =
              ListBuilder(raw.s17.split(',').where((i) => i.isNotEmpty).map(int.parse)),
      );
}
