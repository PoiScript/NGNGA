import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart';

class VoteResponse {
  final String message;
  final int value;

  VoteResponse._({
    @required this.message,
    @required this.value,
  });

  factory VoteResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] is List) {
      return VoteResponse._(
        message: json['data'][0],
        value: json['data'][1],
      );
    } else {
      return VoteResponse._(
        message: json['error'][0],
        value: 0,
      );
    }
  }
}

Future<VoteResponse> votePost({
  @required Client client,
  @required String baseUrl,
  @required String cookie,
  @required int topicId,
  @required int postId,
  @required int value,
}) async {
  final uri = Uri.https(baseUrl, 'nuke.php', {
    '__lib': 'topic_recommend',
    '__act': 'add',
    'tid': topicId.toString(),
    'pid': postId.toString(),
    'value': value.toString(),
    'raw': '3',
    '__output': '11',
  });

  print(uri);

  final res = await client.post(uri, headers: {'cookie': cookie});

  final json = jsonDecode(res.body);

  return VoteResponse.fromJson(json);
}
