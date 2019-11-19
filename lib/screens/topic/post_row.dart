import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ngnga/bbcode/render.dart';
import 'package:ngnga/models/post.dart';
import 'package:ngnga/models/user.dart';
import 'package:ngnga/screens/editor/editor.dart';
import 'package:ngnga/utils/duration.dart';
import 'package:ngnga/utils/number_to_hsl_color.dart';
import 'package:ngnga/utils/vendor_icons.dart';
import 'package:ngnga/widgets/link_dialog.dart';
import 'package:ngnga/widgets/post_dialog.dart';
import 'package:ngnga/widgets/user_dialog.dart';

import 'attach_viewer.dart';

final dateFormatter = DateFormat("yyyy-MM-dd HH:mm:ss");

class PostRow extends StatefulWidget {
  final Post post;
  final User user;
  final int topicId;
  final Stream<DateTime> everyMinutes;

  final Future<void> Function() upvote;
  final Future<void> Function() downvote;

  PostRow({
    @required this.post,
    @required this.user,
    @required this.topicId,
    @required this.upvote,
    @required this.downvote,
    @required this.everyMinutes,
  })  : assert(post != null),
        assert(user != null),
        assert(topicId != null),
        assert(upvote != null),
        assert(downvote != null),
        assert(everyMinutes != null);

  @override
  _PostRowState createState() => _PostRowState();
}

class _PostRowState extends State<PostRow> {
  DisplayMode _displayMode = DisplayMode.RichText;

  @override
  Widget build(BuildContext context) {
    List<Widget> children;

    if (widget.post.isComment) {
      children = [
        Container(
          margin: EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              _buildAvatar(),
              Container(width: 8.0),
              _buildUsername(),
            ],
          ),
        ),
        if (widget.post.subject.isNotEmpty && widget.post.index != 0)
          _buildSubject(),
      ];
    } else {
      children = [
        _buildHeader(),
        if (widget.post.subject.isNotEmpty && widget.post.index != 0)
          _buildSubject(),
        _buildContent(),
        _buildFooter(),
      ];
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
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
          _buildUsername(),
          const Spacer(),
          GestureDetector(
            child: _buildMetaRow(),
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => _buildMetaList(),
              );
            },
          ),
          PopupMenuButton<Choice>(
            child: const Icon(
              Icons.more_vert,
              color: Colors.grey,
              size: 20.0,
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
      backgroundColor: numberToHslColor(widget.user.id),
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
    TextStyle subhead = Theme.of(context).textTheme.subhead;

    return widget.user.id > 0
        ? Text(widget.user.username, style: subhead)
        : Text('匿名', style: subhead.copyWith(color: Colors.grey));
  }

  Widget _buildMetaRow() {
    return Row(
      children: [
        // attachments icon
        if (widget.post.attachments.isNotEmpty)
          Icon(Icons.attach_file, color: Colors.grey, size: 16),
        if (widget.post.attachments.length > 1)
          Text(
            "${widget.post.attachments.length}",
            style: Theme.of(context).textTheme.caption,
          ),
        if (widget.post.attachments.isNotEmpty)
          Container(width: 4),

        // edit icon
        if (widget.post.editedAt != null)
          Icon(Icons.edit, color: Colors.grey, size: 16),
        if (widget.post.editedAt != null)
          Container(width: 4),

        // vendor icon
        if (widget.post.client != null)
          Icon(
            VendorIcons.fromClient(widget.post.client),
            color: Colors.grey,
            size: 16.0,
          ),
        if (widget.post.client != null)
          Container(width: 4),

        // post index
        if (widget.post.index != 0)
          Text(
            "#${widget.post.index}",
            style: Theme.of(context).textTheme.caption,
          ),
        if (widget.post.index != 0)
          Container(width: 4),

        // post send date in duration format, updated by minutes
        StreamBuilder<DateTime>(
          initialData: DateTime.now(),
          stream: widget.everyMinutes,
          builder: (context, snapshot) => Text(
            duration(snapshot.data, widget.post.createdAt),
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
      if (widget.post.client != null) _buildVendorListTile(),
      if (widget.post.attachments.isNotEmpty)
        ListTile(
          dense: true,
          leading: Icon(Icons.attach_file),
          title: Text("共 ${widget.post.attachments.length} 张附件"),
          trailing: Icon(Icons.keyboard_arrow_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AttachViewer(widget.post.attachments),
              ),
            );
          },
        ),
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
    switch (widget.post.client) {
      case Client.Android:
        title = "发送自 Android 客户端";
        break;
      case Client.Apple:
        title = "发送自 iOS 客户端";
        break;
      case Client.Windows:
        title = "发送自 Windows Phone 客户端";
        break;
    }
    if (widget.post.clientDetail.isEmpty) {
      return ListTile(
        dense: true,
        leading: Icon(VendorIcons.fromClient(widget.post.client)),
        title: Text(title),
      );
    } else {
      return ListTile(
        dense: true,
        leading: Icon(VendorIcons.fromClient(widget.post.client)),
        title: Text(title),
        subtitle: Text(widget.post.clientDetail),
      );
    }
  }

  List<PopupMenuEntry<Choice>> _buildMenuItem(BuildContext context) {
    return [
      if (_displayMode != DisplayMode.BBCode)
        PopupMenuItem<Choice>(
          value: Choice.DisplayInBBCode,
          child: Text(
            "Display in BBCode",
            style: Theme.of(context).textTheme.body1,
          ),
        ),
      if (_displayMode != DisplayMode.RichText)
        PopupMenuItem<Choice>(
          value: Choice.DispalyInRichText,
          child: Text(
            "Display in RichText",
            style: Theme.of(context).textTheme.body1,
          ),
        ),
      PopupMenuItem<Choice>(
        value: Choice.ReplyToThisPost,
        child: Text(
          "Reply To This Post",
          style: Theme.of(context).textTheme.body1,
        ),
      ),
      PopupMenuItem<Choice>(
        value: Choice.QuoteFromThisPost,
        child: Text(
          "Quote From This Post",
          style: Theme.of(context).textTheme.body1,
        ),
      ),
      PopupMenuItem<Choice>(
        value: Choice.CommentOnThisPost,
        child: Text(
          "Comment On This Post",
          style: Theme.of(context).textTheme.body1,
        ),
      ),
    ];
  }

  _onMenuSelected(Choice choice) {
    switch (choice) {
      case Choice.DisplayInBBCode:
        setState(() {
          _displayMode = DisplayMode.BBCode;
        });
        break;
      case Choice.DispalyInRichText:
        setState(() {
          _displayMode = DisplayMode.RichText;
        });
        break;
      case Choice.ReplyToThisPost:
        Navigator.pushNamed(context, "/e", arguments: {
          "action": ACTION_REPLY,
          "topicId": widget.topicId,
          "postId": widget.post.id,
        });
        break;
      case Choice.QuoteFromThisPost:
        Navigator.pushNamed(context, "/e", arguments: {
          "action": ACTION_QUOTE,
          "topicId": widget.topicId,
          "postId": widget.post.id,
        });
        break;
      case Choice.CommentOnThisPost:
        Navigator.pushNamed(context, "/e", arguments: {
          "action": ACTION_COMMENT,
          "topicId": widget.topicId,
          "postId": widget.post.id,
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
      case DisplayMode.BBCode:
        return Container(
          padding: EdgeInsets.only(bottom: 6.0),
          child: SelectableText(
            widget.post.content.replaceAll("<br/>", "\n"),
          ),
        );
      case DisplayMode.RichText:
        return BBCodeRender(
          data: widget.post.content,
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
              builder: (context) =>
                  PostDialogConnector(topicId: topicId, postId: postId),
            );
          },
        );
    }
    return null;
  }

  Widget _buildFooter() {
    return Row(
      children: <Widget>[
        const Spacer(),
        InkResponse(
          child: Icon(
            Icons.thumb_up,
            size: 16.0,
            color: Colors.grey,
          ),
          onTap: () => widget.upvote(),
        ),
        widget.post.upVote > 0
            ? Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  widget.post.upVote.toString(),
                  style: Theme.of(context).textTheme.caption,
                ),
              )
            : Container(width: 8.0),
        InkResponse(
          child: Icon(
            Icons.thumb_down,
            size: 16.0,
            color: Colors.grey,
          ),
          onTap: () => widget.downvote(),
        ),
        Container(width: 8)
      ],
    );
  }

  void openLink(String url) {
    if (url.startsWith("/read.php?") ||
        url.startsWith("http://nga.178.com/read.php?") ||
        url.startsWith("https://nga.178.com/read.php?") ||
        url.startsWith("http://bbs.ngacn.cc/read.php?") ||
        url.startsWith("https://bbs.ngacn.cc/read.php?") ||
        url.startsWith("http://bbs.nga.cn/read.php?") ||
        url.startsWith("https://bbs.nga.cn/read.php?") ||
        url.startsWith("http://nga.donews.com/read.php?") ||
        url.startsWith("https://nga.donews.com/read.php?")) {
      // TODO: internal jumping
    } else if (url.startsWith("/thread.php?") ||
        url.startsWith("http://nga.178.com/thread.php?") ||
        url.startsWith("https://nga.178.com/thread.php?") ||
        url.startsWith("http://bbs.ngacn.cc/thread.php?") ||
        url.startsWith("https://bbs.ngacn.cc/thread.php?") ||
        url.startsWith("http://nga.donews.com/thread.php?") ||
        url.startsWith("https://bbs.nga.cn/thread.php?") ||
        url.startsWith("http://bbs.nga.cn/thread.php?") ||
        url.startsWith("https://nga.donews.com/thread.php?")) {
      // TODO: internal jumping
    }

    showDialog(
      context: context,
      builder: (context) => LinkDialog(url),
    );
  }
}

enum Choice {
  DisplayInBBCode,
  DispalyInRichText,
  ReplyToThisPost,
  QuoteFromThisPost,
  CommentOnThisPost,
}

enum DisplayMode {
  BBCode,
  RichText,
}
