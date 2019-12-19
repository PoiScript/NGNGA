import 'package:flutter/material.dart';
import 'package:ngnga/widgets/link_dialog.dart';

void openLink(BuildContext context, String url) {
  Uri uri = Uri.tryParse(url);

  if (uri == null) {
    Scaffold.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Invalid link')));
  }

  if (uri.hasAbsolutePath ||
      uri.host == 'nga.178.com' ||
      uri.host == 'bbs.ngacn.cc' ||
      uri.host == 'bbs.nga.cn' ||
      uri.host == 'ngabbs.com') {
    if (uri.path == '/read.php' &&
        uri.queryParameters.containsKey('tid') &&
        int.tryParse(uri.queryParameters['tid']) != null) {
      Navigator.pushNamed(context, '/t', arguments: {
        'id': int.parse(uri.queryParameters['tid']),
        'page': int.tryParse(uri.queryParameters['page'] ?? '') ?? 0,
      });
      return;
    }

    if (uri.path == '/thread.php' &&
        uri.queryParameters.containsKey('fid') &&
        int.tryParse(uri.queryParameters['fid']) != null) {
      Navigator.pushNamed(context, '/c', arguments: {
        'id': int.parse(uri.queryParameters['fid']),
        'isSubcategory': false,
        'page': int.tryParse(uri.queryParameters['page'] ?? '') ?? 0,
      });
      return;
    }

    if (uri.path == '/thread.php' &&
        uri.queryParameters.containsKey('stid') &&
        int.tryParse(uri.queryParameters['stid']) != null) {
      Navigator.pushNamed(context, '/c', arguments: {
        'id': int.parse(uri.queryParameters['stid']),
        'isSubcategory': true,
        'page': int.tryParse(uri.queryParameters['page'] ?? '') ?? 0,
      });
      return;
    }
  }

  showDialog(
    context: context,
    builder: (context) => LinkDialog(url),
  );
}
