import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gbk_codec/gbk_codec.dart';
import 'package:http/http.dart';
import 'package:path/path.dart';

import 'package:ngnga/models/response.dart';
import 'package:ngnga/screens/editor/editor.dart';
import 'package:ngnga/store/state.dart';

const _editorActionToString = {
  EditorAction.newTopic: 'new',
  EditorAction.quote: 'quote',
  EditorAction.reply: 'reply',
  EditorAction.modify: 'modify',
  EditorAction.comment: 'reply',
  EditorAction.newPost: 'reply',
};

class Repository {
  String userAgent = '';
  String cookie = '';
  String baseUrl = 'ngabbs.com';

  final Client client;

  Repository() : client = Client();

  // update client cookies base on given userState
  void updateCookie(UserState userState) {
    if (userState is UserLogged) {
      cookie =
          'ngaPassportUid=${userState.uid};ngaPassportCid=${userState.cid};';
      // } else if (userState is Guest) {
      //   // TODO: guest login
      //   cookie = 'ngaPassportUid=${userState.uid};';
    } else if (userState is UserUninitialized) {
      cookie = '';
    }
  }

  Future<Map<String, dynamic>> fetch(
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
    final response = await Response.fromStream(stream);

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getJson(
    String path,
    Map<String, String> queryParameters,
  ) =>
      fetch('GET', path, queryParameters);

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, String> queryParameters,
  ) =>
      fetch('POST', path, queryParameters);

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

  Future<FetchFavorTopicsResponse> fetchFavorTopics({
    @required int page,
  }) async =>
      FetchFavorTopicsResponse.fromJson(await getJson('nuke.php', {
        '__lib': 'topic_favor',
        '__act': 'topic_favor',
        'action': 'get',
        'page': (page + 1).toString(),
        '__output': '11',
      }));

  Future<FavoritesResponse> addToFavorites({
    @required int topicId,
  }) async =>
      FavoritesResponse.fromJson(await postJson('nuke.php', {
        '__lib': 'topic_favor',
        '__act': 'topic_favor',
        'action': 'add',
        'tid': topicId.toString(),
        '__output': '11',
      }));

  Future<FavoritesResponse> removeFromFavorites({
    @required int topicId,
  }) async =>
      FavoritesResponse.fromJson(await postJson('nuke.php', {
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

  Future<NotificationResponse> fetchNotifications() async =>
      NotificationResponse.fromJson(await getJson('nuke.php', {
        '__lib': 'noti',
        '__act': 'get_all',
        '__output': '11',
      }));

  Future<VoteResponse> votePost({
    @required int topicId,
    @required int postId,
    @required int value,
  }) async =>
      VoteResponse.fromJson(await postJson('nuke.php', {
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
