import 'dart:convert';

import '../../models/notification.dart';

class FetchNotificationResponse {
  final List<UserNotification> notifications;
  final int unreadCount;
  final DateTime lastChecked;

  FetchNotificationResponse({
    this.notifications,
    this.unreadCount,
    this.lastChecked,
  });

  factory FetchNotificationResponse.fromJson(Map<String, dynamic> raw) {
    String content = raw['data'][0].substring(8).replaceAllMapped(
        RegExp(r'([,\{])\s*(\d+):'), (m) => '${m[1]}"${m[2]}":');
    Map<String, dynamic> json = jsonDecode(content);

    List<UserNotification> notifications = [];

    for (var value in json['0']) {
      notifications.add(UserNotification.fromJson(value));
    }

    return FetchNotificationResponse(
      notifications: notifications,
      unreadCount: json['unread'],
      lastChecked: DateTime.fromMillisecondsSinceEpoch(
        json['lasttime'] * 1000,
      ),
    );
  }
}
