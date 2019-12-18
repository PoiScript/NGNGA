import 'package:flutter/material.dart';

class Category {
  final int id;
  final String title;
  final bool isSubcategory;

  const Category({
    @required this.id,
    @required this.title,
    this.isSubcategory = false,
  })  : assert(id != null),
        assert(title != null),
        assert(isSubcategory != null);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Category &&
        id == other.id &&
        isSubcategory == other.isSubcategory;
  }

  @override
  int get hashCode => id.hashCode ^ isSubcategory.hashCode;
}
