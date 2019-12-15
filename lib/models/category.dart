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
}
