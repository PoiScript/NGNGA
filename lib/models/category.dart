class Category {
  final int id;
  final String title;
  final bool isSubcategory;

  Category({
    this.id,
    this.title,
    this.isSubcategory,
  });

  factory Category.fromString(String string) {
    var split = string.split(",");

    if (split.length != 3) {
      return null;
    }

    var id = int.tryParse(split[0]);
    var isSubcategory = int.tryParse(split[2]);

    if (id == null || isSubcategory == null) {
      return null;
    }

    return Category(
      id: id,
      title: split[1],
      isSubcategory: isSubcategory == 0,
    );
  }

  @override
  String toString() {
    return "$id,$title,${isSubcategory ? 1 : 0}";
  }
}
