class VotePostResponse {
  final String message;
  final int value;

  VotePostResponse({
    this.message,
    this.value,
  });

  factory VotePostResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] is List) {
      return VotePostResponse(
        message: json['data'][0],
        value: json['data'][1],
      );
    } else {
      return VotePostResponse(
        message: json['error'][0],
        value: 0,
      );
    }
  }
}
