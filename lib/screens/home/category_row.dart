import 'package:flutter/material.dart';

import '../../models/category.dart';

class CategoryRow extends StatelessWidget {
  final Category category;

  CategoryRow(this.category);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          category.title,
          style: Theme.of(context).textTheme.title,
        ),
      ],
    );
  }
}
