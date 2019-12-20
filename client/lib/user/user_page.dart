import 'package:flutter/material.dart' hide Builder;
import 'package:intl/intl.dart';

import 'package:business/models/user.dart';
import 'package:ngnga/localizations.dart';
import 'package:ngnga/utils/open_link.dart';
import 'package:ngnga/widgets/bbcode_render.dart';
import 'package:ngnga/widgets/user_avatar.dart';

import 'avatar_gallery.dart';

final _dateFormatter = DateFormat('yyyy-MM-dd HH:mm');

class UserPage extends StatelessWidget {
  final User user;

  const UserPage({
    @required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(AppLocalizations.of(context).user),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                _buildAvatar(context),
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.all(0.0),
                    title: Text(user.username),
                    subtitle: Text('UID: ${user.id}'),
                  ),
                ),
              ],
            ),
            // ListTile(
            //   title: Text('Medals'),
            // ),
            // Container(
            //   padding: EdgeInsets.symmetric(horizontal: 16.0),
            //   child: Wrap(
            //       children:
            //           user.medals.map((i) => Chip(label: Text('$i'))).toList()),
            // ),
            ListTile(
              title: Text(AppLocalizations.of(context).createdAt),
              subtitle: Text(_dateFormatter.format(user.createdAt)),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context).lastVisited),
              subtitle: Text(_dateFormatter.format(user.lastVisited)),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context).postsCount),
              subtitle: Text(user.postsCount.toString()),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context).signature),
            ),
            if (user.signature != null && user.signature.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                alignment: Alignment.centerLeft,
                child: BBCodeRender(
                  raw: user.signature,
                  openUser: (userId) {},
                  openLink: (url) => openLink(context, url),
                  openPost: (topicId, page, postId) {},
                ),
              )
            else
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                alignment: Alignment.centerLeft,
                child: Text(
                  AppLocalizations.of(context).noSignature,
                  style: Theme.of(context)
                      .textTheme
                      .body1
                      .copyWith(fontStyle: FontStyle.italic),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    Widget avatar = UserAvatar(
      user: user,
      size: 72.0,
      index: 0,
    );

    if (user.avatars.length > 1) {
      avatar = Stack(
        children: <Widget>[
          avatar,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.collections,
                color: Colors.white,
                size: 16.0,
              ),
            ),
          ),
        ],
      );
    }

    avatar = Container(
      padding: const EdgeInsets.all(16.0),
      child: avatar,
    );

    if (user.avatars.isEmpty) return avatar;

    return GestureDetector(
      child: avatar,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AvatarsGallery(user.avatars),
          ),
        );
      },
    );
  }
}
