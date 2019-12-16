import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:ngnga/localizations.dart';

import 'package:ngnga/models/notification.dart';
import 'package:ngnga/store/actions.dart';
import 'package:ngnga/store/inbox.dart';
import 'package:ngnga/store/state.dart';
import 'package:ngnga/utils/duration.dart';
import 'package:ngnga/widgets/refresh.dart';

final _everyMinutes = StreamController<DateTime>.broadcast()
  ..addStream(
    Stream.periodic(Duration(minutes: 1), (_) => DateTime.now()),
  );

class Inbox extends StatelessWidget {
  final Future<void> Function() fetch;
  final InboxState inboxState;

  const Inbox({
    Key key,
    @required this.fetch,
    @required this.inboxState,
  })  : assert(fetch != null),
        assert(inboxState != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (inboxState is InboxUninitialized) {
      return Center(child: CircularProgressIndicator());
    }

    if (inboxState is InboxLoaded) {
      return _buildList(context, inboxState);
    }

    return null;
  }

  Widget _buildList(BuildContext context, InboxLoaded state) {
    return EasyRefresh(
      header: RefreshHeader(context),
      onRefresh: fetch,
      child: ListView.separated(
        separatorBuilder: (context, inex) => Divider(height: 0.0),
        itemCount: state.notifications.length,
        itemBuilder: (context, index) {
          UserNotification notification = state.notifications[index];
          return InkWell(
            onTap: () => Navigator.pushNamed(
              context,
              '/t',
              arguments: {
                'id': notification.topicId,
                'page': notification.pageIndex
              },
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
                      StreamBuilder<DateTime>(
                        initialData: DateTime.now(),
                        stream: _everyMinutes.stream,
                        builder: (context, snapshot) => Text(
                          duration(snapshot.data, notification.dateTime),
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ),
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
      onInit: (store) => store.dispatch(FetchNotificationsAction()),
      builder: (context, vm) => Inbox(
        inboxState: vm.inboxState,
        fetch: vm.fetch,
      ),
    );
  }
}

class ViewModel extends BaseModel<AppState> {
  Future<void> Function() fetch;
  InboxState inboxState;

  ViewModel();

  ViewModel.build({
    @required this.inboxState,
    @required this.fetch,
  }) : super(equals: [inboxState]);

  @override
  ViewModel fromStore() {
    return ViewModel.build(
      inboxState: state.inboxState,
      fetch: () => dispatchFuture(RefreshNotificationsAction()),
    );
  }
}
