import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:html_unescape/html_unescape.dart';

final HtmlUnescape unescape = HtmlUnescape();

enum NotificationType {
  postOnYourTopic,
  replyOnYourPost,
  commentOnYourTopic,
  commentOnYourPost,
  metionOnTopic,
  metionOnReply,
}

class UserNotification {
  final NotificationType type;
  final int userId;
  final String username;
  final int topicId;
  final String topicTitle;
  final int postId;
  final DateTime dateTime;
  final int pageIndex;

  UserNotification._({
    this.type,
    this.userId,
    this.username,
    this.topicId,
    this.topicTitle,
    this.postId,
    this.dateTime,
    this.pageIndex,
  });

  factory UserNotification.fromJson(Map<String, dynamic> json) {
    NotificationType type;

    switch (json['0']) {
      case 1:
        type = NotificationType.postOnYourTopic;
        break;
      case 2:
        type = NotificationType.replyOnYourPost;
        break;
      case 3:
        type = NotificationType.commentOnYourTopic;
        break;
      case 4:
        type = NotificationType.commentOnYourPost;
        break;
      case 7:
        type = NotificationType.metionOnTopic;
        break;
      case 8:
        type = NotificationType.metionOnReply;
        break;
      default:
        throw 'Unknown notification type';
    }

    return UserNotification._(
      type: type,
      userId: json['1'],
      username: json['2'],
      topicId: json['6'],
      topicTitle: unescape.convert(json['5']),
      postId: json['7'],
      dateTime: DateTime.fromMillisecondsSinceEpoch(
        json['9'] * 1000,
      ),
      pageIndex: json['10'],
    );
  }
}

class NotificationResponse {
  final List<UserNotification> notifications;
  final int unreadCount;
  final DateTime lastChecked;

  NotificationResponse._({
    this.notifications,
    this.unreadCount,
    this.lastChecked,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> raw) {
    String content = raw['data'][0].substring(8).replaceAllMapped(
          RegExp(r'([,\{])\s*(\d+):'),
          (match) => '${match[1]}"${match[2]}":',
        );
    Map<String, dynamic> json = jsonDecode(content);

    List<UserNotification> notifications = [];

    for (var value in json['0']) {
      notifications.add(UserNotification.fromJson(value));
    }

    return NotificationResponse._(
      notifications: notifications,
      unreadCount: json['unread'],
      lastChecked: DateTime.fromMillisecondsSinceEpoch(
        json['lasttime'] * 1000,
      ),
    );
  }
}

Future<NotificationResponse> fetchNotifications({
  @required Client client,
  @required String baseUrl,
}) async {
  final uri = Uri.https(baseUrl, 'nuke.php', {
    '__lib': 'noti',
    '__act': 'get_all',
    '__output': '11',
  });

  print(uri);

  final res = await client.post(uri);

  final json = jsonDecode(res.body);

  return NotificationResponse.fromJson(json);
}
