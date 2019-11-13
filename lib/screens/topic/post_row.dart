import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

import 'package:ngnga/bbcode/render.dart';
import 'package:ngnga/models/post.dart';
import 'package:ngnga/models/user.dart';
import 'package:ngnga/utils/duration_to_now.dart';
import 'package:ngnga/widgets/link_dialog.dart';
import 'package:ngnga/widgets/post_dialog.dart';
import 'package:ngnga/widgets/user_dialog.dart';

class PostRow extends StatefulWidget {
  final Post post;
  final User user;

  PostRow(this.post, this.user)
      : assert(post != null),
        assert(user != null);

  @override
  _PostRowState createState() => _PostRowState();
}

class _PostRowState extends State<PostRow> {
  DisplayMode _displayMode = DisplayMode.RichText;

  @override
  Widget build(BuildContext context) {
    var letterAvatar = CircleAvatar(
      radius: 16,
      child: Text(
        widget.user.username[0].toUpperCase(),
        style: Theme.of(context).textTheme.body2.copyWith(color: Colors.white),
      ),
      backgroundColor: numberToHslColor(widget.user.id),
    );

    return Stack(
      children: <Widget>[
        Positioned(
          left: 8.0,
          top: 8.0,
          child: widget.user.avatars.isNotEmpty
              ? CachedNetworkImage(
                  // user can have mulitples avatars, so we randomly pick one of them to display
                  imageUrl: widget.user
                      .avatars[widget.post.index % widget.user.avatars.length],
                  imageBuilder: (context, imageProvider) => CircleAvatar(
                    radius: 16,
                    backgroundImage: imageProvider,
                  ),
                  placeholder: (context, url) => letterAvatar,
                  errorWidget: (context, url, error) => letterAvatar,
                )
              : letterAvatar,
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(48.0, 8.0, 8.0, 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    widget.user.username,
                    style: Theme.of(context).textTheme.subhead,
                  ),
                  const Spacer(),
                  Text(
                    "#${widget.post.index} ${durationToNow(widget.post.createdAt)}",
                    style: Theme.of(context).textTheme.caption,
                  ),
                  PopupMenuButton<Choice>(
                    child: const Icon(
                      Icons.more_vert,
                      color: Colors.grey,
                      size: 20.0,
                    ),
                    itemBuilder: (context) => [
                      _displayMode != DisplayMode.BBCode
                          ? PopupMenuItem<Choice>(
                              value: Choice.DisplayInBBCode,
                              child: Text(
                                "Display in BBCode",
                                style: Theme.of(context).textTheme.body1,
                              ),
                            )
                          : null,
                      _displayMode != DisplayMode.RichText
                          ? PopupMenuItem<Choice>(
                              value: Choice.DispalyRichText,
                              child: Text(
                                "Display in RichText",
                                style: Theme.of(context).textTheme.body1,
                              ),
                            )
                          : null,
                    ]..removeWhere((item) => item == null),
                    onSelected: _onMenuSelected,
                  ),
                ],
              ),
              _buildContent(),
              Row(
                children: <Widget>[
                  const Spacer(),
                  const Icon(
                    OMIcons.thumbUp,
                    color: Colors.grey,
                    size: 20.0,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      widget.post.upVote - widget.post.downVote > 0
                          ? (widget.post.upVote - widget.post.downVote)
                              .toString()
                          : "",
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ),
                  const Icon(
                    OMIcons.thumbDown,
                    color: Colors.grey,
                    size: 20.0,
                  ),
                  const Icon(
                    OMIcons.reply,
                    color: Colors.grey,
                    size: 20.0,
                  ),
                ],
              )
            ],
          ),
        )
      ],
    );
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
        content = SelectableText(widget.post.content);
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
