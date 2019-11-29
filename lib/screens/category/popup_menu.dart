import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ngnga/store/actions.dart';
import 'package:ngnga/store/state.dart';

enum Choice {
  copyLinkToClipboard,
  addToPinned,
  removeFromPinned,
}

class PopupMenu extends StatelessWidget {
  final int categoryId;
  final bool isSubcategory;
  final String baseUrl;

  final bool isPinned;
  final VoidCallback addToPinned;
  final VoidCallback removeFromPinned;

  PopupMenu({
    Key key,
    @required this.categoryId,
    @required this.isSubcategory,
    @required this.baseUrl,
    @required this.isPinned,
    @required this.addToPinned,
    @required this.removeFromPinned,
  }) : super(key: key);

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
        PopupMenuItem<Choice>(
          value: Choice.copyLinkToClipboard,
          child: Text(
            'Copy Link to clipboard',
            style: Theme.of(context).textTheme.body1,
          ),
        ),
        if (isPinned)
          PopupMenuItem<Choice>(
            value: Choice.removeFromPinned,
            child: Text(
              'Remove from pinned',
              style: Theme.of(context).textTheme.body1,
            ),
          )
        else
          PopupMenuItem<Choice>(
            value: Choice.addToPinned,
            child: Text(
              'Add to pinned',
              style: Theme.of(context).textTheme.body1,
            ),
          ),
      ],
      onSelected: (choice) async {
        switch (choice) {
          case Choice.copyLinkToClipboard:
            await Clipboard.setData(ClipboardData(
              text: Uri.https(baseUrl, 'read.php', {
                isSubcategory ? 'stid' : 'tid': categoryId.toString()
              }).toString(),
            ));
            Scaffold.of(context).showSnackBar(SnackBar(
              content: Text('Copied to clipboard'),
            ));
            break;
          case Choice.addToPinned:
            addToPinned();
            Scaffold.of(context).showSnackBar(SnackBar(
              content: Text('Added to pinned'),
            ));
            break;
          case Choice.removeFromPinned:
            removeFromPinned();
            Scaffold.of(context).showSnackBar(SnackBar(
              content: Text('Removed from pinned'),
            ));
            break;
        }
      },
    );
  }
}

class PopupMenuConnector extends StatelessWidget {
  final int categoryId;

  PopupMenuConnector({
    @required this.categoryId,
  }) : assert(categoryId != null);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ViewModel>(
      model: ViewModel(categoryId),
      builder: (context, vm) => PopupMenu(
        categoryId: categoryId,
        isSubcategory: vm.isSubcategory,
        baseUrl: vm.baseUrl,
        isPinned: vm.isPinned,
        addToPinned: vm.addToPinned,
        removeFromPinned: vm.removeFromPinned,
      ),
    );
  }
}

class ViewModel extends BaseModel<AppState> {
  final int categoryId;

  String baseUrl;
  bool isSubcategory;

  bool isPinned;
  VoidCallback addToPinned;
  VoidCallback removeFromPinned;

  ViewModel(this.categoryId);

  ViewModel.build({
    @required this.isSubcategory,
    @required this.categoryId,
    @required this.baseUrl,
    @required this.isPinned,
    @required this.addToPinned,
    @required this.removeFromPinned,
  }) : super(equals: [isPinned]);

  @override
  ViewModel fromStore() {
    return ViewModel.build(
      categoryId: categoryId,
      isSubcategory: state.categories[categoryId].isSubcategory,
      baseUrl: state.settings.baseUrl,
      isPinned: state.pinned.contains(categoryId),
      addToPinned: () => dispatch(AddToPinnedAction(categoryId)),
      removeFromPinned: () => dispatch(RemoveFromPinnedAction(categoryId)),
    );
  }
}
