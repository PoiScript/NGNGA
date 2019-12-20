import '../../models/post.dart';
import '../../models/topic.dart';
import '../../models/user.dart';

class FetchTopicPostsResponse {
  final Topic topic;
  final List<PostItem> posts;
  final List<Post> comments;
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
        posts.add(Comment.fromJson(value).build());
      } else {
        posts.add(Post.fromJson(value).build());
      }

      if (value['comment'] is List) {
        for (var value in List.of(value['comment'])) {
          comments.add(Post.fromJson(value).build());
        }
      }
    }

    return FetchTopicPostsResponse(
      topic: Topic.fromJson(json['data']['__T']),
      posts: posts,
      comments: comments,
      users: users,
      maxPage: (json['data']['__ROWS'] - 1) ~/ json['data']['__R__ROWS_PAGE'],
      forumName: json['data']['__F']['name'],
    );
  }
}
