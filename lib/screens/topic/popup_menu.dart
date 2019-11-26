import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ngnga/store/actions.dart';
import 'package:ngnga/store/state.dart';

enum Choice {
  addToFavorites,
  removeFromFavorites,
  copyLinkToClipboard,
  jumpToPage,
}

class PopupMenu extends StatelessWidget {
  final int topicId;
  final String baseUrl;

  final bool isFavorited;
  final Future<void> Function() addToFavorites;
  final Future<void> Function() removeFromFavorites;

  PopupMenu({
    Key key,
    @required this.topicId,
    @required this.baseUrl,
    @required this.isFavorited,
    @required this.addToFavorites,
    @required this.removeFromFavorites,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Choice>(
      icon: const Icon(
        Icons.more_vert,
        color: Colors.black,
      ),
      itemBuilder: (context) => [
        if (isFavorited)
          PopupMenuItem<Choice>(
            value: Choice.removeFromFavorites,
            child: Text(
              "Remove from Favorites",
              style: Theme.of(context).textTheme.body1,
            ),
          ),
        if (!isFavorited)
          PopupMenuItem<Choice>(
            value: Choice.addToFavorites,
            child: Text(
              "Add to Favorites",
              style: Theme.of(context).textTheme.body1,
            ),
          ),
        PopupMenuItem<Choice>(
          value: Choice.copyLinkToClipboard,
          child: Text(
            "Copy Link to clipboard",
            style: Theme.of(context).textTheme.body1,
          ),
        )
      ],
      onSelected: (choice) async {
        switch (choice) {
          case Choice.removeFromFavorites:
            removeFromFavorites();
            break;
          case Choice.addToFavorites:
            addToFavorites();
            break;
          case Choice.copyLinkToClipboard:
            await Clipboard.setData(ClipboardData(
              text: Uri.https(baseUrl, "read.php", {
                "tid": topicId.toString(),
              }).toString(),
            ));
            Scaffold.of(context).showSnackBar(SnackBar(
              content: Text("copied"),
            ));
            break;
          default:
            break;
        }
      },
    );
  }
}

class PopupMenuConnector extends StatelessWidget {
  final int topicId;

  PopupMenuConnector({
    @required this.topicId,
  }) : assert(topicId != null);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ViewModel>(
      model: ViewModel(topicId),
      builder: (context, vm) => PopupMenu(
        topicId: topicId,
        baseUrl: vm.baseUrl,
        isFavorited: vm.isFavorited,
        addToFavorites: vm.addToFavorites,
        removeFromFavorites: vm.removeFromFavorites,
      ),
    );
  }
}

class ViewModel extends BaseModel<AppState> {
  final topicId;

  String baseUrl;

  bool isFavorited;
  Future<void> Function() addToFavorites;
  Future<void> Function() removeFromFavorites;

  ViewModel(this.topicId);

  ViewModel.build({
    @required this.topicId,
    @required this.baseUrl,
    @required this.isFavorited,
    @required this.addToFavorites,
    @required this.removeFromFavorites,
  }) : super(equals: [isFavorited]);

  @override
  ViewModel fromStore() {
    return ViewModel.build(
      topicId: topicId,
      baseUrl: state.settings.baseUrl,
      isFavorited: state.favoriteState.topicIds.contains(topicId),
      addToFavorites: () => dispatchFuture(
        AddToFavoritesAction(topicId: topicId),
      ),
      removeFromFavorites: () => dispatchFuture(
        RemoveFromFavoritesAction(topicId: topicId),
      ),
    );
  }
}
