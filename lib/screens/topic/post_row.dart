import 'package:async_redux/async_redux.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ngnga/bbcode/render.dart';
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
  final Post post;
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          if (widget.post.subject.isNotEmpty && widget.post.index != 0)
            _buildSubject(),
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
          _buildAvatar(),
          Container(width: 8.0),
          Expanded(child: _buildUsername()),
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
        imageUrl:
            widget.user.avatars[widget.post.index % widget.user.avatars.length],
        imageBuilder: (context, imageProvider) => CircleAvatar(
          radius: 16,
          backgroundImage: imageProvider,
        ),
        errorWidget: (context, url, error) => letterAvatar,
      ),
    );
  }

  Widget _buildUsername() {
    return Row(
      children: <Widget>[
        if (widget.user.id > 0)
          Expanded(
            child: Text(
              widget.user.username,
              style: Theme.of(context).textTheme.subhead,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        if (widget.user.id == 0)
          Text(
            '#ANONYMOUS#',
            style: Theme.of(context)
                .textTheme
                .subhead
                .copyWith(color: Colors.grey),
          ),
        if (widget.post.commentTo != null)
          Padding(
            padding: EdgeInsets.all(8.0),
            child: InkResponse(
              child: Icon(
                Icons.comment,
                size: 16.0,
                color: Color.fromARGB(255, 144, 144, 144),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMetaRow() {
    return Row(
      children: [
        // edit icon
        if (widget.post.editedAt != null)
          Icon(Icons.edit, color: Colors.grey, size: 16),
        if (widget.post.editedAt != null)
          Container(width: 4),

        // vendor icon
        if (widget.post.vendor != null)
          Icon(
            VendorIcons.fromVendor(widget.post.vendor),
            color: Colors.grey,
            size: 16.0,
          ),
        if (widget.post.vendor != null)
          Container(width: 4),

        // post index
        if (widget.post.index != 0)
          Text(
            '#${widget.post.index}',
            style: Theme.of(context).textTheme.caption,
          ),
        if (widget.post.index != 0)
          Container(width: 4),

        // post send date in duration format, updated by minutes
        StreamBuilder<DateTime>(
          stream: Stream.periodic(const Duration(minutes: 1)),
          builder: (context, snapshot) => Text(
            duration(DateTime.now(), widget.post.createdAt),
            style: Theme.of(context).textTheme.caption,
          ),
        ),
      ],
    );
  }

  Widget _buildMetaList() {
    List<ListTile> listChildren = [
      if (widget.post.index != 0)
        ListTile(
          dense: true,
          leading: const Icon(Icons.info),
          title: Text('第 ${widget.post.index} 楼'),
        ),
      ListTile(
        dense: true,
        leading: const Icon(Icons.access_time),
        title: Text('创建时间'),
        subtitle: Text(dateFormatter.format(widget.post.createdAt)),
      ),
      if (widget.post.editedAt != null)
        ListTile(
          dense: true,
          leading: const Icon(Icons.edit),
          title: Text('编辑时间'),
          subtitle: Text(dateFormatter.format(widget.post.editedAt)),
        ),
      if (widget.post.vendor != null) _buildVendorListTile(),
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
    switch (widget.post.vendor) {
      case Vendor.android:
        title = '发送自 Android 客户端';
        break;
      case Vendor.apple:
        title = '发送自 iOS 客户端';
        break;
      case Vendor.windows:
        title = '发送自 Windows Phone 客户端';
        break;
    }
    if (widget.post.vendorDetail.isEmpty) {
      return ListTile(
        dense: true,
        leading: Icon(VendorIcons.fromVendor(widget.post.vendor)),
        title: Text(title),
      );
    } else {
      return ListTile(
        dense: true,
        leading: Icon(VendorIcons.fromVendor(widget.post.vendor)),
        title: Text(title),
        subtitle: Text(widget.post.vendorDetail),
      );
    }
  }

  List<PopupMenuEntry<Choice>> _buildMenuItem(BuildContext context) {
    return [
      if (_displayMode != DisplayMode.bbCode)
        PopupMenuItem<Choice>(
          value: Choice.displayInBBCode,
          child: Text(
            'Display in BBCode',
            style: Theme.of(context).textTheme.body1,
          ),
        ),
      if (_displayMode != DisplayMode.richText)
        PopupMenuItem<Choice>(
          value: Choice.dispalyInRichText,
          child: Text(
            'Display in RichText',
            style: Theme.of(context).textTheme.body1,
          ),
        ),
      if (widget.sentByMe)
        PopupMenuItem<Choice>(
          value: Choice.editThisPost,
          child: Text(
            'Edit This Post',
            style: Theme.of(context).textTheme.body1,
          ),
        ),
      PopupMenuItem<Choice>(
        value: Choice.replyToThisPost,
        child: Text(
          'Reply To This Post',
          style: Theme.of(context).textTheme.body1,
        ),
      ),
      PopupMenuItem<Choice>(
        value: Choice.quoteFromThisPost,
        child: Text(
          'Quote From This Post',
          style: Theme.of(context).textTheme.body1,
        ),
      ),
      PopupMenuItem<Choice>(
        value: Choice.commentOnThisPost,
        child: Text(
          'Comment On This Post',
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
          'topicId': widget.post.topicId,
          'postId': widget.post.id,
        });
        break;
      case Choice.replyToThisPost:
        Navigator.pushNamed(context, '/e', arguments: {
          'action': actionReply,
          'topicId': widget.post.topicId,
          'postId': widget.post.id,
        });
        break;
      case Choice.quoteFromThisPost:
        Navigator.pushNamed(context, '/e', arguments: {
          'action': actionQuote,
          'topicId': widget.post.topicId,
          'postId': widget.post.id,
        });
        break;
      case Choice.commentOnThisPost:
        Navigator.pushNamed(context, '/e', arguments: {
          'action': actionComment,
          'topicId': widget.post.topicId,
          'postId': widget.post.id,
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
            widget.post.content.replaceAll('<br/>', '\n'),
          ),
        );
      case DisplayMode.richText:
        return BBCodeRender(
          raw: widget.post.content,
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
        if (widget.post.attachments.isNotEmpty)
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
                    builder: (context) => AttachViewer(widget.post.attachments),
                  ),
                );
              },
            ),
          ),
        if (widget.post.attachments.length > 1)
          Text(
            '${widget.post.attachments.length}',
            style: Theme.of(context).textTheme.caption,
          ),
        if (widget.post.commentIds.isNotEmpty)
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
                    builder: (context) => AttachViewer(widget.post.attachments),
                  ),
                );
              },
            ),
          ),
        if (widget.post.commentIds.length > 1)
          Text(
            '${widget.post.commentIds.length}',
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
        if (widget.post.vote > 0)
          Text(
            widget.post.vote.toString(),
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
  final Post post;
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
        userId: post.userId,
        topicId: post.topicId,
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
