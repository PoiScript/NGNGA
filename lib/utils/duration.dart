String duration(DateTime left, DateTime right) {
  Duration difference = left.difference(right);
  if (difference.inDays > 10) {
    switch (right.month) {
      case DateTime.january:
        return "Jan '${right.day}";
      case DateTime.february:
        return "Feb '${right.day}";
      case DateTime.march:
        return "Mar '${right.day}";
      case DateTime.april:
        return "Apr '${right.day}";
      case DateTime.may:
        return "May '${right.day}";
      case DateTime.june:
        return "Jun '${right.day}";
      case DateTime.july:
        return "Jul '${right.day}";
      case DateTime.august:
        return "Aug '${right.day}";
      case DateTime.september:
        return "Sep '${right.day}";
      case DateTime.october:
        return "Oct '${right.day}";
      case DateTime.november:
        return "Nov '${right.day}";
      case DateTime.december:
        return "Dec '${right.day}";
    }
    return "${right.day}";
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
