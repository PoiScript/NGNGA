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

  factory User.fromJson(Map<String, dynamic> json) {
    List<String> avatars = [];
    if (json['avatar'] is String) {
      String string = json['avatar'].replaceAll("%7C", "|");
      var lastEnd = 0;
      for (var match in RegExp(r"https?://").allMatches(string)) {
        if (match.start != 0) {
          avatars.add(string.substring(lastEnd, match.start));
        }
        lastEnd = match.start;
      }
      if (lastEnd != string.length) {
        avatars.add(string.substring(lastEnd));
      }
    }

    return User(
      id: json['uid'],
      username: json['username'],
      avatars: avatars,
      signature: json['signature'],
      postsCount: json['postnum'],
      createdAt: json['regDate'],
    );
  }
}
