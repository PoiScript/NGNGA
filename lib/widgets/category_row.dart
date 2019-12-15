import 'package:flutter/material.dart';

import 'package:ngnga/models/category.dart';

class CategoryRow extends StatelessWidget {
  final Category category;
  final Function({int categoryId, bool isSubcategory}) navigateToCategory;

  CategoryRow({
    @required this.category,
    @required this.navigateToCategory,
  })  : assert(category != null),
        assert(navigateToCategory != null);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(category.title),
      trailing: const Icon(Icons.keyboard_arrow_right),
      onTap: () => navigateToCategory(
        categoryId: category.id,
        isSubcategory: category.isSubcategory,
      ),
    );
  }
}
