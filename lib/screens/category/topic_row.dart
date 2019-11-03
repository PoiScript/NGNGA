import 'package:flutter/material.dart';

import '../../models/topic.dart';
import '../../widgets/duration_to_now.dart';

class TopicRow extends StatelessWidget {
  final Topic topic;

  TopicRow(this.topic);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(12.0, 6.0, 12.0, 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            topic.title,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: Theme.of(context).textTheme.body1,
          ),
          Row(children: <Widget>[
            Text(
              "${topic.createdAt.toString()} · ${topic.postsCount} posts",
              style: Theme.of(context).textTheme.caption,
            ),
            const Spacer(),
            DurationToNow(
              topic.lastPostedAt,
              style: Theme.of(context).textTheme.caption,
            ),
          ])
        ],
      ),
    );
  }
}
