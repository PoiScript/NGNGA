import 'dart:convert';

import 'package:ngnga/store/state.dart';

import 'category.dart';
import 'notification.dart';
import 'post.dart';
import 'topic.dart';
import 'user.dart';

class PrepareEditingResponse {
  final String content;
  final String subject;
  final String uploadUrl;
  final String uploadAuthCode;
  final List<RemoteAttachment> attachs;

  PrepareEditingResponse._({
    this.content,
    this.subject,
    this.uploadUrl,
    this.attachs,
    this.uploadAuthCode,
  });

  PrepareEditingResponse.fromJson(Map<String, dynamic> json)
      : content = json['result'][0]['content'],
        subject = json['result'][0]['subject'],
        uploadUrl = json['result'][0]['attach_url'],
        attachs = List.of(json['result'][0]['attachs'] ?? [])
            .map((val) => RemoteAttachment(val['attachurl']))
            .toList(),
        uploadAuthCode = json['result'][0]['auth'];
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
  final List<Topic> topics;
  final List<Category> categories;
  final int topicCount;
  final int maxPage;

  FetchCategoryTopicsResponse({
    this.topics,
    this.categories,
    this.topicCount,
    this.maxPage,
  }) : assert(topics != null && topicCount != null);

  factory FetchCategoryTopicsResponse.fromJson(Map<String, dynamic> json) {
    List<Topic> topics = [];
    List<Category> categories = [];

    if (json['data']['__T'] is List) {
      for (var value in List.from(json['data']['__T'])) {
        Topic topic = Topic.fromJson(value);
        if (topic.category != null) categories.add(topic.category);
        topics.add(topic);
      }
    } else {
      for (var value in Map.from(json['data']['__T']).values) {
        Topic topic = Topic.fromJson(value);
        if (topic.category != null) categories.add(topic.category);
        topics.add(topic);
      }
    }

    return FetchCategoryTopicsResponse(
      topics: topics,
      categories: categories,
      topicCount: json['data']['__ROWS'],
      maxPage: json['data']['__ROWS'] ~/ json['data']['__T__ROWS_PAGE'],
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
      for (final value in json['data'][0][0]) {
        if (value['__P'] == null) favorites.add(Topic.fromJson(value));
      }
    } else if (json['data'][0][0] is Map) {
      for (final value in json['data'][0][0].values) {
        if (value['__P'] == null) favorites.add(Topic.fromJson(value));
      }
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

class FetchTopicPostsResponse {
  final Topic topic;
  final List<PostItem> posts;
  final List<Post> comments;
  final Map<int, User> users;

  final int maxPage;

  FetchTopicPostsResponse({
    this.topic,
    this.posts,
    this.users,
    this.comments,
    this.maxPage,
  });

  factory FetchTopicPostsResponse.fromJson(Map<String, dynamic> json) {
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
      posts.add(PostItem.fromJson(value));

      if (value['comment'] is List) {
        for (var value in List.of(value['comment'])) {
          comments.add(Post.fromJson(value));
        }
      }
    }

    return FetchTopicPostsResponse(
      topic: Topic.fromJson(json['data']['__T']),
      posts: posts,
      comments: comments,
      users: users,
      maxPage: (json['data']['__ROWS'] - 1) ~/ json['data']['__R__ROWS_PAGE'],
    );
  }
}
