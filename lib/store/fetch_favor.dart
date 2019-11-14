import 'dart:async';
import 'dart:convert';

import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'package:ngnga/models/topic.dart';

import 'is_loading.dart';
import 'state.dart';

class _FetchTopicsResponse {
  final List<Topic> topics;
  final int topicCount;

  _FetchTopicsResponse({
    @required this.topics,
    @required this.topicCount,
  }) : assert(topics != null && topicCount != null);

  factory _FetchTopicsResponse.fromJson(Map<String, dynamic> json) {
    return _FetchTopicsResponse(
      topics: List.from(json["data"]["__T"])
          .map((value) => Topic.fromJson(value))
          .toList(),
      topicCount: json["data"]["__ROWS"],
    );
  }
}

Future<_FetchTopicsResponse> _fetchFavorTopics(List<String> cookies) async {
  final uri = Uri.https("nga.178.com", "thread.php", {
    "favor": "1",
    "__output": "11",
  });

  print(uri);

  final res = await get(uri, headers: {"cookie": cookies.join(";")});

  final json = jsonDecode(res.body);

  return _FetchTopicsResponse.fromJson(json);
}

class FetchFavorTopicsAction extends ReduxAction<AppState> {
  FetchFavorTopicsAction();

  @override
  Future<AppState> reduce() async {
    var response = await _fetchFavorTopics(state.cookies);

    return state.copy(
      favorTopics: response.topics,
    );
  }

  void before() => dispatch(IsLoadingAction(true));

  void after() => dispatch(IsLoadingAction(false));
}
