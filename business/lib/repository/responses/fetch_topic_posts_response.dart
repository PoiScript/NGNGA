import '../../models/post.dart';
import '../../models/topic.dart';
import '../../models/user.dart';

class FetchTopicPostsResponse {
  final Topic topic;
  final List<RawPost> posts;
  final List<RawPost> comments;
  final Map<int, User> users;
  final String forumName;

  final int maxPage;

  final String errorMessage;

  FetchTopicPostsResponse({
    this.topic,
    this.posts,
    this.users,
    this.comments,
    this.maxPage,
    this.forumName,
    this.errorMessage,
  });

  factory FetchTopicPostsResponse.fromJson(Map<String, dynamic> json) {
    if (json['error'] != null) {
      return FetchTopicPostsResponse(
        errorMessage: json['error']['__MESSAGE']['1'],
      );
    }

    Map<int, User> users = {};
    List<RawPost> posts = [];
    List<RawPost> comments = [];

    for (var entry in Map.from(json['data']['__U']).entries) {
      if (entry.key == '__MEDALS' ||
          entry.key == '__REPUTATIONS' ||
          entry.key == '__GROUPS') continue;

      users[int.parse(entry.key)] = User.fromJson(entry.value);
    }

    for (var value in List.from(json['data']['__R'])) {
      posts.add(RawPost.fromJson(value));

      if (value['comment'] is List) {
        for (var value in List.of(value['comment'])) {
          comments.add(RawPost.fromJson(value));
        }
      }
    }

    return FetchTopicPostsResponse(
      topic: Topic.fromRaw(RawTopic.fromJson(json['data']['__T'])),
      posts: posts,
      comments: comments,
      users: users,
      maxPage: (json['data']['__ROWS'] - 1) ~/ json['data']['__R__ROWS_PAGE'],
      forumName: json['data']['__F']['name'],
    );
  }
}
