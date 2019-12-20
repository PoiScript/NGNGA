import 'dart:convert';
import 'dart:io';

import 'package:built_value/built_value.dart';
import 'package:flutter/foundation.dart';
import 'package:fast_gbk/fast_gbk.dart';
import 'package:http/http.dart';
import 'package:path/path.dart';

import '../models/editor_action.dart';
import 'responses/apply_editing_response.dart';
import 'responses/edit_favorites_response.dart';
import 'responses/fetch_category_topics.dart';
import 'responses/fetch_favorite_topics_response.dart';
import 'responses/fetch_notification_response.dart';
import 'responses/fetch_topic_posts_response.dart';
import 'responses/prepare_editing_response.dart';
import 'responses/upload_file_response.dart';
import 'responses/vote_post_response.dart';

part 'repository.g.dart';

const _editorActionToString = {
  EditorAction.newTopic: 'new',
  EditorAction.quote: 'quote',
  EditorAction.reply: 'reply',
  EditorAction.modify: 'modify',
  EditorAction.comment: 'reply',
  EditorAction.newPost: 'reply',
};

abstract class Repository implements Built<Repository, RepositoryBuilder> {
  Repository._();

  factory Repository([Function(RepositoryBuilder) updates]) = _$Repository;

  String get userAgent;
  String get cookie;
  String get baseUrl;
  Client get client;

  static void _initializeBuilder(RepositoryBuilder b) => b
    ..baseUrl = 'ngabbs.com'
    ..cookie = ''
    ..userAgent = ''
    ..client = Client();

  Future<String> fetch(
    String method,
    String path,
    Map<String, String> queryParameters,
  ) async {
    StringBuffer query = StringBuffer();
    for (MapEntry entry in queryParameters.entries) {
      if (entry.value == null) continue;
      _urlEncodeGbk(entry.key, query);
      query.write('=');
      _urlEncodeGbk(entry.value, query);
      query.write('&');
    }

    final uri = Uri(
      scheme: 'https',
      host: baseUrl,
      path: path,
      query: query.toString(),
    );

    if (kDebugMode) print('$method $uri');

    final request = Request(method, uri);
    request.headers['cookie'] = cookie;
    request.headers['user-agent'] = userAgent;

    final stream = await client.send(request);

    Response response = await Response.fromStream(stream);

    return response.body;
  }

  Future<dynamic> getJson(
    String path,
    Map<String, String> queryParameters,
  ) =>
      fetch('GET', path, queryParameters).then(jsonDecode);

  Future<dynamic> postJson(
    String path,
    Map<String, String> queryParameters,
  ) =>
      fetch('POST', path, queryParameters).then(jsonDecode);

  Future<FetchTopicPostsResponse> fetchTopicPosts({
    @required int topicId,
    @required int page,
  }) async =>
      FetchTopicPostsResponse.fromJson(await getJson('read.php', {
        'tid': topicId.toString(),
        'page': (page + 1).toString(),
        '__output': '11',
      }));

  Future<FetchTopicPostsResponse> fetchReply({
    @required int topicId,
    @required int postId,
  }) async =>
      FetchTopicPostsResponse.fromJson(await getJson('read.php', {
        'pid': postId.toString(),
        'tid': topicId.toString(),
        '__output': '11',
      }));

  Future<FetchFavoriteTopicsResponse> fetchFavorTopics({
    @required int page,
  }) async =>
      FetchFavoriteTopicsResponse.fromJson(await getJson('nuke.php', {
        '__lib': 'topic_favor',
        '__act': 'topic_favor',
        'action': 'get',
        'page': (page + 1).toString(),
        '__output': '11',
      }));

  Future<FetchFavoriteTopicsResponse> addToFavorites({
    @required int topicId,
  }) async =>
      FetchFavoriteTopicsResponse.fromJson(await postJson('nuke.php', {
        '__lib': 'topic_favor',
        '__act': 'topic_favor',
        'action': 'add',
        'tid': topicId.toString(),
        '__output': '11',
      }));

  Future<EditFavoritesResponse> removeFromFavorites({
    @required int topicId,
  }) async =>
      EditFavoritesResponse.fromJson(await postJson('nuke.php', {
        '__lib': 'topic_favor',
        '__act': 'topic_favor',
        'action': 'del',
        'tidarray': topicId.toString(),
        // TODO: handle different page index
        'page': '1',
        '__output': '11',
      }));

  Future<FetchCategoryTopicsResponse> fetchCategoryTopics({
    @required int categoryId,
    @required int page,
    @required bool isSubcategory,
  }) async =>
      FetchCategoryTopicsResponse.fromJson(await getJson('thread.php', {
        isSubcategory ? 'stid' : 'fid': categoryId.toString(),
        'page': (page + 1).toString(),
        '__output': '11',
      }));

  Future<FetchNotificationResponse> fetchNotifications() async =>
      FetchNotificationResponse.fromJson(await getJson('nuke.php', {
        '__lib': 'noti',
        '__act': 'get_all',
        '__output': '11',
      }));

  Future<VotePostResponse> votePost({
    @required int topicId,
    @required int postId,
    @required int value,
  }) async =>
      VotePostResponse.fromJson(await postJson('nuke.php', {
        '__lib': 'topic_recommend',
        '__act': 'add',
        'tid': topicId.toString(),
        'pid': postId.toString(),
        'value': value.toString(),
        'raw': '3',
        '__output': '11',
      }));

  Future<PrepareEditingResponse> prepareEditing({
    @required EditorAction action,
    @required int categoryId,
    @required int topicId,
    @required int postId,
  }) async =>
      PrepareEditingResponse.fromJson(await getJson('post.php', {
        'fid': categoryId?.toString(),
        'tid': topicId?.toString(),
        'pid': postId?.toString(),
        'action': _editorActionToString[action],
        'comment': action == EditorAction.comment ? '1' : null,
        '__output': '14',
      }));

  Future<ApplyEditingResponse> applyEditing({
    @required EditorAction action,
    @required int categoryId,
    @required int topicId,
    @required int postId,
    @required String subject,
    @required String content,
    @required String attachmentCode,
    @required String attachmentChecksum,
  }) async =>
      ApplyEditingResponse.fromJson(await postJson('post.php', {
        'fid': categoryId?.toString(),
        'tid': topicId?.toString(),
        'pid': postId?.toString(),
        'action': _editorActionToString[action],
        'comment': action == EditorAction.comment ? '1' : null,
        'step': '2',
        'post_content': content,
        'post_subject': subject.trim().isNotEmpty ? subject : null,
        'attachments': attachmentCode.isNotEmpty ? attachmentCode : null,
        'attachments_check':
            attachmentChecksum.isNotEmpty ? attachmentChecksum : null,
        '__output': '14',
      }));

  Future<UploadFileResponse> uploadFile({
    @required String uploadUrl,
    @required int categoryId,
    @required String auth,
    @required File file,
  }) async {
    MultipartRequest request = MultipartRequest('POST', Uri.parse(uploadUrl));

    request.headers['cookie'] = cookie;
    request.headers['user-agent'] = userAgent;

    request.fields['func'] = 'upload';
    request.fields['v2'] = '1';
    request.fields['origin_domain'] = baseUrl;
    request.fields['__output'] = '11';
    request.fields['auth'] = auth;
    request.fields['fid'] = categoryId.toString();
    request.fields['attachment_file1_watermark'] = '';
    request.fields['attachment_file1_dscp'] = '';
    request.fields['attachment_file1_img'] = '1';
    request.fields['attachment_file1_auto_size'] = '';
    request.fields['attachment_file1_url_utf8_name'] =
        Uri.encodeFull(basename(file.path));
    request.files.add(
      await MultipartFile.fromPath('attachment_file1', file.path),
    );

    if (kDebugMode) print('POST $uploadUrl');

    final stream = await client.send(request);
    final res = await Response.fromStream(stream);

    final json = jsonDecode(res.body);

    return UploadFileResponse.fromJson(json);
  }

//   Future<FetchTopicKeyResponse> fetchTopicKeys({
//     @required int forumId,
//   }) async {
//     final res = await fetch('GET', 'nuke.php', {
//       '__lib': 'topic_key',
//       '__act': 'get',
//       'raw': '1',
//       'fid': forumId.toString(),
//     });
//     if (res.startsWith('window.script_muti_get_var_store=')) {
//       return FetchTopicKeyResponse.fromJson(
//         jsonDecode(res.substring('window.script_muti_get_var_store='.length)),
//       );
//     } else {
//       return FetchTopicKeyResponse(keys: []);
//     }
//   }
}

_urlEncodeGbk(String text, StringBuffer sb) {
  for (int code in gbk.encode(text)) {
    if (code <= 0x000F) {
      sb..write('%0')..write(code.toRadixString(16));
    } else if (code <= 0x00FF) {
      sb..write('%')..write(code.toRadixString(16));
    } else if (code <= 0x0FFF) {
      sb..write('%0')..write(((code >> 8) & 0xFF)..toRadixString(16));
      sb..write('%')..write((code & 0xFF).toRadixString(16));
    } else {
      sb..write('%')..write(((code >> 8) & 0xFF).toRadixString(16));
      sb..write('%')..write((code & 0xFF).toRadixString(16));
    }
  }
}
