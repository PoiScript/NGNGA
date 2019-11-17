import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

import 'package:ngnga/widgets/category_row.dart';

import 'categories.dart';

class ExplorePage extends StatelessWidget {
  ExplorePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        title: Text(
          "Explore",
          style: Theme.of(context).textTheme.body2,
        ),
        titleSpacing: 0.0,
        backgroundColor: Colors.white,
      ),
      body: Scrollbar(
        child: CustomScrollView(
          slivers: categoryGroups
              .map(
                (group) => SliverStickyHeader(
                  header: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    color: Colors.white,
                    child: Text(
                      group.name,
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          CategoryRowConnector(group.categories[index]),
                      childCount: group.categories.length,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
