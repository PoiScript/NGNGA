import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

import '../../models/post.dart';
import '../../widgets/bbcode.dart';
import '../../utils/duration_to_now.dart';
import '../../models/user.dart';

class PostRow extends StatefulWidget {
  final Post post;
  final User user;

  PostRow(this.post, this.user);

  @override
  _PostRowState createState() => _PostRowState();
}

class _PostRowState extends State<PostRow> {
  DisplayMode _displayMode = DisplayMode.richText;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          left: 8.0,
          top: 8.0,
          child: widget.user.avatars.isNotEmpty
              ? CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(widget.user.avatars[0]),
                )
              : CircleAvatar(
                  radius: 16,
                  child: Text(widget.user.username[0].toUpperCase()),
                ),
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
                      PopupMenuItem<Choice>(
                        value: Choice.displayInBBCode,
                        child: Text(
                          "Display in BBCode",
                          style: Theme.of(context).textTheme.body1,
                        ),
                      ),
                      PopupMenuItem<Choice>(
                        value: Choice.dispalyRichText,
                        child: Text(
                          "Display in RichText",
                          style: Theme.of(context).textTheme.body1,
                        ),
                      ),
                    ],
                    onSelected: _onMenuSelected,
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.only(
                  top: 8.0,
                  bottom: 8.0,
                ),
                child: _buildContent(),
              ),
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

  _onMenuSelected(Choice choice) {
    switch (choice) {
      case Choice.displayInBBCode:
        setState(() {
          _displayMode = DisplayMode.bbCode;
        });
        break;
      case Choice.dispalyRichText:
        setState(() {
          _displayMode = DisplayMode.richText;
        });
        break;
    }
  }

  Widget _buildContent() {
    var content;
    switch (_displayMode) {
      case DisplayMode.bbCode:
        content = SelectableText(widget.post.content);
        break;
      case DisplayMode.richText:
        content = BBCode(widget.post.content);
        break;
    }
    return content;
  }
}

enum Choice {
  displayInBBCode,
  dispalyRichText,
}

enum DisplayMode {
  bbCode,
  richText,
}
