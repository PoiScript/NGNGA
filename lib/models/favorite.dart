import 'package:ngnga/models/topic.dart';

class Favorite {
  final Topic topic;
  final String postContent;
  final int postId;

  Favorite._(
    this.topic,
    this.postContent,
    this.postId,
  ) : assert(topic != null);

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite._(
      Topic.fromJson(json),
      json['__P'] != null ? json['__P']['content'] : null,
      json['__P'] != null ? json['__P']['pid'] : null,
    );
  }
}
