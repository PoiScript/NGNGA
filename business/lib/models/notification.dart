import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:html_unescape/html_unescape.dart';

part 'notification.g.dart';

final _unescape = HtmlUnescape();

class NotificationType extends EnumClass {
  static Serializer<NotificationType> get serializer =>
      _$notificationTypeSerializer;

  static const NotificationType postOnYourTopic = _$postOnYourTopic;
  static const NotificationType replyOnYourPost = _$replyOnYourPost;
  static const NotificationType commentOnYourTopic = _$commentOnYourTopic;
  static const NotificationType commentOnYourPost = _$commentOnYourPost;
  static const NotificationType metionOnTopic = _$metionOnTopic;
  static const NotificationType metionOnReply = _$metionOnReply;
  static const NotificationType unknown = _$unknown;

  const NotificationType._(String name) : super(name);

  static BuiltSet<NotificationType> get values => _$tyValues;
  static NotificationType valueOf(String name) => _$tyValueOf(name);
}

class UserNotification {
  final NotificationType type;
  final int userId;
  final String username;
  final int topicId;
  final String topicTitle;
  final int postId;
  final DateTime dateTime;
  final int pageIndex;

  UserNotification._({
    this.type,
    this.userId,
    this.username,
    this.topicId,
    this.topicTitle,
    this.postId,
    this.dateTime,
    this.pageIndex,
  });

  factory UserNotification.fromJson(Map<String, dynamic> json) {
    NotificationType type;

    switch (json['0']) {
      case 1:
        type = NotificationType.postOnYourTopic;
        break;
      case 2:
        type = NotificationType.replyOnYourPost;
        break;
      case 3:
        type = NotificationType.commentOnYourTopic;
        break;
      case 4:
        type = NotificationType.commentOnYourPost;
        break;
      case 7:
        type = NotificationType.metionOnTopic;
        break;
      case 8:
        type = NotificationType.metionOnReply;
        break;
      default:
        throw 'Unknown notification type';
    }

    return UserNotification._(
      type: type,
      userId: json['1'],
      username: json['2'],
      topicId: json['6'],
      topicTitle: _unescape.convert(json['5']),
      postId: json['7'],
      dateTime: DateTime.fromMillisecondsSinceEpoch(
        json['9'] * 1000,
      ),
      pageIndex: json['10'] - 1,
    );
  }
}
