class Post {
  final int id;
  final int topicId;
  final int userId;
  final int replyTo;
  final DateTime createdAt;
  final String content;
  final String client;

  Post({
    this.id,
    this.topicId,
    this.userId,
    this.replyTo,
    this.createdAt,
    this.content,
    this.client,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      topicId: json['threadId'],
      userId: json['authorId'],
      replyTo: json['replyTo'],
      createdAt: json['postDatetime'],
      content: json['content'],
      client: json['client'],
    );
  }
}
