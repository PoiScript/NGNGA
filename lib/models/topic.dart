class Topic {
  final int id;
  final String title;
  final DateTime lastPostedAt;
  final DateTime createdAt;
  final int postsCount;
  final List<int> ancestors;
  final String category;
  final String author;
  final String lastPoster;

  Topic({
    this.id,
    this.title,
    this.createdAt,
    this.lastPostedAt,
    this.postsCount,
    this.category,
    this.ancestors,
    this.author,
    this.lastPoster,
  })  : assert(id != null),
        assert(title != null),
        assert(createdAt != null),
        assert(lastPostedAt != null),
        assert(postsCount != null),
        assert(ancestors != null);

  factory Topic.fromJson(Map<String, dynamic> json) {
    List<int> ancestors = [];
    String category;

    if (json['parent'] is List) {
      List parent = List.from(json['parent']);
      category = parent.removeLast();
      ancestors = List<int>.from(parent);
    } else if (json['parent'] is Map) {
      print(json['parent']);
      List parent = (Map.from(json['parent']).entries.toList()
            ..sort((a, b) => a.key.compareTo(b.key)))
          .map((e) => e.value)
          .toList();
      category = parent.removeLast();
      ancestors = List<int>.from(parent);
    }

    return Topic(
      id: json['tid'],
      title: json['subject'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['postdate'] * 1000),
      lastPostedAt:
          DateTime.fromMillisecondsSinceEpoch(json['lastpost'] * 1000),
      postsCount: json['replies'],
      ancestors: ancestors,
      category: category,
      author: json['author'],
      lastPoster: json['lastposter'],
    );
  }
}
