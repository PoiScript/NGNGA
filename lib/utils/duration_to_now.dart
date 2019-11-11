import 'package:flutter/material.dart';

String durationToNow(DateTime datetime) {
  Duration difference = DateTime.now().difference(datetime);
  if (difference.inDays > 7) {
    switch (datetime.month) {
      case DateTime.january:
        return "Jan '${datetime.day}";
      case DateTime.february:
        return "Feb '${datetime.day}";
      case DateTime.march:
        return "Mar '${datetime.day}";
      case DateTime.april:
        return "Apr '${datetime.day}";
      case DateTime.may:
        return "May '${datetime.day}";
      case DateTime.june:
        return "Jun '${datetime.day}";
      case DateTime.july:
        return "Jul '${datetime.day}";
      case DateTime.august:
        return "Aug '${datetime.day}";
      case DateTime.september:
        return "Sep '${datetime.day}";
      case DateTime.october:
        return "Oct '${datetime.day}";
      case DateTime.november:
        return "Nov '${datetime.day}";
      case DateTime.december:
        return "Dec '${datetime.day}";
    }
    return "${datetime.day}";
  } else if (difference.inDays > 0) {
    return "${difference.inDays}d";
  } else if (difference.inHours > 0) {
    return "${difference.inHours}h";
  } else if (difference.inMinutes > 0) {
    return "${difference.inMinutes}m";
  } else {
    return "now";
  }
}
