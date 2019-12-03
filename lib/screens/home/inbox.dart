import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

import 'package:ngnga/store/actions/fetch_notifications.dart';
import 'package:ngnga/store/state.dart';
import 'package:ngnga/utils/duration.dart';
import 'package:ngnga/utils/requests.dart';

class Inbox extends StatelessWidget {
  final Future<void> Function() fetch;
  final List<UserNotification> notifications;

  const Inbox({
    Key key,
    @required this.fetch,
    @required this.notifications,
  })  : assert(fetch != null),
        assert(notifications != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return EasyRefresh(
      header: ClassicalHeader(),
      onRefresh: fetch,
      child: ListView.separated(
        separatorBuilder: (context, inex) => Divider(),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          UserNotification notification = notifications[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            notification.username,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.caption,
                          ),
                          Text(
                            _description(notification.type),
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ],
                      ),
                    ),
                    // StreamBuilder<DateTime>(
                    //   stream: Stream.periodic(const Duration(minutes: 1)),
                    //   builder: (context, snapshot) =>
                    Text(
                      duration(DateTime.now(), notification.dateTime),
                      style: Theme.of(context).textTheme.caption,
                    ),
                    // ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.all(8.0),
                child: Text(notification.topicTitle),
              ),
            ],
          );
        },
      ),
    );
  }

  String _description(NotificationType type) {
    switch (type) {
      case NotificationType.postOnYourTopic:
        return '回复了你的主题';
      case NotificationType.replyOnYourPost:
        return '回复了你在该主题中的回复';
      case NotificationType.commentOnYourTopic:
        return '评论了你的主题';
      case NotificationType.commentOnYourPost:
        return '评论了你在该主题中的回复';
      case NotificationType.metionOnTopic:
        return '在主题中 @ 了你';
      case NotificationType.metionOnReply:
        return '在回复中 @ 了你';
    }
    return null;
  }
}

class InboxConnector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ViewModel>(
      model: ViewModel(),
      builder: (context, vm) => Inbox(
        notifications: vm.notifications,
        fetch: vm.fetch,
      ),
    );
  }
}

class ViewModel extends BaseModel<AppState> {
  Future<void> Function() fetch;
  List<UserNotification> notifications;

  ViewModel();

  ViewModel.build({
    @required this.notifications,
    @required this.fetch,
  }) : super(equals: [notifications]);

  @override
  ViewModel fromStore() {
    return ViewModel.build(
      notifications: state.notifications,
      fetch: () => dispatchFuture(FetchNotificationsAction()),
    );
  }
}
