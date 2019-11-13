import 'package:flutter/material.dart';

import '../../models/topic.dart';
import '../../utils/duration_to_now.dart';

class TopicRow extends StatelessWidget {
  final Topic topic;
  final void Function(Topic) ensureTopicExists;

  TopicRow(this.topic, this.ensureTopicExists)
      : assert(topic != null),
        assert(ensureTopicExists != null);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 8.0, right: 48.0),
          child: InkWell(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  topic.title,
                  style: Theme.of(context).textTheme.body1,
                ),
                Text(
                  "${topic.createdAt.toString()}",
                  style: Theme.of(context).textTheme.caption,
                ),
              ],
            ),
            onTap: () {
              ensureTopicExists(topic);
              Navigator.pushNamed(context, "/t", arguments: {
                "id": topic.id,
                "page": 0,
              });
            },
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          width: 48,
          child: InkWell(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Expanded(
                  child: Center(
                    child: Text(
                      topic.postsCount.toString(),
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    durationToNow(topic.lastPostedAt),
                    style: Theme.of(context).textTheme.caption,
                  ),
                ),
              ],
            ),
            onTap: () {
              ensureTopicExists(topic);
              Navigator.pushNamed(context, "/t", arguments: {
                "id": topic.id,
                "page": topic.postsCount ~/ 20,
              });
            },
          ),
        ),
      ],
    );
  }
}
