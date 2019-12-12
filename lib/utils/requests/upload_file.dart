import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:path/path.dart';

class UploadFileResponse {
  final String attachUrl;
  final String attachCode;
  final String attachChecksum;
  final int thumb;

  UploadFileResponse._({
    this.attachUrl,
    this.attachCode,
    this.attachChecksum,
    this.thumb,
  });

  factory UploadFileResponse.fromJson(Map<String, dynamic> json) {
    return UploadFileResponse._(
      attachUrl: json['url'],
      attachCode: json['attachments'],
      attachChecksum: json['attachments_check'],
      thumb: json['thumb'],
    );
  }
}

Future<UploadFileResponse> uploadFile({
  @required Client client,
  @required String originDomain,
  @required String uploadUrl,
  @required String cookie,
  @required int categoryId,
  @required String auth,
  @required File file,
}) async {
  print(uploadUrl);
  MultipartRequest request = MultipartRequest('POST', Uri.parse(uploadUrl));
  request.headers['cookie'] = cookie;
  request.fields['func'] = 'upload';
  request.fields['v2'] = '1';
  request.fields['origin_domain'] = originDomain;
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

  print(uploadUrl);

  final stream = await client.send(request);
  final res = await Response.fromStream(stream);

  final json = jsonDecode(res.body);

  return UploadFileResponse.fromJson(json);
}
