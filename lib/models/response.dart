import 'dart:convert';

import 'attachment.dart';
import 'notification.dart';
import 'post.dart';
import 'topic.dart';
import 'user.dart';

class PrepareEditingResponse {
  final String content;
  final String subject;
  final String uploadUrl;
  final String uploadAuthCode;
  final List<Attachment> attachs;

  PrepareEditingResponse({
    this.content,
    this.subject,
    this.uploadUrl,
    this.attachs,
    this.uploadAuthCode,
  });

  factory PrepareEditingResponse.fromJson(Map<String, dynamic> json) {
    return PrepareEditingResponse(
      content: json['result'][0]['content'],
      subject: json['result'][0]['subject'],
      uploadUrl: json['result'][0]['attach_url'],
      attachs: List.of(json['result'][0]['attachs'] ?? [])
          .map((val) => Attachment.fromJson(val))
          .toList(growable: false),
      uploadAuthCode: json['result'][0]['auth'],
    );
  }
}

class ApplyEditingResponse {
  final int code;
  final String message;

  ApplyEditingResponse({
    this.code,
    this.message,
  });

  ApplyEditingResponse.fromJson(Map<String, dynamic> json)
      : code = json['code'],
        message = json['msg'];
}

class FavoritesResponse {
  final String message;

  FavoritesResponse({
    this.message,
  });

  FavoritesResponse.fromJson(Map<String, dynamic> json)
      : message = json['data'][0];
}

class FetchCategoryTopicsResponse {
  final int toppedTopicId;
  final List<Topic> topics;
  final int topicCount;
  final int maxPage;

  FetchCategoryTopicsResponse({
    this.topics,
    this.topicCount,
    this.maxPage,
    this.toppedTopicId,
  }) : assert(topics != null && topicCount != null);

  factory FetchCategoryTopicsResponse.fromJson(Map<String, dynamic> json) {
    List<Topic> topics = [];

    if (json['data']['__T'] is List) {
      for (var value in List.from(json['data']['__T'])) {
        Topic topic = Topic.fromJson(value);
        topics.add(topic);
      }
    } else {
      for (var value in Map.from(json['data']['__T']).values) {
        Topic topic = Topic.fromJson(value);
        topics.add(topic);
      }
    }

    return FetchCategoryTopicsResponse(
      topics: topics,
      topicCount: json['data']['__ROWS'],
      maxPage: json['data']['__ROWS'] ~/ json['data']['__T__ROWS_PAGE'],
      toppedTopicId: json['data']['__F']['topped_topic'],
    );
  }
}

class FetchFavorTopicsResponse {
  final List<Topic> topics;
  final int topicsCount;
  final int maxPage;

  FetchFavorTopicsResponse({
    this.topics,
    this.topicsCount,
    this.maxPage,
  }) : assert(topics != null && topicsCount != null);

  factory FetchFavorTopicsResponse.fromJson(Map<String, dynamic> json) {
    List<Topic> favorites = [];

    if (json['data'][0][0] is List) {
      favorites = List.of(json['data'][0][0])
          .where((value) => value['__P'] == null)
          .map((value) => Topic.fromJson(value))
          .toList(growable: false);
    } else if (json['data'][0][0] is Map) {
      favorites = Map.of(json['data'][0][0])
          .values
          .where((value) => value['__P'] == null)
          .map((value) => Topic.fromJson(value))
          .toList(growable: false);
    }

    return FetchFavorTopicsResponse(
      topics: favorites,
      topicsCount: json['data'][0][1],
      maxPage: json['data'][0][1] ~/ json['data'][0][3],
    );
  }
}

class NotificationResponse {
  final List<UserNotification> notifications;
  final int unreadCount;
  final DateTime lastChecked;

  NotificationResponse({
    this.notifications,
    this.unreadCount,
    this.lastChecked,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> raw) {
    String content = raw['data'][0].substring(8).replaceAllMapped(
        RegExp(r'([,\{])\s*(\d+):'), (m) => '${m[1]}"${m[2]}":');
    Map<String, dynamic> json = jsonDecode(content);

    List<UserNotification> notifications = [];

    for (var value in json['0']) {
      notifications.add(UserNotification.fromJson(value));
    }

    return NotificationResponse(
      notifications: notifications,
      unreadCount: json['unread'],
      lastChecked: DateTime.fromMillisecondsSinceEpoch(
        json['lasttime'] * 1000,
      ),
    );
  }
}

class UploadFileResponse {
  final String attachUrl;
  final String attachCode;
  final String attachChecksum;
  final int thumb;

  UploadFileResponse({
    this.attachUrl,
    this.attachCode,
    this.attachChecksum,
    this.thumb,
  });

  factory UploadFileResponse.fromJson(Map<String, dynamic> json) {
    return UploadFileResponse(
      attachUrl: json['url'],
      attachCode: json['attachments'],
      attachChecksum: json['attachments_check'],
      thumb: json['thumb'],
    );
  }
}

class VoteResponse {
  final String message;
  final int value;

  VoteResponse({
    this.message,
    this.value,
  });

  factory VoteResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] is List) {
      return VoteResponse(
        message: json['data'][0],
        value: json['data'][1],
      );
    } else {
      return VoteResponse(
        message: json['error'][0],
        value: 0,
      );
    }
  }
}

class FetchPostsResponse {
  final Topic topic;
  final List<PostItem> posts;
  final List<Post> comments;
  final Map<int, User> users;
  final String forumName;

  final int maxPage;

  final String errorMessage;

  FetchPostsResponse({
    this.topic,
    this.posts,
    this.users,
    this.comments,
    this.maxPage,
    this.forumName,
    this.errorMessage,
  });

  factory FetchPostsResponse.fromJson(Map<String, dynamic> json) {
    if (json['error'] != null) {
      return FetchPostsResponse(
        errorMessage: json['error']['__MESSAGE']['1'],
      );
    }

    Map<int, User> users = {};
    List<PostItem> posts = [];
    List<Post> comments = [];

    for (var entry in Map.from(json['data']['__U']).entries) {
      if (entry.key == '__MEDALS' ||
          entry.key == '__REPUTATIONS' ||
          entry.key == '__GROUPS') continue;

      users[int.parse(entry.key)] = User.fromJson(entry.value);
    }

    for (var value in List.from(json['data']['__R'])) {
      if (value['comment_to_id'] != null) {
        posts.add(Comment.fromJson(value));
      } else {
        posts.add(Post.fromJson(value));
      }

      if (value['comment'] is List) {
        for (var value in List.of(value['comment'])) {
          comments.add(Post.fromJson(value));
        }
      }
    }

    return FetchPostsResponse(
      topic: Topic.fromJson(json['data']['__T']),
      posts: posts,
      comments: comments,
      users: users,
      maxPage: (json['data']['__ROWS'] - 1) ~/ json['data']['__R__ROWS_PAGE'],
      forumName: json['data']['__F']['name'],
    );
  }
}
