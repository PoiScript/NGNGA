import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';

import 'package:ngnga/store/actions.dart';
import 'package:ngnga/store/state.dart';

enum Choice {
  AddToFavorites,
  RemoveFromFavorites,
  CopyLinkToClipboard,
  JumpToPage,
}

class PopupMenu extends StatelessWidget {
  final bool isFavorited;
  final Future<void> Function() addToFavorites;
  final Future<void> Function() removeFromFavorites;

  PopupMenu({
    Key key,
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
        isFavorited
            ? PopupMenuItem<Choice>(
                value: Choice.RemoveFromFavorites,
                child: Text(
                  "Remove from Favorites",
                  style: Theme.of(context).textTheme.body1,
                ),
              )
            : PopupMenuItem<Choice>(
                value: Choice.AddToFavorites,
                child: Text(
                  "Add to Favorites",
                  style: Theme.of(context).textTheme.body1,
                ),
              ),
      ],
      onSelected: (choice) {
        switch (choice) {
          case Choice.RemoveFromFavorites:
            removeFromFavorites();
            break;
          case Choice.AddToFavorites:
            addToFavorites();
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
        isFavorited: vm.isFavorited,
        addToFavorites: vm.addToFavorites,
        removeFromFavorites: vm.removeFromFavorites,
      ),
    );
  }
}

class ViewModel extends BaseModel<AppState> {
  final topicId;

  bool isFavorited;
  Future<void> Function() addToFavorites;
  Future<void> Function() removeFromFavorites;

  ViewModel(this.topicId);

  ViewModel.build({
    @required this.topicId,
    @required this.isFavorited,
    @required this.addToFavorites,
    @required this.removeFromFavorites,
  }) : super(equals: [isFavorited]);

  @override
  ViewModel fromStore() {
    return ViewModel.build(
      topicId: topicId,
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
