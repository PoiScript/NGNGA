import 'package:flutter/material.dart';

import '../../models/category.dart';
import './category_row.dart';

class HomePage extends StatelessWidget {
  final List<Category> categories = [
    Category(
      id: 16907081,
      title: "Hololive 讨论合集",
      lastPostedAt: 0,
      postsCount: 0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(20.0, 100.0, 20.0, 20.0),
            child: Text(
              "NGNGA",
              style: Theme.of(context).textTheme.headline.copyWith(
                    fontWeight: FontWeight.bold,
                    // fontSize: 50.0,
                  ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) =>
                  _itemBuilder(context, categories[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemBuilder(BuildContext context, Category category) {
    return GestureDetector(
      onTap: () => _onTap(context, category.id),
      child: CategoryRow(category),
    );
  }

  _onTap(BuildContext context, int categoryId) {
    Navigator.pushNamed(context, "/c", arguments: {"id": categoryId});
  }
}
