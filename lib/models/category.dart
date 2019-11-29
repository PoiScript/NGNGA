import 'package:flutter/material.dart';

const int _subcategoryMask = 32768;

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

  factory Category.fromJson(Map<String, dynamic> json) {
    if (json['topic_misc_var'] is Map) {
      if (json['topic_misc_var']['3'] is int) {
        return Category(
          id: json['topic_misc_var']['3'],
          title: json['subject'],
          isSubcategory: false,
        );
      }
    }

    if (json['type'] is int &&
        json['type'] & _subcategoryMask == _subcategoryMask) {
      return Category(
        id: json['tid'],
        title: json['subject'],
        isSubcategory: true,
      );
    }

    return null;
  }
}
