import 'package:async_redux/async_redux.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ngnga/bbcode/render.dart';
import 'package:ngnga/localizations.dart';
import 'package:ngnga/models/post.dart';
import 'package:ngnga/models/user.dart';
import 'package:ngnga/screens/editor/editor.dart';
import 'package:ngnga/store/actions.dart';
import 'package:ngnga/store/state.dart';
import 'package:ngnga/utils/duration.dart';
import 'package:ngnga/utils/number_to_hsl_color.dart';
import 'package:ngnga/utils/vendor_icons.dart';
import 'package:ngnga/widgets/link_dialog.dart';
import 'package:ngnga/widgets/post_dialog.dart';
import 'package:ngnga/widgets/user_dialog.dart';

import 'attach_viewer.dart';

final DateFormat dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');

class PostRow extends StatefulWidget {
  final PostItem post;
  final User user;
  final bool sentByMe;

  final Future<void> Function() upvote;
  final Future<void> Function() downvote;

  PostRow({
    @required this.post,
    @required this.user,
    @required this.sentByMe,
    @required this.upvote,
    @required this.downvote,
  })  : assert(post != null),
        assert(user != null),
        assert(sentByMe != null),
        assert(upvote != null),
        assert(downvote != null);

  @override
  _PostRowState createState() => _PostRowState();
}

class _PostRowState extends State<PostRow> {
  DisplayMode _displayMode = DisplayMode.richText;

  Post get post => widget.post.inner;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          if (widget.post.subject.isNotEmpty) _buildSubject(),
          _buildContent(),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          GestureDetector(
            child: _buildAvatar(),
            onTap: () {
              Navigator.pushNamed(context, '/u',
                  arguments: {'uesrId': widget.user.id});
            },
          ),
          Container(width: 8.0),
          Expanded(
            child: GestureDetector(
              child: _buildUsername(),
              onTap: () {
                Navigator.pushNamed(context, '/u',
                    arguments: {'uesrId': widget.user.id});
              },
            ),
          ),
          InkWell(
            child: Container(
              padding: EdgeInsets.all(8.0),
              child: _buildMetaRow(),
            ),
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => _buildMetaList(),
              );
            },
          ),
          PopupMenuButton<Choice>(
            child: Container(
              padding: EdgeInsets.all(8.0),
              child: const Icon(
                Icons.more_vert,
                color: Colors.grey,
                size: 16.0,
              ),
            ),
            itemBuilder: _buildMenuItem,
            onSelected: _onMenuSelected,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final letterAvatar = CircleAvatar(
      radius: 16,
      child: Text(
        widget.user.username[0].toUpperCase(),
        style: Theme.of(context).textTheme.body2.copyWith(color: Colors.white),
      ),
      backgroundColor: numberToHslColor(
        widget.user.id,
        Theme.of(context).brightness,
      ),
    );

    if (widget.user.avatars.isEmpty) return letterAvatar;

    // wrap the avatar with a sized box,
    // so it can take up enough space even when loading image
    return SizedBox(
      width: 32.0,
      height: 32.0,
      child: CachedNetworkImage(
        // user can have mulitples avatars, so we pick one of them randomly to display
        imageUrl: widget.user.avatars[post.index % widget.user.avatars.length],
        imageBuilder: (context, imageProvider) => CircleAvatar(
          radius: 16,
          backgroundImage: imageProvider,
        ),
        errorWidget: (context, url, error) => letterAvatar,
      ),
    );
  }

  Widget _buildUsername() {
    if (widget.user.id > 0) {
      return Text(
        widget.user.username,
        style: Theme.of(context).textTheme.subhead,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    } else {
      return Text(
        '#ANONYMOUS#',
        style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.grey),
      );
    }
  }

  Widget _buildMetaRow() {
    return Wrap(
      spacing: 4.0,
      alignment: WrapAlignment.center,
      children: [
        // edit icon
        if (post.editedAt != null)
          Icon(Icons.edit, color: Colors.grey, size: 16),

        // vendor icon
        if (post.vendor != null)
          Icon(
            VendorIcons.fromVendor(post.vendor),
            color: Colors.grey,
            size: 16.0,
          ),

        // post index
        if (post.index != 0)
          Text(
            '#${post.index}',
            style: Theme.of(context).textTheme.caption,
          ),

        // post send date in duration format, updated by minutes
        StreamBuilder<DateTime>(
          stream: Stream.periodic(const Duration(minutes: 1)),
          builder: (context, snapshot) => Text(
            duration(DateTime.now(), post.createdAt),
            style: Theme.of(context).textTheme.caption,
          ),
        ),
      ],
    );
  }

  Widget _buildMetaList() {
    List<ListTile> listChildren = [
      ListTile(
        dense: true,
        leading: const Icon(Icons.access_time),
        title: Text(AppLocalizations.of(context).createdAt),
        subtitle: Text(dateFormatter.format(post.createdAt)),
      ),
      if (post.editedAt != null)
        ListTile(
          dense: true,
          leading: const Icon(Icons.edit),
          title: Text(AppLocalizations.of(context).editedAt),
          subtitle: Text(dateFormatter.format(post.editedAt)),
        ),
      if (post.vendor != null) _buildVendorListTile(),
    ];

    return ListView.separated(
      shrinkWrap: true,
      separatorBuilder: (context, index) => const Divider(height: 0),
      itemCount: listChildren.length,
      itemBuilder: (context, index) => listChildren[index],
    );
  }

  ListTile _buildVendorListTile() {
    String title;
    switch (post.vendor) {
      case Vendor.android:
        title = AppLocalizations.of(context).sentFromAndroid;
        break;
      case Vendor.apple:
        title = AppLocalizations.of(context).sentFromApple;
        break;
      case Vendor.windows:
        title = AppLocalizations.of(context).sentFromWindows;
        break;
    }
    if (post.vendorDetail.isEmpty) {
      return ListTile(
        dense: true,
        leading: Icon(VendorIcons.fromVendor(post.vendor)),
        title: Text(title),
      );
    } else {
      return ListTile(
        dense: true,
        leading: Icon(VendorIcons.fromVendor(post.vendor)),
        title: Text(title),
        subtitle: Text(post.vendorDetail),
      );
    }
  }

  List<PopupMenuEntry<Choice>> _buildMenuItem(BuildContext context) {
    return [
      if (_displayMode != DisplayMode.bbCode)
        PopupMenuItem<Choice>(
          value: Choice.displayInBBCode,
          child: Text(
            AppLocalizations.of(context).displayInBBCode,
            style: Theme.of(context).textTheme.body1,
          ),
        ),
      if (_displayMode != DisplayMode.richText)
        PopupMenuItem<Choice>(
          value: Choice.dispalyInRichText,
          child: Text(
            AppLocalizations.of(context).dispalyInRichText,
            style: Theme.of(context).textTheme.body1,
          ),
        ),
      if (widget.sentByMe)
        PopupMenuItem<Choice>(
          value: Choice.editThisPost,
          child: Text(
            AppLocalizations.of(context).edit,
            style: Theme.of(context).textTheme.body1,
          ),
        ),
      PopupMenuItem<Choice>(
        value: Choice.replyToThisPost,
        child: Text(
          AppLocalizations.of(context).reply,
          style: Theme.of(context).textTheme.body1,
        ),
      ),
      PopupMenuItem<Choice>(
        value: Choice.quoteFromThisPost,
        child: Text(
          AppLocalizations.of(context).quote,
          style: Theme.of(context).textTheme.body1,
        ),
      ),
      PopupMenuItem<Choice>(
        value: Choice.commentOnThisPost,
        child: Text(
          AppLocalizations.of(context).comment,
          style: Theme.of(context).textTheme.body1,
        ),
      ),
    ];
  }

  _onMenuSelected(Choice choice) {
    switch (choice) {
      case Choice.displayInBBCode:
        setState(() => _displayMode = DisplayMode.bbCode);
        break;
      case Choice.dispalyInRichText:
        setState(() => _displayMode = DisplayMode.richText);
        break;
      case Choice.editThisPost:
        Navigator.pushNamed(context, '/e', arguments: {
          'action': actionModify,
          'topicId': post.topicId,
          'postId': post.id,
        });
        break;
      case Choice.replyToThisPost:
        Navigator.pushNamed(context, '/e', arguments: {
          'action': actionReply,
          'topicId': post.topicId,
          'postId': post.id,
        });
        break;
      case Choice.quoteFromThisPost:
        Navigator.pushNamed(context, '/e', arguments: {
          'action': actionQuote,
          'topicId': post.topicId,
          'postId': post.id,
        });
        break;
      case Choice.commentOnThisPost:
        Navigator.pushNamed(context, '/e', arguments: {
          'action': actionComment,
          'topicId': post.topicId,
          'postId': post.id,
        });
        break;
    }
  }

  Widget _buildSubject() {
    return Text(
      widget.post.subject,
      style: Theme.of(context).textTheme.subhead,
    );
  }

  Widget _buildContent() {
    switch (_displayMode) {
      case DisplayMode.bbCode:
        return Container(
          padding: EdgeInsets.only(bottom: 6.0),
          child: SelectableText(
            post.content.replaceAll('<br/>', '\n'),
          ),
        );
      case DisplayMode.richText:
        return BBCodeRender(
          raw: post.content,
          openUser: (userId) {
            showDialog(
              context: context,
              builder: (context) => UserDialog(userId),
            );
          },
          openLink: (url) {
            showDialog(
              context: context,
              builder: (context) => LinkDialog(url),
            );
          },
          openPost: (topicId, page, postId) {
            showDialog(
              context: context,
              builder: (context) => PostDialogConnector(
                topicId: topicId,
                postId: postId,
              ),
            );
          },
        );
    }
    return null;
  }

  Widget _buildFooter() {
    return Row(
      children: <Widget>[
        // attachments icon
        if (post.attachments.isNotEmpty)
          Padding(
            padding: EdgeInsets.all(8.0),
            child: InkResponse(
              child: Icon(
                Icons.attach_file,
                size: 16.0,
                color: Color.fromARGB(255, 144, 144, 144),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AttachViewer(post.attachments),
                  ),
                );
              },
            ),
          ),
        if (post.attachments.length > 1)
          Text(
            '${post.attachments.length}',
            style: Theme.of(context).textTheme.caption,
          ),
        if (post.commentIds.isNotEmpty)
          Padding(
            padding: EdgeInsets.all(8.0),
            child: InkResponse(
              child: Icon(
                Icons.comment,
                size: 16,
                color: Color.fromARGB(255, 144, 144, 144),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AttachViewer(post.attachments),
                  ),
                );
              },
            ),
          ),
        if (post.commentIds.length > 1)
          Text(
            '${post.commentIds.length}',
            style: Theme.of(context).textTheme.caption,
          ),
        const Spacer(),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: InkResponse(
            child: Icon(
              Icons.thumb_up,
              size: 16.0,
              color: Color.fromARGB(255, 144, 144, 144),
            ),
            onTap: () => widget.upvote(),
          ),
        ),
        if (post.vote > 0)
          Text(
            post.vote.toString(),
            style: Theme.of(context).textTheme.caption,
          ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: InkResponse(
            child: Icon(
              Icons.thumb_down,
              size: 16.0,
              color: Color.fromARGB(255, 144, 144, 144),
            ),
            onTap: () => widget.downvote(),
          ),
        ),
      ],
    );
  }

  // void openLink(String url) {
  //   if (url.startsWith('/read.php?') ||
  //       url.startsWith('http://nga.178.com/read.php?') ||
  //       url.startsWith('https://nga.178.com/read.php?') ||
  //       url.startsWith('http://bbs.ngacn.cc/read.php?') ||
  //       url.startsWith('https://bbs.ngacn.cc/read.php?') ||
  //       url.startsWith('http://bbs.nga.cn/read.php?') ||
  //       url.startsWith('https://bbs.nga.cn/read.php?') ||
  //       url.startsWith('http://nga.donews.com/read.php?') ||
  //       url.startsWith('https://nga.donews.com/read.php?')) {
  // try {
  //   final int topicId = int.parse(Uri.parse(url).queryParameters['tid']);
  //   Navigator.pushNamed(context, '/t', arguments: {'topicId': topicId});
  // } catch (_) {
  //   Scaffold.of(context).showSnackBar(SnackBar(
  //     content: Text('Can't open this link.'),
  //   ));
  // }
  // } else if (url.startsWith('/thread.php?') ||
  //     url.startsWith('http://nga.178.com/thread.php?') ||
  //     url.startsWith('https://nga.178.com/thread.php?') ||
  //     url.startsWith('http://bbs.ngacn.cc/thread.php?') ||
  //     url.startsWith('https://bbs.ngacn.cc/thread.php?') ||
  //     url.startsWith('http://nga.donews.com/thread.php?') ||
  //     url.startsWith('https://bbs.nga.cn/thread.php?') ||
  //     url.startsWith('http://bbs.nga.cn/thread.php?') ||
  //     url.startsWith('https://nga.donews.com/thread.php?')) {
  // try {
  //   final int categoryId = int.parse(Uri.parse(url).queryParameters['fid']);
  //   if (categoryIds.contains(categoryId)) {
  //     Navigator.pushNamed(
  //       context,
  //       '/c',
  //       arguments: {'categoryId': categoryId},
  //     );
  //   } else {
  //     Scaffold.of(context).showSnackBar(SnackBar(
  //       content: Text('Can't open this link.'),
  //     ));
  //   }
  // } catch (_) {
  //   Scaffold.of(context).showSnackBar(SnackBar(
  //     content: Text('Can't open this link.'),
  //   ));
  // }
  // }

  //   showDialog(
  //     context: context,
  //     builder: (context) => LinkDialog(url),
  //   );
  // }
}

class PostRowConnector extends StatelessWidget {
  final PostItem post;
  final User user;

  const PostRowConnector({
    Key key,
    @required this.post,
    @required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ViewModel>(
      model: ViewModel(
        postId: post.id,
        userId: post.inner.userId,
        topicId: post.inner.topicId,
      ),
      builder: (context, vm) => PostRow(
        post: post,
        user: user,
        sentByMe: vm.sentByMe,
        upvote: vm.upvote,
        downvote: vm.downvote,
      ),
    );
  }
}

class ViewModel extends BaseModel<AppState> {
  final int postId;
  final int userId;
  final int topicId;

  bool sentByMe;

  Future<void> Function() upvote;
  Future<void> Function() downvote;

  ViewModel({
    @required this.postId,
    @required this.userId,
    @required this.topicId,
  });

  ViewModel.build({
    @required this.postId,
    @required this.topicId,
    @required this.userId,
    @required this.upvote,
    @required this.downvote,
    @required this.sentByMe,
  });

  @override
  ViewModel fromStore() {
    return ViewModel.build(
      postId: postId,
      topicId: topicId,
      userId: userId,
      sentByMe: state.userState.isMe(userId),
      upvote: () => dispatchFuture(
        UpvotePostAction(
          topicId: topicId,
          postId: postId,
        ),
      ),
      downvote: () => dispatchFuture(
        DownvotePostAction(
          topicId: topicId,
          postId: postId,
        ),
      ),
    );
  }
}

enum Choice {
  displayInBBCode,
  dispalyInRichText,
  editThisPost,
  replyToThisPost,
  quoteFromThisPost,
  commentOnThisPost,
}

enum DisplayMode {
  bbCode,
  richText,
}
