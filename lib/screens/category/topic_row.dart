import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ngnga/models/topic.dart';
import 'package:ngnga/utils/duration.dart';
import 'package:ngnga/widgets/title_colorize.dart';

final numberFormatter = NumberFormat("#,###");
final dateFormatter = DateFormat("yyyy-MM-dd HH:mm");

class TopicRow extends StatelessWidget {
  final Topic topic;
  final Stream<DateTime> everyMinutes;

  final void Function(Topic, int) navigateToTopic;

  TopicRow(this.topic, this.navigateToTopic, this.everyMinutes)
      : assert(topic != null),
        assert(navigateToTopic != null),
        assert(everyMinutes != null);

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
                TitleColorize(topic.title),
                Text(
                  "${dateFormatter.format(topic.createdAt)}",
                  style: Theme.of(context).textTheme.caption,
                ),
              ],
            ),
            onTap: () => navigateToTopic(topic, 0),
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
                      numberFormatter.format(topic.postsCount),
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ),
                ),
                Center(
                  child: StreamBuilder<DateTime>(
                    initialData: DateTime.now(),
                    stream: everyMinutes,
                    builder: (context, snapshot) => Text(
                      duration(snapshot.data, topic.lastPostedAt),
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ),
                ),
              ],
            ),
            onTap: () => navigateToTopic(topic, topic.postsCount ~/ 20),
          ),
        ),
      ],
    );
  }
}
