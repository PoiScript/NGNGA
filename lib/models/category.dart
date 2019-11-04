class Category {
  final int id;
  final String title;

  Category({
    this.id,
    this.title,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['tid'],
      title: json['subject'],
    );
  }
}
