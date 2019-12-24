import 'dart:async';

import 'package:flutter/material.dart';

final _everySeconds = StreamController<DateTime>.broadcast()
  ..addStream(
    Stream.periodic(Duration(seconds: 1), (_) => DateTime.now()),
  );

final _everyMinutes = StreamController<DateTime>.broadcast()
  ..addStream(
    Stream.periodic(Duration(minutes: 1), (_) => DateTime.now()),
  );

final _everyHours = StreamController<DateTime>.broadcast()
  ..addStream(
    Stream.periodic(Duration(hours: 1), (_) => DateTime.now()),
  );

class DistanceToNow extends StatefulWidget {
  final DateTime dateTime;

  const DistanceToNow(
    this.dateTime, {
    Key key,
  }) : super(key: key);

  @override
  _DistanceToNowState createState() => _DistanceToNowState();
}

class _DistanceToNowState extends State<DistanceToNow> {
  StreamSubscription<DateTime> _subscription;
  String text;
  Interval interval;

  @override
  void initState() {
    DateTime now = DateTime.now();
    Duration duration = now.difference(widget.dateTime);
    setState(() {
      text = duration.inDays > 10 ? _date(now) : _distance(duration);
    });
    if (duration.inHours >= 1) {
      _subscribeToHours();
    } else if (duration.inMinutes >= 1) {
      _subscribeToMinutes();
    } else {
      _subscribeToSeconds();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.caption);
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  void _subscribeToHours() {
    assert(_subscription == null);
    _subscription = _everyHours.stream.listen((now) {
      Duration duration = now.difference(widget.dateTime);
      setState(() {
        text = duration.inDays > 10 ? _date(now) : _distance(duration);
      });
    });
  }

  void _subscribeToMinutes() {
    assert(_subscription == null);
    _subscription = _everyMinutes.stream.listen((now) {
      Duration duration = now.difference(widget.dateTime);
      setState(() {
        text = _distance(duration);
      });
      if (duration.inHours > 0) {
        _unsubscribe();
        _subscribeToHours();
      }
    });
  }

  void _subscribeToSeconds() {
    assert(_subscription == null);
    _subscription = _everySeconds.stream.listen((now) {
      Duration duration = now.difference(widget.dateTime);
      setState(() {
        text = _distance(duration);
      });
      if (duration.inMinutes > 0) {
        _unsubscribe();
        _subscribeToMinutes();
      }
    });
  }

  void _unsubscribe() {
    if (_subscription != null) {
      _subscription.cancel();
      _subscription = null;
    }
  }

  String _distance(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  String _date(DateTime dateTime) {
    return {
      DateTime.january: () => 'Jan ${dateTime.day}',
      DateTime.february: () => 'Feb ${dateTime.day}',
      DateTime.march: () => 'Mar ${dateTime.day}',
      DateTime.april: () => 'Apr ${dateTime.day}',
      DateTime.may: () => 'May ${dateTime.day}',
      DateTime.june: () => 'Jun ${dateTime.day}',
      DateTime.july: () => 'Jul ${dateTime.day}',
      DateTime.august: () => 'Aug ${dateTime.day}',
      DateTime.september: () => 'Sep ${dateTime.day}',
      DateTime.october: () => 'Oct ${dateTime.day}',
      DateTime.november: () => 'Nov ${dateTime.day}',
      DateTime.december: () => 'Dec ${dateTime.day}',
    }[dateTime.month]();
  }
}
