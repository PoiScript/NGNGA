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
    return User(
      id: json['uid'],
      username: json['username'],
      avatars: json['avatar'],
      signature: json['signature'],
      postsCount: json['postnum'],
      createdAt: json['regDate'],
    );
  }
}
