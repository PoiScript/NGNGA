class Topic {
  final int id;
  final String title;
  final int lastPostedAt;
  final int postsCount;

  Topic({
    this.id,
    this.title,
    this.lastPostedAt,
    this.postsCount,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['tid'],
      title: json['subject'],
      lastPostedAt: json['lastpost'],
      postsCount: json['replies'],
    );
  }
}
