import 'package:business/models/notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

import 'package:business/inbox/models/inbox_state.dart';
import 'package:ngnga/localizations.dart';
import 'package:ngnga/widgets/distance_to_now.dart';
import 'package:ngnga/widgets/refresh.dart';

class InboxTab extends StatefulWidget {
  final InboxState inboxState;

  final Future<void> Function() refreshInbox;
  final Future<void> Function() maybeRefreshInbox;

  const InboxTab({
    Key key,
    @required this.inboxState,
    @required this.refreshInbox,
    @required this.maybeRefreshInbox,
  }) : super(key: key);

  @override
  _InboxTabState createState() => _InboxTabState();
}

class _InboxTabState extends State<InboxTab> {
  @override
  void initState() {
    widget.maybeRefreshInbox();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.inboxState.initialized) {
      return Center(child: CircularProgressIndicator());
    }

    return EasyRefresh(
      header: RefreshHeader(context),
      onRefresh: widget.refreshInbox,
      child: ListView.separated(
        separatorBuilder: (context, inex) => Divider(height: 0.0),
        itemCount: widget.inboxState.notifications.length,
        itemBuilder: (context, index) => _NotificationItem(
          notification: widget.inboxState.notifications[index],
        ),
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final UserNotification notification;

  const _NotificationItem({Key key, this.notification}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(
        context,
        '/t',
        arguments: {'id': notification.topicId, 'page': notification.pageIndex},
      ),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
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
                DistanceToNow(notification.dateTime),
              ],
            ),
            Container(
              margin: EdgeInsets.only(top: 8.0),
              child: Text(notification.topicTitle),
            ),
          ],
        ),
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
