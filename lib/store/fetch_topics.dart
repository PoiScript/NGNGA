import 'dart:async';
import 'dart:convert';

import 'package:async_redux/async_redux.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';

import '../models/topic.dart';
import './state.dart';
import './is_loading.dart';

class _FetchTopicsResponse {
  final Iterable<Topic> topics;
  final int topicCount;

  _FetchTopicsResponse({
    @required this.topics,
    @required this.topicCount,
  }) : assert(topics != null && topicCount != null);

  factory _FetchTopicsResponse.fromJson(Map<String, dynamic> json) {
    var topics = json["data"]["__T"];
    return _FetchTopicsResponse(
      topics: (topics is List ? List.from(topics) : Map.from(topics).values)
          .map((value) => Topic.fromJson(value)),
      topicCount: json["data"]["__ROWS"],
    );
  }
}

Future<_FetchTopicsResponse> _fetchTopics(
  int categoryId,
  int pageIndex,
  Map<String, String> cookies,
) async {
  final uri = Uri.https("nga.178.com", "thread.php", {
    "stid": categoryId.toString(),
    "page": pageIndex.toString(),
    "__output": "11",
  });

  print(uri);

  final res = await get(uri, headers: {
    "cookie":
        cookies.entries.map((entry) => "${entry.key}=${entry.value}").join(";")
  });

  final json = jsonDecode(res.body);

  return _FetchTopicsResponse.fromJson(json);
}

class FetchTopicsAction extends ReduxAction<AppState> {
  final int categoryId;

  FetchTopicsAction({
    @required this.categoryId,
  }) : assert(categoryId != null);

  @override
  Future<AppState> reduce() async {
    final response = await _fetchTopics(categoryId, 1, state.cookies);

    return state.copy(
      categories: state.categories
        ..update(
          categoryId,
          (categoryState) => categoryState.copy(
            topics: List.of(response.topics),
            topicsCount: response.topicCount,
          ),
        ),
    );
  }

  void before() => dispatch(IsLoadingAction(true));

  void after() => dispatch(IsLoadingAction(false));
}

class FetchNextTopicsAction extends ReduxAction<AppState> {
  final int categoryId;

  FetchNextTopicsAction({
    @required this.categoryId,
  }) : assert(categoryId != null);

  @override
  Future<AppState> reduce() async {
    // page index starts at 1, not 0
    final lastPage = state.categories[categoryId].topics.length ~/ 20 + 1;
    final maxPage = state.categories[categoryId].topicsCount ~/ 20 + 1;
    final response = await _fetchTopics(
      categoryId,
      lastPage < maxPage ? lastPage : maxPage,
      state.cookies,
    );

    return state.copy(
      categories: state.categories
        ..update(
          categoryId,
          (categoryState) => categoryState.copy(
            topics: categoryState.topics..addAll(response.topics),
            topicsCount: response.topicCount,
          ),
        ),
    );
  }

  void before() => dispatch(IsLoadingAction(true));

  void after() => dispatch(IsLoadingAction(false));
}
