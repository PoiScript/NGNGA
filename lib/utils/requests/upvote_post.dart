import 'dart:convert';

import 'package:http/http.dart';

Future<String> upvotePost(
  int topicId,
  int postId,
  List<String> cookies,
) async {
  final uri = Uri.https("nga.178.com", "nuke.php", {
    "__lib": "topic_recommend",
    "__act": "add",
    "tid": topicId.toString(),
    "pid": postId.toString(),
    "value": "1",
    "raw": "3",
    "__output": "11",
  });

  print(uri);

  final res = await post(uri, headers: {"cookie": cookies.join(";")});

  final json = jsonDecode(res.body);

  return json["data"][0];
}
