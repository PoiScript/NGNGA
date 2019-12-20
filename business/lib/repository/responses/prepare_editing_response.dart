import '../../models/attachment.dart';

class PrepareEditingResponse {
  final String content;
  final String subject;
  final String uploadUrl;
  final String uploadAuthCode;
  final List<Attachment> attachs;

  PrepareEditingResponse({
    this.content,
    this.subject,
    this.uploadUrl,
    this.attachs,
    this.uploadAuthCode,
  });

  factory PrepareEditingResponse.fromJson(Map<String, dynamic> json) {
    return PrepareEditingResponse(
      content: json['result'][0]['content'],
      subject: json['result'][0]['subject'],
      uploadUrl: json['result'][0]['attach_url'],
      attachs: List.of(json['result'][0]['attachs'] ?? [])
          .map((val) => Attachment.fromJson(val))
          .toList(growable: false),
      uploadAuthCode: json['result'][0]['auth'],
    );
  }
}
