import 'dart:convert';

class User {
  final int id;
  final String username;
  final List<String> avatars;
  final String signature;
  final int postsCount;
  final DateTime createdAt;

  User({
    this.id,
    this.username,
    this.avatars,
    this.signature,
    this.postsCount,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json, int id) {
    List<String> avatars = [];

    if (json['avatar'] is String) {
      if (json['avatar'].startsWith(r"/*$js$*/")) {
        final map = jsonDecode(json['avatar'].substring(8));
        for (final value in map.values) {
          if (value is! String) continue;

          if (value.startsWith("https://") || value.startsWith("http://")) {
            avatars.add(value);
          } else if (value.startsWith(".a/")) {
            avatars.add(parseAvatar(value));
          }
        }
      } else {
        for (final value in json['avatar'].replaceAll("%7C", "|").split("|")) {
          if (value.startsWith("https://") || value.startsWith("http://")) {
            avatars.add(value);
          } else if (value.startsWith(".a/")) {
            avatars.add(parseAvatar(value));
          }
        }
      }
    }

    return User(
      id: id,
      username: id <= 0 ? "#ANONYMOUS#" : json['username'],
      avatars: avatars,
      signature: json['signature'] ?? json['sign'],
      postsCount: json['postnum'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        json['regdate'] ?? 0 * 1000,
      ),
    );
  }
}

String parseAvatar(String avatar) {
  String path = int.parse(
    avatar.substring(3, avatar.indexOf('_')),
  ).toRadixString(16).padLeft(9, '0');

  String a = path.substring(path.length - 3, path.length);
  String b = path.substring(path.length - 6, path.length - 3);
  String c = path.substring(path.length - 9, path.length - 6);

  return "http://img.nga.cn/avatars/2002/$a/$b/$c/${avatar.substring(3)}";
}
