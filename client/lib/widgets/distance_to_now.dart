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
      return {
        DateTime.january: () => 'Jan \'${right.day}',
        DateTime.february: () => 'Feb \'${right.day}',
        DateTime.march: () => 'Mar \'${right.day}',
        DateTime.april: () => 'Apr \'${right.day}',
        DateTime.may: () => 'May \'${right.day}',
        DateTime.june: () => 'Jun \'${right.day}',
        DateTime.july: () => 'Jul \'${right.day}',
        DateTime.august: () => 'Aug \'${right.day}',
        DateTime.september: () => 'Sep \'${right.day}',
        DateTime.october: () => 'Oct \'${right.day}',
        DateTime.november: () => 'Nov \'${right.day}',
        DateTime.december: () => 'Dec \'${right.day}',
      }[right.month]();
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
