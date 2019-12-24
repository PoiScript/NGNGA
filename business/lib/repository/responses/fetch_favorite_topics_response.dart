import '../../models/topic.dart';

class FetchFavoriteTopicsResponse {
  final List<Topic> topics;
  final int topicsCount;
  final int maxPage;

  FetchFavoriteTopicsResponse({
    this.topics,
    this.topicsCount,
    this.maxPage,
  }) : assert(topics != null && topicsCount != null);

  factory FetchFavoriteTopicsResponse.fromJson(Map<String, dynamic> json) {
    List<Topic> favorites = [];

    if (json['data'][0][0] is List) {
      favorites = List.of(json['data'][0][0])
          .where((value) => value['__P'] == null)
          .map((raw) => Topic.fromRaw(RawTopic.fromJson(raw)))
          .toList(growable: false);
    } else if (json['data'][0][0] is Map) {
      favorites = Map.of(json['data'][0][0])
          .values
          .where((value) => value['__P'] == null)
          .map((raw) => Topic.fromRaw(RawTopic.fromJson(raw)))
          .toList(growable: false);
    }

    return FetchFavoriteTopicsResponse(
      topics: favorites,
      topicsCount: json['data'][0][1],
      maxPage: json['data'][0][1] ~/ json['data'][0][3],
    );
  }
}
