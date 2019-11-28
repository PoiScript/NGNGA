import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart';

Future<String> loginAsGuest({
  @required Client client,
  @required String baseUrl,
}) async {
  final res =
      await client.get('https://nga.178.com/nuke.php?__lib=noti&__act=if');

  String cookie = res.headers['set-cookie'];

  int start = cookie.indexOf("ngaPassportUid=") + "ngaPassportUid=".length;

  if (start == -1) return null;

  int end = cookie.indexOf(";", start);

  return cookie.substring(start, end);
}
