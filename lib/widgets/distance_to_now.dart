import 'dart:async';

import 'package:flutter/material.dart';

final _everyMinutes = StreamController<DateTime>.broadcast()
  ..addStream(
    Stream.periodic(Duration(minutes: 1), (_) => DateTime.now()),
  );

class DistanceToNow extends StatelessWidget {
  final DateTime dateTime;

  const DistanceToNow(
    this.dateTime, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime>(
      initialData: DateTime.now(),
      stream: _everyMinutes.stream,
      builder: (context, snapshot) => Text(
        _distance(snapshot.data, dateTime),
        style: Theme.of(context).textTheme.caption,
      ),
    );
  }

  String _distance(DateTime left, DateTime right) {
    Duration difference = left.difference(right);
    if (difference.inDays > 10) {
      switch (right.month) {
        case DateTime.january:
          return 'Jan \'${right.day}';
        case DateTime.february:
          return 'Feb \'${right.day}';
        case DateTime.march:
          return 'Mar \'${right.day}';
        case DateTime.april:
          return 'Apr \'${right.day}';
        case DateTime.may:
          return 'May \'${right.day}';
        case DateTime.june:
          return 'Jun \'${right.day}';
        case DateTime.july:
          return 'Jul \'${right.day}';
        case DateTime.august:
          return 'Aug \'${right.day}';
        case DateTime.september:
          return 'Sep \'${right.day}';
        case DateTime.october:
          return 'Oct \'${right.day}';
        case DateTime.november:
          return 'Nov \'${right.day}';
        case DateTime.december:
          return 'Dec \'${right.day}';
      }
      return '${right.day}';
    } else if (difference.inDays > 0) {
      if (difference.inDays < 2) {
        return '${difference.inDays}d${difference.inHours % 24}h';
      } else {
        return '${difference.inDays}d';
      }
    } else if (difference.inHours > 0) {
      if (difference.inHours < 2) {
        return '${difference.inHours}h${difference.inMinutes % 60}m';
      } else {
        return '${difference.inHours}h';
      }
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}
