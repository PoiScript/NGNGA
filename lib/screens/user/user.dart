import 'package:async_redux/async_redux.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ngnga/bbcode/render.dart';
import 'package:ngnga/localizations.dart';
import 'package:ngnga/models/user.dart';
import 'package:ngnga/screens/user/avatar_gallery.dart';
import 'package:ngnga/store/state.dart';
import 'package:ngnga/utils/number_to_hsl_color.dart';
import 'package:ngnga/utils/open_link.dart';
import 'package:ngnga/widgets/user_dialog.dart';

final _dateFormatter = DateFormat('yyyy-MM-dd HH:mm');

class UserPage extends StatelessWidget {
  final User user;

  UserPage({
    @required this.user,
  }) : assert(user != null);

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
                  openUser: (userId) {
                    showDialog(
                      context: context,
                      builder: (context) => UserDialog(userId),
                    );
                  },
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
    Widget letterAvatar = CircleAvatar(
      radius: 36.0,
      child: Text(
        user.username[0].toUpperCase(),
        style: Theme.of(context)
            .textTheme
            .body2
            .copyWith(color: Colors.white, fontSize: 32.0),
      ),
      backgroundColor: numberToHslColor(
        user.id,
        Theme.of(context).brightness,
      ),
    );

    if (user.avatars.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        child: letterAvatar,
      );
    }

    Widget avatar = CachedNetworkImage(
      imageUrl: user.avatars[0],
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: 36.0,
        backgroundImage: imageProvider,
      ),
      errorWidget: (context, url, error) => letterAvatar,
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

    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: avatar,
      ),
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

class UserPageConnector extends StatelessWidget {
  final int userId;

  UserPageConnector({
    @required this.userId,
  }) : assert(userId != null);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ViewModel>(
      model: ViewModel(userId),
      builder: (context, vm) => UserPage(
        user: vm.user,
      ),
    );
  }
}

class ViewModel extends BaseModel<AppState> {
  final int userId;

  User user;

  ViewModel(this.userId);

  ViewModel.build({
    @required this.userId,
    @required this.user,
  }) : super(equals: [user]);

  @override
  ViewModel fromStore() {
    return ViewModel.build(
      userId: userId,
      user: state.users[userId],
    );
  }
}
