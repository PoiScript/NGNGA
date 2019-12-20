class UploadFileResponse {
  final String attachUrl;
  final String attachCode;
  final String attachChecksum;
  final int thumb;

  UploadFileResponse({
    this.attachUrl,
    this.attachCode,
    this.attachChecksum,
    this.thumb,
  });

  factory UploadFileResponse.fromJson(Map<String, dynamic> json) {
    return UploadFileResponse(
      attachUrl: json['url'],
      attachCode: json['attachments'],
      attachChecksum: json['attachments_check'],
      thumb: json['thumb'],
    );
  }
}
