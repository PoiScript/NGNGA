import 'dart:convert';

import 'package:flutter/foundation.dart';

class User {
  final int id;
  final String username;
  final List<String> avatars;
  final String signature;
  final int postsCount;

  final DateTime createdAt;
  final DateTime lastVisited;

  User({
    @required this.id,
    @required this.username,
    @required this.avatars,
    @required this.signature,
    @required this.postsCount,
    @required this.createdAt,
    @required this.lastVisited,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    List<String> avatars = [];

    if (json['avatar'] is String) {
      if (json['avatar'].startsWith(r'/*$js$*/')) {
        final map = jsonDecode(json['avatar'].substring(8));
        for (final value in map.values) {
          if (value is! String) continue;

          if (value.startsWith('https://') || value.startsWith('http://')) {
            avatars.add(value);
          } else if (value.startsWith('.a/')) {
            avatars.add(parseAvatar(value));
          }
        }
      } else {
        for (final value in json['avatar'].replaceAll('%7C', '|').split('|')) {
          if (value.startsWith('https://') || value.startsWith('http://')) {
            avatars.add(value);
          } else if (value.startsWith('.a/')) {
            avatars.add(parseAvatar(value));
          }
        }
      }
    }

    return User(
      id: json['uid'],
      username: json['uid'] <= 0 ? '#ANONYMOUS#' : json['username'],
      avatars: avatars,
      signature: json['signature'] ?? json['sign'],
      postsCount: json['postnum'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (json['regdate'] ?? 0) * 1000,
      ),
      lastVisited: DateTime.fromMillisecondsSinceEpoch(
        (json['thisvisit'] ?? 0) * 1000,
      ),
    );
  }
}

String parseAvatar(String avatar) {
  String path = int.parse(
    avatar.substring(3, avatar.indexOf('_')),
  ).toRadixString(16).padLeft(9, '0');
  path = path.substring(path.length - 9);

  String a = path.substring(6);
  String b = path.substring(3, 6);
  String c = path.substring(0, 3);

  return 'http://img.nga.cn/avatars/2002/$a/$b/$c/${avatar.substring(3)}';
}
