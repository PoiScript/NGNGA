import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ngnga/models/category.dart';

import 'package:ngnga/models/topic.dart';
import 'package:ngnga/utils/duration.dart';
import 'package:ngnga/widgets/title_colorize.dart';

final numberFormatter = NumberFormat("#,###");
final dateFormatter = DateFormat("yyyy-MM-dd HH:mm");

class TopicRow extends StatelessWidget {
  final Topic topic;
  final Stream<DateTime> everyMinutes;

  final void Function(Topic, int) navigateToTopic;
  final void Function(Category) navigateToCategory;

  TopicRow({
    this.topic,
    this.everyMinutes,
    this.navigateToTopic,
    this.navigateToCategory,
  })  : assert(topic != null),
        assert(everyMinutes != null),
        assert(navigateToTopic != null),
        assert(navigateToCategory != null);

  @override
  Widget build(BuildContext context) {
    if (topic.category != null)
      return InkWell(
        onTap: () => navigateToCategory(topic.category),
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              TitleColorize(topic),
              const Spacer(),
              const Icon(Icons.keyboard_arrow_right)
            ],
          ),
        ),
      );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        InkWell(
          onTap: () => navigateToTopic(topic, 0),
          child: Padding(
            padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 4.0),
            child: TitleColorize(topic),
          ),
        ),
        Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 8.0),
              child: Text(
                "${topic.author.length > 6 ? topic.author.substring(0, 6) + '..' : topic.author} ${dateFormatter.format(topic.createdAt)} ${numberFormatter.format(topic.postsCount)}",
                style: Theme.of(context).textTheme.caption,
              ),
            ),
            const Spacer(),
            InkWell(
              child: Padding(
                padding: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 8.0),
                child: StreamBuilder<DateTime>(
                  initialData: DateTime.now(),
                  stream: everyMinutes,
                  builder: (context, snapshot) => Text(
                    "${topic.lastPoster.length > 6 ? topic.lastPoster.substring(0, 6) + '..' : topic.lastPoster} ${duration(snapshot.data, topic.lastPostedAt)}",
                    style: Theme.of(context).textTheme.caption,
                  ),
                ),
              ),
              onTap: () => navigateToTopic(topic, topic.postsCount ~/ 20),
            ),
          ],
        ),
      ],
    );
  }
}
