import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ngnga/localizations.dart';
import 'package:ngnga/widgets/page_picker.dart';

enum Choice {
  copyLinkToClipboard,
  addToPinned,
  removeFromPinned,
  viewToppedTopic,
  jumpToPage,
}

class PopupMenu extends StatelessWidget {
  final int categoryId;
  final bool isSubcategory;
  final String baseUrl;

  final int toppedTopicId;

  final int firstPage;
  final int maxPage;
  final Future<void> Function(int) changePage;

  final bool isPinned;
  final VoidCallback addToPinned;
  final VoidCallback removeFromPinned;

  const PopupMenu({
    Key key,
    @required this.firstPage,
    @required this.maxPage,
    @required this.changePage,
    @required this.categoryId,
    @required this.isSubcategory,
    @required this.baseUrl,
    @required this.toppedTopicId,
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
            AppLocalizations.of(context).copyLinkToClipboard,
            style: Theme.of(context).textTheme.body1,
          ),
        ),
        if (isPinned)
          PopupMenuItem<Choice>(
            value: Choice.removeFromPinned,
            child: Text(
              AppLocalizations.of(context).removeFromPinned,
              style: Theme.of(context).textTheme.body1,
            ),
          )
        else
          PopupMenuItem<Choice>(
            value: Choice.addToPinned,
            child: Text(
              AppLocalizations.of(context).addToPinned,
              style: Theme.of(context).textTheme.body1,
            ),
          ),
        if (toppedTopicId != null)
          PopupMenuItem<Choice>(
            value: Choice.viewToppedTopic,
            child: Text(
              AppLocalizations.of(context).viewToppedTopic,
              style: Theme.of(context).textTheme.body1,
            ),
          ),
        PopupMenuItem<Choice>(
          value: Choice.jumpToPage,
          child: Text(
            AppLocalizations.of(context).jumpToPage,
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
            Scaffold.of(context)
              ..removeCurrentSnackBar()
              ..showSnackBar(SnackBar(
                content:
                    Text(AppLocalizations.of(context).copiedLinkToClipboard),
              ));
            break;
          case Choice.addToPinned:
            addToPinned();
            Scaffold.of(context)
              ..removeCurrentSnackBar()
              ..showSnackBar(SnackBar(
                content: Text(AppLocalizations.of(context).addedToPinned),
              ));
            break;
          case Choice.removeFromPinned:
            removeFromPinned();
            Scaffold.of(context)
              ..removeCurrentSnackBar()
              ..showSnackBar(SnackBar(
                content: Text(AppLocalizations.of(context).removedFromPinned),
              ));
            break;
          case Choice.viewToppedTopic:
            Navigator.pushNamed(context, '/t', arguments: {
              'id': toppedTopicId,
              'page': 0,
            });
            break;
          case Choice.jumpToPage:
            int page = await showDialog<int>(
              context: context,
              builder: (BuildContext context) => PagePicker(
                initialPage: firstPage,
                maxPage: maxPage,
              ),
            );
            if (page != null) {
              changePage(page);
            }
            break;
        }
      },
    );
  }
}
