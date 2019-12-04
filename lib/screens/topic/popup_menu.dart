import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ngnga/localizations.dart';

import 'package:ngnga/store/actions.dart';
import 'package:ngnga/store/state.dart';

import 'page_picker.dart';

enum Choice {
  addToFavorites,
  removeFromFavorites,
  copyLinkToClipboard,
  jumpToPage,
}

class PopupMenu extends StatelessWidget {
  final int topicId;
  final String baseUrl;
  final int firstPage;
  final int maxPage;

  final bool isFavorited;
  final Future<void> Function() addToFavorites;
  final Future<void> Function() removeFromFavorites;
  final Future<void> Function(int) changePage;

  PopupMenu({
    Key key,
    @required this.firstPage,
    @required this.maxPage,
    @required this.topicId,
    @required this.baseUrl,
    @required this.isFavorited,
    @required this.addToFavorites,
    @required this.removeFromFavorites,
    @required this.changePage,
  })  : assert(firstPage != null),
        assert(maxPage != null),
        assert(topicId != null),
        assert(baseUrl != null),
        assert(isFavorited != null),
        assert(addToFavorites != null),
        assert(removeFromFavorites != null),
        assert(changePage != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Choice>(
      icon: Icon(
        Icons.more_vert,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
      ),
      itemBuilder: (context) => [
        if (isFavorited)
          PopupMenuItem<Choice>(
            value: Choice.removeFromFavorites,
            child: Text(
              AppLocalizations.of(context).removeFromFavorites,
              style: Theme.of(context).textTheme.body1,
            ),
          )
        else
          PopupMenuItem<Choice>(
            value: Choice.addToFavorites,
            child: Text(
              AppLocalizations.of(context).addToFavorites,
              style: Theme.of(context).textTheme.body1,
            ),
          ),
        PopupMenuItem<Choice>(
          value: Choice.copyLinkToClipboard,
          child: Text(
            AppLocalizations.of(context).copyLinkToClipboard,
            style: Theme.of(context).textTheme.body1,
          ),
        ),
        PopupMenuItem<Choice>(
          value: Choice.jumpToPage,
          child: Text(
            AppLocalizations.of(context).jumpToPage,
            style: Theme.of(context).textTheme.body1,
          ),
        )
      ],
      onSelected: (choice) async {
        switch (choice) {
          case Choice.removeFromFavorites:
            await removeFromFavorites();
            Scaffold.of(context)
              ..removeCurrentSnackBar()
              ..showSnackBar(SnackBar(
                content:
                    Text(AppLocalizations.of(context).removedFromFavorites),
              ));
            break;
          case Choice.addToFavorites:
            await addToFavorites();
            Scaffold.of(context)
              ..removeCurrentSnackBar()
              ..showSnackBar(SnackBar(
                content: Text(AppLocalizations.of(context).addedToFavorites),
              ));
            break;
          case Choice.copyLinkToClipboard:
            await Clipboard.setData(ClipboardData(
              text: Uri.https(baseUrl, 'read.php', {
                'tid': topicId.toString(),
              }).toString(),
            ));
            Scaffold.of(context)
              ..removeCurrentSnackBar()
              ..showSnackBar(SnackBar(
                content:
                    Text(AppLocalizations.of(context).copiedLinkToClipboard),
              ));
            break;
          case Choice.jumpToPage:
            showDialog<int>(
              context: context,
              builder: (BuildContext context) => PagePicker(
                initialPage: firstPage,
                maxPage: maxPage,
              ),
            ).then((page) {
              if (page != null) {
                changePage(page);
              }
            });
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
        firstPage: vm.firstPage,
        maxPage: vm.maxPage,
        baseUrl: vm.baseUrl,
        isFavorited: vm.isFavorited,
        addToFavorites: vm.addToFavorites,
        removeFromFavorites: vm.removeFromFavorites,
        changePage: vm.changePage,
      ),
    );
  }
}

class ViewModel extends BaseModel<AppState> {
  final int topicId;

  String baseUrl;
  int firstPage;
  int maxPage;

  bool isFavorited;
  Future<void> Function() addToFavorites;
  Future<void> Function() removeFromFavorites;
  Future<void> Function(int) changePage;

  ViewModel(this.topicId);

  ViewModel.build({
    @required this.firstPage,
    @required this.maxPage,
    @required this.topicId,
    @required this.baseUrl,
    @required this.isFavorited,
    @required this.addToFavorites,
    @required this.removeFromFavorites,
    @required this.changePage,
  }) : super(equals: [isFavorited, firstPage, maxPage]);

  @override
  ViewModel fromStore() {
    return ViewModel.build(
      topicId: topicId,
      firstPage: state.topicStates[topicId].firstPage,
      maxPage: state.topicStates[topicId].maxPage,
      baseUrl: state.settings.baseUrl,
      isFavorited: state.favoriteState.topicIds.contains(topicId),
      addToFavorites: () => dispatchFuture(
        AddToFavoritesAction(topicId: topicId),
      ),
      removeFromFavorites: () => dispatchFuture(
        RemoveFromFavoritesAction(topicId: topicId),
      ),
      changePage: (page) => dispatchFuture(
        FetchPostsAction(pageIndex: page, topicId: topicId),
      ),
    );
  }
}
