import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:business/topic/models/topic_state.dart';

import 'package:ngnga/utils/category_icons.dart';
import 'distance_to_now.dart';
import 'title_colorize.dart';

final _numberFormatter = NumberFormat('#,###,###,###');

class TopicRow extends StatelessWidget {
  final TopicState topic;

  const TopicRow(this.topic) : assert(topic != null);

  @override
  Widget build(BuildContext context) {
    if (topic.topic.error != null) {
      return ListTile(
        title: Text(
          topic.topic.error,
          style: Theme.of(context)
              .textTheme
              .subhead
              .copyWith(color: Theme.of(context).errorColor),
        ),
      );
    }

    if (topic.topic.category != null) {
      return ListTile(
        leading: CircleAvatar(
          maxRadius: 16,
          backgroundColor: Theme.of(context).cardColor,
          backgroundImage: CachedNetworkImageProvider(
            categoryIconUrl(
              topic.topic.category.id,
              isSubcategory: topic.topic.category.isSubcategory,
            ),
          ),
        ),
        title: Text(topic.topic.category.title),
        trailing: const Icon(Icons.keyboard_arrow_right),
        onTap: () => Navigator.pushNamed(context, '/c', arguments: {
          'id': topic.topic.category.id,
          'isSubcategory': topic.topic.category.isSubcategory,
          'page': 0,
        }),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        InkWell(
          onTap: () => Navigator.pushNamed(context, '/t', arguments: {
            'id': topic.topic.id,
            'page': 0,
          }),
          child: Padding(
            padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 4.0),
            child: TitleColorize(topic.topic),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Container(
              width: 64,
              padding: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 8.0),
              child: Text(
                _numberFormatter.format(topic.topic.postsCount),
                style: Theme.of(context).textTheme.caption,
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Text(
                          topic.topic.author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ),
                    ),
                    DistanceToNow(topic.topic.createdAt),
                  ],
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                child: Container(
                  padding: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: 4.0),
                          child: Text(
                            topic.topic.lastPoster,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ),
                      ),
                      DistanceToNow(topic.topic.lastPostedAt),
                    ],
                  ),
                ),
                onTap: () => Navigator.pushNamed(context, '/t', arguments: {
                  'id': topic.topic.id,
                  'page': topic.topic.postsCount ~/ 20,
                }),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
