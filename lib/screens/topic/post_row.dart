import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:intl/intl.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

import 'package:ngnga/bbcode/render.dart';
import 'package:ngnga/models/post.dart';
import 'package:ngnga/models/user.dart';
import 'package:ngnga/utils/duration.dart';
import 'package:ngnga/utils/vendor_icons.dart';
import 'package:ngnga/widgets/link_dialog.dart';
import 'package:ngnga/widgets/post_dialog.dart';
import 'package:ngnga/widgets/user_dialog.dart';

import 'attach_viewer.dart';

final dateFormatter = DateFormat("yyyy-MM-dd HH:mm:ss");

class PostRow extends StatefulWidget {
  final Post post;
  final User user;
  final Stream<DateTime> everyMinutes;

  PostRow(this.post, this.user, this.everyMinutes)
      : assert(post != null),
        assert(user != null),
        assert(everyMinutes != null);

  @override
  _PostRowState createState() => _PostRowState();
}

class _PostRowState extends State<PostRow> {
  DisplayMode _displayMode = DisplayMode.RichText;

  @override
  Widget build(BuildContext context) {
    if (widget.post.isComment) {
      return SliverStickyHeader(
        overlapsContent: true,
        header: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: _buildAvatar(context),
          ),
        ),
        sliver: SliverPadding(
          padding: EdgeInsets.fromLTRB(48.0, 8.0, 8.0, 0.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              [
                Text(
                  widget.user.id > 0 ? widget.user.username : '匿名',
                  style: Theme.of(context).textTheme.subhead.copyWith(
                      color: widget.user.id <= 0 ? Colors.grey : null),
                ),
                ...widget.post.subject != null && widget.post.subject.isNotEmpty
                    ? [
                        Text(
                          widget.post.subject,
                          style: Theme.of(context).textTheme.subhead,
                        )
                      ]
                    : [],
                const Divider(),
              ],
            ),
          ),
        ),
      );
    }

    return SliverStickyHeader(
      overlapsContent: true,
      header: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: _buildAvatar(context),
        ),
      ),
      sliver: SliverPadding(
        padding: EdgeInsets.fromLTRB(48.0, 8.0, 8.0, 0.0),
        sliver: SliverList(
          delegate: SliverChildListDelegate(
            [
              Container(
                margin: EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Text(
                      widget.user.id > 0 ? widget.user.username : '匿名',
                      style: Theme.of(context).textTheme.subhead.copyWith(
                          color: widget.user.id <= 0 ? Colors.grey : null),
                    ),
                    const Spacer(),
                    _buildMetadata(context),
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
              ),
              ...widget.post.subject != null && widget.post.subject.isNotEmpty
                  ? [
                      Text(
                        widget.post.subject,
                        style: Theme.of(context).textTheme.subhead,
                      )
                    ]
                  : [],
              _buildContent(),
              Row(
                children: <Widget>[
                  const Spacer(),
                  const Icon(
                    Icons.thumb_up,
                    color: Colors.grey,
                    size: 20.0,
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
                  const Icon(
                    Icons.thumb_down,
                    color: Colors.grey,
                    size: 20.0,
                  ),
                ],
              ),
              const Divider(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final letterAvatar = CircleAvatar(
      radius: 16,
      child: Text(
        widget.user.username[0].toUpperCase(),
        style: Theme.of(context).textTheme.body2.copyWith(color: Colors.white),
      ),
      backgroundColor: numberToHslColor(widget.user.id),
    );

    if (widget.user.avatars.isEmpty) return letterAvatar;

    return CachedNetworkImage(
      // user can have mulitples avatars, so we randomly pick one of them to display
      imageUrl:
          widget.user.avatars[widget.post.index % widget.user.avatars.length],
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: 16,
        backgroundImage: imageProvider,
      ),
      errorWidget: (context, url, error) => letterAvatar,
    );
  }

  Widget _buildMetadata(BuildContext context) {
    // edit icon, client icon, post index, post date
    List<Widget> rowChildren = [];

    if (widget.post.attachments.isNotEmpty) {
      rowChildren.add(Icon(
        Icons.attach_file,
        color: Colors.grey,
        size: 16.0,
      ));
      rowChildren.add(
        Text(
          widget.post.attachments.length.toString(),
          style: Theme.of(context).textTheme.caption,
        ),
      );
      rowChildren.add(Container(width: 4));
    }

    if (widget.post.editedAt != null) {
      rowChildren.add(Icon(
        Icons.edit,
        color: Colors.grey,
        size: 16.0,
      ));
      rowChildren.add(Container(width: 4));
    }

    if (widget.post.client != null) {
      switch (widget.post.client) {
        case Client.Android:
          rowChildren.add(Icon(
            VendorIcons.android,
            color: Colors.grey,
            size: 16.0,
          ));
          break;
        case Client.Apple:
          rowChildren.add(Icon(
            VendorIcons.apple,
            color: Colors.grey,
            size: 16.0,
          ));
          break;
        case Client.Windows:
          rowChildren.add(Icon(
            VendorIcons.windows,
            color: Colors.grey,
            size: 16.0,
          ));
          break;
      }
      rowChildren.add(Container(width: 4));
    }

    rowChildren.add(Text(
      "#${widget.post.index}",
      style: Theme.of(context).textTheme.caption,
    ));

    rowChildren.add(Container(width: 4));

    rowChildren.add(
      StreamBuilder<DateTime>(
        initialData: DateTime.now(),
        stream: widget.everyMinutes,
        builder: (context, snapshot) => Text(
          duration(snapshot.data, widget.post.createdAt),
          style: Theme.of(context).textTheme.caption,
        ),
      ),
    );

    // post date, client detail, edited data, actions
    List<ListTile> listChildren = [];

    listChildren.add(ListTile(
      dense: true,
      leading: const Icon(
        Icons.access_time,
        color: Colors.grey,
        size: 20.0,
      ),
      title: Text('创建时间'),
      subtitle: Text(dateFormatter.format(widget.post.createdAt)),
    ));

    if (widget.post.editedAt != null) {
      listChildren.add(ListTile(
        dense: true,
        leading: const Icon(
          Icons.edit,
          color: Colors.grey,
          size: 20.0,
        ),
        title: Text('编辑时间'),
        subtitle: Text(dateFormatter.format(widget.post.editedAt)),
      ));
    }

    if (widget.post.client != null) {
      Icon icon;
      String title;
      switch (widget.post.client) {
        case Client.Android:
          icon = Icon(VendorIcons.android);
          title = "发送自 Android 客户端";
          break;
        case Client.Apple:
          icon = Icon(VendorIcons.apple);
          title = "发送自 iOS 客户端";
          break;
        case Client.Windows:
          icon = Icon(VendorIcons.windows);
          title = "发送自 Windows Phone 客户端";
          break;
      }
      listChildren.add(ListTile(
        dense: true,
        leading: icon,
        title: Text(title),
        subtitle: widget.post.clientDetail.isNotEmpty
            ? Text(widget.post.clientDetail)
            : null,
      ));
    }

    if (widget.post.attachments.isNotEmpty) {
      listChildren.add(ListTile(
        dense: true,
        leading: Icon(Icons.attach_file),
        title: Text("附件"),
        subtitle: Text("${widget.post.attachments.length} 张附件"),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AttachViewer(widget.post.attachments)),
          );
        },
      ));
    }

    return GestureDetector(
      child: Row(children: rowChildren),
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              child: ListView.separated(
                shrinkWrap: true,
                separatorBuilder: (context, index) => const Divider(height: 0),
                itemCount: listChildren.length,
                itemBuilder: (context, index) => listChildren[index],
              ),
            );
          },
        );
      },
    );
  }

  List<PopupMenuEntry<Choice>> _buildMenuItem(BuildContext context) {
    List<PopupMenuEntry<Choice>> entries = [];

    if (_displayMode != DisplayMode.BBCode) {
      entries.add(PopupMenuItem<Choice>(
        value: Choice.DisplayInBBCode,
        child: Text(
          "Display in BBCode",
          style: Theme.of(context).textTheme.body1,
        ),
      ));
    }

    if (_displayMode != DisplayMode.RichText) {
      entries.add(PopupMenuItem<Choice>(
        value: Choice.DispalyRichText,
        child: Text(
          "Display in RichText",
          style: Theme.of(context).textTheme.body1,
        ),
      ));
    }

    return entries;
  }

  Color numberToHslColor(int number) {
    var hash = 0;

    for (var rune in number.toString().runes) {
      hash = rune + ((hash << 5) - hash);
    }

    var h = hash % 360;

    return HSLColor.fromAHSL(1.0, h.toDouble(), 0.3, 0.8).toColor();
  }

  _onMenuSelected(Choice choice) {
    switch (choice) {
      case Choice.DisplayInBBCode:
        setState(() {
          _displayMode = DisplayMode.BBCode;
        });
        break;
      case Choice.DispalyRichText:
        setState(() {
          _displayMode = DisplayMode.RichText;
        });
        break;
    }
  }

  Widget _buildContent() {
    var content;
    switch (_displayMode) {
      case DisplayMode.BBCode:
        content = SelectableText(
          widget.post.content.replaceAll("<br/>", "\n"),
        );
        break;
      case DisplayMode.RichText:
        content = BBCodeRender(
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
        break;
    }
    return content;
  }
}

enum Choice {
  DisplayInBBCode,
  DispalyRichText,
}

enum DisplayMode {
  BBCode,
  RichText,
}
