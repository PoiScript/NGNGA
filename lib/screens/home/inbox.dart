import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:ngnga/localizations.dart';

import 'package:ngnga/store/actions.dart';
import 'package:ngnga/store/state.dart';
import 'package:ngnga/utils/duration.dart';
import 'package:ngnga/utils/requests.dart';
import 'package:ngnga/widgets/refresh.dart';

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
      header: RefreshHeader(context),
      firstRefresh: true,
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
                      child: Text(
                        _description(
                          context,
                          notification.type,
                          notification.username,
                        ),
                        style: Theme.of(context).textTheme.caption,
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

  String _description(
    BuildContext context,
    NotificationType type,
    String username,
  ) {
    switch (type) {
      case NotificationType.postOnYourTopic:
        return AppLocalizations.of(context).replyYourTopic(username);
      case NotificationType.replyOnYourPost:
        return AppLocalizations.of(context).replyYourPost(username);
      case NotificationType.commentOnYourTopic:
        return AppLocalizations.of(context).commentYourTopic(username);
      case NotificationType.commentOnYourPost:
        return AppLocalizations.of(context).commentYourPost(username);
      case NotificationType.metionOnTopic:
        return AppLocalizations.of(context).metionYouOnTopic(username);
      case NotificationType.metionOnReply:
        return AppLocalizations.of(context).metionYouOnReply(username);
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
