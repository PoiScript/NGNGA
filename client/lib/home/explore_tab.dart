import 'package:built_collection/built_collection.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

import 'package:business/models/category.dart';
import 'package:ngnga/localizations.dart';
import 'package:ngnga/utils/categories.dart';
import 'package:ngnga/utils/category_icons.dart';

class ExploreTab extends StatelessWidget {
  final BuiltList<Category> pinned;

  const ExploreTab({
    @required this.pinned,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: BouncingScrollPhysics(),
      slivers: <Widget>[
        SliverToBoxAdapter(),
        SliverStickyHeader(
          header: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            color: Theme.of(context).cardColor,
            child: Text(
              AppLocalizations.of(context).pinned,
              style: Theme.of(context).textTheme.caption,
            ),
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => ListTile(
                leading: CircleAvatar(
                  maxRadius: 16,
                  backgroundColor: Colors.transparent,
                  backgroundImage: CachedNetworkImageProvider(
                    categoryIconUrl(
                      pinned[index].id,
                      isSubcategory: pinned[index].isSubcategory,
                    ),
                  ),
                ),
                title: Text(pinned[index].title),
                trailing: const Icon(Icons.keyboard_arrow_right),
                onTap: () => Navigator.pushNamed(context, '/c', arguments: {
                  'id': pinned[index].id,
                  'isSubcategory': pinned[index].isSubcategory,
                  'page': 0,
                }),
              ),
              childCount: pinned.length,
            ),
          ),
        ),
        for (CategoryGroup group in categoryGroups)
          SliverStickyHeader(
            header: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              color: Theme.of(context).cardColor,
              child: Text(
                group.name,
                style: Theme.of(context).textTheme.caption,
              ),
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => ListTile(
                  leading: CircleAvatar(
                    maxRadius: 16,
                    backgroundColor: Colors.transparent,
                    backgroundImage: CachedNetworkImageProvider(
                      categoryIconUrl(
                        group.categories[index].id,
                        isSubcategory: group.categories[index].isSubcategory,
                      ),
                    ),
                  ),
                  title: Text(group.categories[index].title),
                  trailing: const Icon(Icons.keyboard_arrow_right),
                  onTap: () => Navigator.pushNamed(context, '/c', arguments: {
                    'id': group.categories[index].id,
                    'isSubcategory': group.categories[index].isSubcategory,
                    'page': 0,
                  }),
                ),
                childCount: group.categories.length,
              ),
            ),
          ),
      ],
    );
  }
}
