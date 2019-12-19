import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ngnga/store/topic.dart';
import 'package:ngnga/utils/duration.dart';
import 'package:ngnga/widgets/title_colorize.dart';

final _numberFormatter = NumberFormat('#,###,###,###');

final _everyMinutes = StreamController<DateTime>.broadcast()
  ..addStream(
    Stream.periodic(Duration(minutes: 1), (_) => DateTime.now()),
  );

class TopicRow extends StatelessWidget {
  final TopicState topic;

  const TopicRow({
    @required this.topic,
  }) : assert(topic != null);

  @override
  Widget build(BuildContext context) {
    if (topic.topic.category != null) {
      return InkWell(
        onTap: () => Navigator.pushNamed(context, '/c', arguments: {
          'id': topic.topic.category.id,
          'isSubcategory': topic.topic.category.isSubcategory,
        }),
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TitleColorize(topic.topic),
              ),
              const Icon(Icons.keyboard_arrow_right)
            ],
          ),
        ),
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
                padding: EdgeInsets.only(top: 4, bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
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
                    StreamBuilder<DateTime>(
                      initialData: DateTime.now(),
                      stream: _everyMinutes.stream,
                      builder: (context, snapshot) => Text(
                        duration(snapshot.data, topic.topic.createdAt),
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ),
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
                      StreamBuilder<DateTime>(
                        initialData: DateTime.now(),
                        stream: _everyMinutes.stream,
                        builder: (context, snapshot) => Text(
                          duration(snapshot.data, topic.topic.lastPostedAt),
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ),
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
