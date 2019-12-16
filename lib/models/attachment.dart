final _smallThumbnailMask = 16;
final _defaultThumbnailMask = 32;
final _mediumThumbnailMask = 64;

class Attachment {
  final String url;
  final String name;
  final int _thumbBits;

  Attachment({
    this.url,
    this.name,
    int thumbBits,
  }) : _thumbBits = thumbBits;

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      name: json['url_utf8_org_name'],
      url: json['attachurl'],
      thumbBits:
          json['thumb'] is String ? int.parse(json['thumb']) : json['thumb'],
    );
  }

  String get thumbUrl {
    if (_thumbBits & _smallThumbnailMask == _smallThumbnailMask) {
      return 'https://img.nga.178.com/attachments/$url.thumb_s.jpg';
    } else if (_thumbBits & _defaultThumbnailMask == _defaultThumbnailMask) {
      return 'https://img.nga.178.com/attachments/$url.thumb.jpg';
    } else if (_thumbBits & _mediumThumbnailMask == _mediumThumbnailMask) {
      return 'https://img.nga.178.com/attachments/$url.medium.jpg';
    } else {
      return fullUrl;
    }
  }

  String get fullUrl => 'https://img.nga.178.com/attachments/$url';
}
