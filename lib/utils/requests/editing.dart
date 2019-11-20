import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart';

import 'package:ngnga/screens/editor/editor.dart';
import 'package:ngnga/utils/gbk_encode.dart';

class PrepareEditingResponse {
  final String content;
  final String subject;
  final String attachUrl;

  PrepareEditingResponse._({
    this.content,
    this.subject,
    this.attachUrl,
  });

  factory PrepareEditingResponse.fromJson(Map<String, dynamic> json) {
    return PrepareEditingResponse._(
      content: json['result'][0]['content'],
      subject: json['result'][0]['subject'],
      attachUrl: json['result'][0]['attach_url'],
    );
  }
}

class ApplyEditingResponse {
  final int code;
  final String message;

  ApplyEditingResponse._({
    this.code,
    this.message,
  });

  factory ApplyEditingResponse.fromJson(Map<String, dynamic> json) {
    return ApplyEditingResponse._(
      code: json['code'],
      message: json['msg'],
    );
  }
}

Future<PrepareEditingResponse> prepareEditing({
  @required Client client,
  @required int action,
  @required int categoryId,
  @required int topicId,
  @required int postId,
  @required List<String> cookies,
}) async {
  final query = _getQuery(
    action: action,
    categoryId: categoryId,
    topicId: topicId,
    postId: postId,
  );

  final uri = "https://nga.178.com/post.php?${query.toString()}";

  print(uri);

  final res = await client.get(uri, headers: {"cookie": cookies.join(";")});

  final json = jsonDecode(res.body);

  return PrepareEditingResponse.fromJson(json);
}

Future<ApplyEditingResponse> applyEditing({
  @required Client client,
  @required int action,
  @required int categoryId,
  @required int topicId,
  @required int postId,
  @required List<String> cookies,
  @required String subject,
  @required String content,
}) async {
  final query = _getQuery(
    action: action,
    categoryId: categoryId,
    topicId: topicId,
    postId: postId,
  );

  query.write("&step=2");

  query.write(
    "&post_content=${encodeUrlGbk(content).toString()}",
  );

  if (subject.trim().isNotEmpty) {
    query.write(
      "&post_subject=${encodeUrlGbk(subject.trim()).toString()}",
    );
  }

  // we're manually encode url here, so we have to concatenate it by hand
  final uri = "https://nga.178.com/post.php?${query.toString()}";

  print(uri);

  final res = await client.post(uri, headers: {"cookie": cookies.join(";")});

  final json = jsonDecode(res.body);

  return ApplyEditingResponse.fromJson(json);
}

StringBuffer _getQuery({
  int action,
  int categoryId,
  int topicId,
  int postId,
}) {
  final sb = StringBuffer("__output=14");

  switch (action) {
    case ACTION_NEW_TOPIC:
      sb.write("&action=new");
      break;
    case ACTION_QUOTE:
      sb.write("&action=quote");
      break;
    case ACTION_REPLY:
      sb.write("&action=reply");
      break;
    case ACTION_MODIFY:
      sb.write("&action=modify");
      break;
    case ACTION_COMMENT:
      sb..write("&action=reply")..write("&comment=1");
      break;
  }

  if (categoryId != null) {
    sb.write("&fid=$categoryId");
  }

  if (topicId != null) {
    sb.write("&tid=$topicId");
  }

  if (postId != null) {
    sb.write("&pid=$postId");
  }

  return sb;
}
