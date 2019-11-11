import 'package:flutter/material.dart';

import '../../models/topic.dart';
import '../../utils/duration_to_now.dart';

class TopicRow extends StatelessWidget {
  final Topic topic;

  TopicRow(this.topic);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(right: 40),
          child: GestureDetector(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  topic.title,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: Theme.of(context).textTheme.body1,
                ),
                Text(
                  "${topic.createdAt.toString()} · ${topic.postsCount} posts",
                  style: Theme.of(context).textTheme.caption,
                ),
              ],
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                "/t",
                arguments: {"id": topic.id, "page": 0},
              );
            },
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          width: 40,
          child: GestureDetector(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  topic.postsCount.toString(),
                  style: Theme.of(context).textTheme.caption,
                ),
                Text(
                  durationToNow(topic.lastPostedAt),
                  style: Theme.of(context).textTheme.caption,
                ),
              ],
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                "/t",
                arguments: {"id": topic.id, "page": topic.postsCount ~/ 20},
              );
            },
          ),
        ),
      ],
    );
  }
}
