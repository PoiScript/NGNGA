class ApplyEditingResponse {
  final int code;
  final String message;

  ApplyEditingResponse({
    this.code,
    this.message,
  });

  ApplyEditingResponse.fromJson(Map<String, dynamic> json)
      : code = json['code'],
        message = json['msg'];
}
