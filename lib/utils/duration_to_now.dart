String duration(DateTime left, DateTime right) {
  Duration difference = left.difference(right);
  if (difference.inDays > 7) {
    switch (left.month) {
      case DateTime.january:
        return "Jan '${left.day}";
      case DateTime.february:
        return "Feb '${left.day}";
      case DateTime.march:
        return "Mar '${left.day}";
      case DateTime.april:
        return "Apr '${left.day}";
      case DateTime.may:
        return "May '${left.day}";
      case DateTime.june:
        return "Jun '${left.day}";
      case DateTime.july:
        return "Jul '${left.day}";
      case DateTime.august:
        return "Aug '${left.day}";
      case DateTime.september:
        return "Sep '${left.day}";
      case DateTime.october:
        return "Oct '${left.day}";
      case DateTime.november:
        return "Nov '${left.day}";
      case DateTime.december:
        return "Dec '${left.day}";
    }
    return "${left.day}";
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
