import 'package:flutter/material.dart';

import 'package:ngnga/models/notification.dart';

abstract class InboxState {
  const InboxState();
}

class InboxUninitialized extends InboxState {}

class InboxLoaded extends InboxState {
  final List<UserNotification> notifications;

  const InboxLoaded({
    @required this.notifications,
  });

  InboxLoaded copyWith({
    List<UserNotification> notifications,
  }) =>
      InboxLoaded(
        notifications: notifications ?? this.notifications,
      );
}
