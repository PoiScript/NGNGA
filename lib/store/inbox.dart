import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';

import 'package:ngnga/models/notification.dart';

part 'inbox.g.dart';

abstract class InboxState implements Built<InboxState, InboxStateBuilder> {
  InboxState._();

  factory InboxState([Function(InboxStateBuilder) updates]) = _$InboxState;

  bool get initialized;
  BuiltList<UserNotification> get notifications;

  static void _initializeBuilder(InboxStateBuilder b) => b..initialized = false;
}
