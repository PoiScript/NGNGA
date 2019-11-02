class Post {
  final int id;
  final int topicId;
  final int userId;
  final int replyTo;
  final DateTime createdAt;
  final String content;
  final String client;

  final int upVote;
  final int downVote;

  Post({
    this.id,
    this.topicId,
    this.userId,
    this.replyTo,
    this.createdAt,
    this.content,
    this.client,
    this.upVote,
    this.downVote,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['pid'],
      topicId: json['tid'],
      userId: json['authorid'],
      replyTo: json['reply_to'],
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(json['postdatetimestamp'] * 1000),
      content: json['content'],
      client: json['from_client'],
      upVote: json["score"],
      downVote: json["score_2"],
    );
  }
}
