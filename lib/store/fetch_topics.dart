import 'dart:async';
import 'dart:convert';

import 'package:async_redux/async_redux.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';

import '../models/topic.dart';
import './state.dart';
import './is_loading.dart';

class FetchTopicsAction extends ReduxAction<AppState> {
  final int categoryId;
  final int pageIndex;

  FetchTopicsAction({
    @required this.categoryId,
    this.pageIndex = 0,
  }) : assert(categoryId != null && pageIndex != null);

  @override
  Future<AppState> reduce() async {
    final uri = Uri.https("nga.178.com", "thread.php", {
      "stid": categoryId.toString(),
      "page": pageIndex.toString(),
      "__output": "11",
    });

    print(uri);

    final res = await get(uri, headers: {
      "cookie": state.cookies.entries
          .map((entry) => "${entry.key}=${entry.value}")
          .join(";")
    });

    final json = jsonDecode(res.body);

    final topicsObject = json["data"]["__T"];

    if (topicsObject != null) {
      Iterable<Topic> topics = (topicsObject is List
              ? List.from(topicsObject)
              : Map.from(topicsObject).values)
          .map((value) => Topic.fromJson(value));

      var topicIds = topics.map((topic) => topic.id).toList();

      return state.copy(
        categories: Map.of(state.categories)
          ..update(
            categoryId,
            (state) => state.copy(
              topicIds: topicIds,
              topicsCount: json["data"]["__ROWS"],
            ),
            ifAbsent: () => CategoryState(
              topicIds: topicIds,
              topicsCount: json["data"]["__ROWS"],
            ),
          ),
        topics: Map.of(state.topics)
          ..addEntries(
            topics.map(
              (topic) => MapEntry(
                topic.id,
                TopicState(topic: topic, posts: Map()),
              ),
            ),
          ),
      );
    }

    return state;
  }

  void before() => dispatch(IsLoadingAction(true));

  void after() => dispatch(IsLoadingAction(false));
}
