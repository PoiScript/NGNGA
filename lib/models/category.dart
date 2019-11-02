class Category {
  final int id;
  final String title;
  final int lastPostedAt;
  final int postsCount;

  Category({
    this.id,
    this.title,
    this.lastPostedAt,
    this.postsCount,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['tid'],
      title: json['subject'],
      lastPostedAt: json['lastpost'],
      postsCount: json['replies'],
    );
  }
}
