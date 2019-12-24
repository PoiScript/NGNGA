import '../../models/topic.dart';

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
        topics.add(Topic.fromRaw(RawTopic.fromJson(value)));
      }
    } else {
      for (var value in Map.from(json['data']['__T']).values) {
        topics.add(Topic.fromRaw(RawTopic.fromJson(value)));
      }
    }

    return FetchCategoryTopicsResponse(
      topics: topics,
      topicCount: json['data']['__ROWS'],
      maxPage: (json['data']['__ROWS'] - 1) ~/ json['data']['__T__ROWS_PAGE'],
      toppedTopicId: json['data']['__F']['topped_topic'],
    );
  }
}
