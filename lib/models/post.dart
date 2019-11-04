import 'package:flutter/widgets.dart';

class Post {
  final int id;
  final int topicId;
  final int userId;
  final int replyTo;
  final DateTime createdAt;
  final String content;
  final String client;

  final int index;

  final int upVote;
  final int downVote;

  Post({
    @required this.id,
    @required this.topicId,
    @required this.userId,
    @required this.replyTo,
    @required this.createdAt,
    @required this.content,
    @required this.client,
    @required this.upVote,
    @required this.downVote,
    @required this.index,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['pid'],
      topicId: json['tid'],
      userId: json['authorid'],
      replyTo: json['reply_to'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        json['postdatetimestamp'] * 1000,
      ),
      content: json['content'],
      client: json['from_client'],
      upVote: json["score"],
      downVote: json["score_2"],
      index: json['lou'],
    );
  }
}
