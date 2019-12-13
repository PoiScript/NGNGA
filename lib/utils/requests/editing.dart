import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart';

import 'package:ngnga/screens/editor/editor.dart';
import 'package:ngnga/store/state.dart';
import 'package:ngnga/utils/gbk_encode.dart';

class PrepareEditingResponse {
  final String content;
  final String subject;
  final String uploadUrl;
  final String uploadAuthCode;
  final List<RemoteAttachment> attachs;

  PrepareEditingResponse._({
    this.content,
    this.subject,
    this.uploadUrl,
    this.attachs,
    this.uploadAuthCode,
  });

  factory PrepareEditingResponse.fromJson(Map<String, dynamic> json) {
    return PrepareEditingResponse._(
      content: json['result'][0]['content'],
      subject: json['result'][0]['subject'],
      uploadUrl: json['result'][0]['attach_url'],
      attachs: List.of(json['result'][0]['attachs'] ?? [])
          .map((val) => RemoteAttachment(val['attachurl']))
          .toList(),
      uploadAuthCode: json['result'][0]['auth'],
    );
  }
}

Future<PrepareEditingResponse> prepareEditing({
  @required Client client,
  @required String baseUrl,
  @required EditorAction action,
  @required int categoryId,
  @required int topicId,
  @required int postId,
}) async {
  final query = _getQuery(
    action: action,
    categoryId: categoryId,
    topicId: topicId,
    postId: postId,
  );

  final uri = 'https://$baseUrl/post.php?${query.toString()}';

  print(uri);

  final res = await client.get(uri);

  final json = jsonDecode(res.body);

  return PrepareEditingResponse.fromJson(json);
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

Future<ApplyEditingResponse> applyEditing({
  @required Client client,
  @required String baseUrl,
  @required EditorAction action,
  @required int categoryId,
  @required int topicId,
  @required int postId,
  @required String subject,
  @required String content,
  @required String attachmentCode,
  @required String attachmentChecksum,
}) async {
  final query = _getQuery(
    action: action,
    categoryId: categoryId,
    topicId: topicId,
    postId: postId,
  );

  query.write('&step=2');

  query.write('&post_content=${encodeUrlGbk(content).toString()}');

  if (subject.trim().isNotEmpty) {
    query.write('&post_subject=${encodeUrlGbk(subject.trim()).toString()}');
  }

  if (attachmentCode.isNotEmpty) {
    query.write('&attachments=$attachmentCode');
  }

  if (attachmentChecksum.isNotEmpty) {
    query.write('&attachments_check=$attachmentChecksum');
  }

  // we're manually encode url here, so we have to concatenate it by hand
  final uri = 'https://$baseUrl/post.php?${query.toString()}';

  print(uri);

  final res = await client.post(uri);

  final json = jsonDecode(res.body);

  return ApplyEditingResponse.fromJson(json);
}

StringBuffer _getQuery({
  EditorAction action,
  int categoryId,
  int topicId,
  int postId,
}) {
  final sb = StringBuffer('__output=14');

  switch (action) {
    case EditorAction.newTopic:
      sb.write('&action=new');
      break;
    case EditorAction.quote:
      sb.write('&action=quote');
      break;
    case EditorAction.reply:
      sb.write('&action=reply');
      break;
    case EditorAction.modify:
      sb.write('&action=modify');
      break;
    case EditorAction.comment:
      sb..write('&action=reply')..write('&comment=1');
      break;
    case EditorAction.newPost:
      sb.write('&action=reply');
      break;
    case EditorAction.noop:
      // TODO: Handle this case.
      break;
  }

  if (categoryId != null) {
    sb.write('&fid=$categoryId');
  }

  if (topicId != null) {
    sb.write('&tid=$topicId');
  }

  if (postId != null) {
    sb.write('&pid=$postId');
  }

  return sb;
}
