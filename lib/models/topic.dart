class Topic {
  final int id;
  final String title;
  final DateTime lastPostedAt;
  final int postsCount;
  final List<Object> category;

  Topic({
    this.id,
    this.title,
    this.lastPostedAt,
    this.postsCount,
    this.category,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['tid'],
      title: json['subject'],
      lastPostedAt:
          DateTime.fromMillisecondsSinceEpoch(json['lastpost'] * 1000),
      postsCount: json['replies'],
      category: json['parent'],
    );
  }
}
