class Category {
  final int id;
  final String title;
  final bool isSubcategory;

  const Category({
    this.id,
    this.title,
    this.isSubcategory = false,
  })  : assert(id != null),
        assert(title != null),
        assert(isSubcategory != null);

  Category.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        title = json["title"],
        isSubcategory = json["isSubcategory"];

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "isSubcategory": isSubcategory,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Category && other.id == id;

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ isSubcategory.hashCode;
}
