import 'package:flutter/material.dart';

class DurationToNow extends StatelessWidget {
  final DateTime datetime;
  final TextStyle style;

  DurationToNow(this.datetime, {this.style});

  @override
  Widget build(BuildContext context) {
    Duration difference = DateTime.now().difference(datetime);
    if (difference.inDays > 7) {
      switch (datetime.month) {
        case DateTime.january:
          return Text("Jan '${datetime.day}", style: style);
        case DateTime.february:
          return Text("Feb '${datetime.day}", style: style);
        case DateTime.march:
          return Text("Mar '${datetime.day}", style: style);
        case DateTime.april:
          return Text("Apr '${datetime.day}", style: style);
        case DateTime.may:
          return Text("May '${datetime.day}", style: style);
        case DateTime.june:
          return Text("Jun '${datetime.day}", style: style);
        case DateTime.july:
          return Text("Jul '${datetime.day}", style: style);
        case DateTime.august:
          return Text("Aug '${datetime.day}", style: style);
        case DateTime.september:
          return Text("Sep '${datetime.day}", style: style);
        case DateTime.october:
          return Text("Oct '${datetime.day}", style: style);
        case DateTime.november:
          return Text("Nov '${datetime.day}", style: style);
        case DateTime.december:
          return Text("Dec '${datetime.day}", style: style);
      }
      return Text("${datetime.day}", style: style);
    } else if (difference.inDays > 0) {
      return Text("${difference.inDays}d", style: style);
    } else if (difference.inHours > 0) {
      return Text("${difference.inHours}h", style: style);
    } else if (difference.inMinutes > 0) {
      return Text("${difference.inMinutes}m", style: style);
    } else {
      return Text("now", style: style);
    }
  }
}
