import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
// import 'package:ngnga/localizations.dart';

class RefreshHeader extends ClassicalHeader {
  RefreshHeader(BuildContext context)
      : super(
          textColor: Theme.of(context).textTheme.caption.color,
          showInfo: false,
          // TODO: waiting for https://github.com/xuelongqy/flutter_easyrefresh/pull/218 to be merged
          // refreshText: AppLocalizations.of(context).pullToRefresh,
          // refreshReadyText: AppLocalizations.of(context).releaseToRefresh,
          // refreshingText: AppLocalizations.of(context).refreshing,
          // refreshedText: AppLocalizations.of(context).refreshCompleted,
        );
}

class PreviousPageHeader extends ClassicalHeader {
  PreviousPageHeader(BuildContext context, int page)
      : super(
          textColor: Theme.of(context).textTheme.caption.color,
          showInfo: false,
          // refreshText: AppLocalizations.of(context).pullToLoadNPage(page),
          // refreshReadyText:
          //     AppLocalizations.of(context).releaseToLoadNPage(page),
          // refreshingText: AppLocalizations.of(context).loadingNPage(page),
          // refreshedText: AppLocalizations.of(context).loadCompleted,
        );
}

class NextPageHeader extends ClassicalFooter {
  NextPageHeader(BuildContext context)
      : super(
          textColor: Theme.of(context).textTheme.caption.color,
          showInfo: false,
          // loadText: AppLocalizations.of(context).pushToLoad,
          // loadReadyText: AppLocalizations.of(context).releaseToLoad,
          // loadingText: AppLocalizations.of(context).loading,
          // loadedText: AppLocalizations.of(context).loadCompleted,
        );
}
