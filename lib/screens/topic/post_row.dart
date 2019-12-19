import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:ngnga/bbcode/render.dart';
import 'package:ngnga/localizations.dart';
import 'package:ngnga/models/attachment.dart';
import 'package:ngnga/models/post.dart';
import 'package:ngnga/models/user.dart';
import 'package:ngnga/screens/editor/editor.dart';
import 'package:ngnga/utils/open_link.dart';
import 'package:ngnga/utils/vendor_icons.dart';
import 'package:ngnga/widgets/distance_to_now.dart';
import 'package:ngnga/widgets/user_avatar.dart';

final _dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');

enum DisplayMode {
  bbCode,
  richText,
}

class PostRow extends StatefulWidget {
  final Post post;
  final User user;
  final bool sentByMe;
  final String baseUrl;

  final Future<void> Function() upvote;
  final Future<void> Function() downvote;

  final Function(int, int) openPost;
  final Function(BuiltList<Attachment>) openAttachmentSheet;
  final Function(BuiltList<int>) openCommentSheet;
  final Function(BuiltList<int>) openTopReplySheet;

  const PostRow({
    @required this.post,
    @required this.user,
    @required this.sentByMe,
    @required this.baseUrl,
    @required this.upvote,
    @required this.downvote,
    @required this.openPost,
    @required this.openAttachmentSheet,
    @required this.openCommentSheet,
    @required this.openTopReplySheet,
  })  : assert(post != null),
        assert(user != null),
        assert(sentByMe != null),
        assert(upvote != null),
        assert(downvote != null),
        assert(openAttachmentSheet != null),
        assert(openCommentSheet != null),
        assert(openTopReplySheet != null);

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
          if (widget.post.subject.isNotEmpty)
            Container(
              margin: EdgeInsets.only(bottom: 8.0),
              child: Text(
                widget.post.subject,
                style: Theme.of(context).textTheme.subhead,
              ),
            ),
          if (_displayMode == DisplayMode.bbCode)
            Container(
              padding: EdgeInsets.only(bottom: 6.0),
              child: SelectableText(
                widget.post.content.replaceAll('<br/>', '\n'),
              ),
            ),
          if (_displayMode == DisplayMode.richText)
            BBCodeRender(
              raw: widget.post.content,
              openUser: (userId) {},
              openLink: (url) => openLink(context, url),
              openPost: (topicId, page, postId) =>
                  widget.openPost(topicId, postId),
            ),
          _Footer(
            attachments: widget.post.attachments,
            openAttachmentSheet: widget.openAttachmentSheet,
            commentIds: widget.post.commentIds,
            openCommentSheet: widget.openCommentSheet,
            topReplyIds: widget.post.topReplyIds,
            openTopReplySheet: widget.openTopReplySheet,
            vote: widget.post.vote,
            upvote: widget.upvote,
            downvote: widget.downvote,
          ),
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
            child: UserAvatar(
              index: widget.post.index,
              size: 32.0,
              user: widget.user,
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/u',
                arguments: {'uesrId': widget.user.id},
              );
            },
          ),
          Container(width: 8.0),
          Expanded(
            child: GestureDetector(
              child: widget.user.id > 0
                  ? Text(
                      widget.user.username,
                      style: Theme.of(context).textTheme.subhead,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  : Text(
                      '#ANONYMOUS#',
                      style: Theme.of(context)
                          .textTheme
                          .subhead
                          .copyWith(color: Colors.grey),
                    ),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/u',
                  arguments: {'uesrId': widget.user.id},
                );
              },
            ),
          ),
          _MetaRow(
            index: widget.post.index,
            createdAt: widget.post.createdAt,
            editedAt: widget.post.editedAt,
            editedBy: widget.post.editedBy,
            vendor: widget.post.vendor,
            vendorDetail: widget.post.vendorDetail,
          ),
          _PopupMenuButton(
            baseUrl: widget.baseUrl,
            topicId: widget.post.topicId,
            postId: widget.post.id,
            categoryId: widget.post.categoryId,
            displayMode: _displayMode,
            changeDisplayMode: (displayMode) =>
                setState(() => _displayMode = displayMode),
            sentByMe: widget.sentByMe,
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final DateTime createdAt;
  final DateTime editedAt;
  final String editedBy;
  final Vendor vendor;
  final String vendorDetail;
  final int index;

  const _MetaRow({
    Key key,
    @required this.createdAt,
    @required this.editedAt,
    @required this.editedBy,
    @required this.vendor,
    @required this.vendorDetail,
    @required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        padding: EdgeInsets.all(8.0),
        child: Wrap(
          spacing: 4.0,
          alignment: WrapAlignment.center,
          children: [
            if (editedAt != null)
              Icon(
                Icons.edit,
                color: Colors.grey,
                size: 16.0,
              ),
            if (vendor != Vendor.none)
              Icon(
                VendorIcons.fromVendor(vendor),
                color: Colors.grey,
                size: 16.0,
              ),
            if (index != 0)
              Text(
                '#$index',
                style: Theme.of(context).textTheme.caption,
              ),
            DistanceToNow(createdAt),
          ],
        ),
      ),
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: _buildMetaList,
        );
      },
    );
  }

  Widget _buildMetaList(BuildContext context) {
    List<ListTile> listChildren = [
      ListTile(
        dense: true,
        leading: const Icon(Icons.access_time),
        title: Text(AppLocalizations.of(context).createdAt),
        subtitle: Text(_dateFormatter.format(createdAt)),
      ),
      if (editedAt != null)
        ListTile(
          dense: true,
          leading: const Icon(Icons.edit),
          title: Text(AppLocalizations.of(context).editedAt),
          subtitle: Text(_dateFormatter.format(editedAt)),
        ),
      if (vendor == Vendor.android)
        ListTile(
          dense: true,
          leading: const Icon(VendorIcons.android),
          title: Text(AppLocalizations.of(context).sentFromAndroid),
          subtitle: vendorDetail.isNotEmpty ? Text(vendorDetail) : null,
        )
      else if (vendor == Vendor.apple)
        ListTile(
          dense: true,
          leading: const Icon(VendorIcons.apple),
          title: Text(AppLocalizations.of(context).sentFromApple),
          subtitle: vendorDetail.isNotEmpty ? Text(vendorDetail) : null,
        )
      else if (vendor == Vendor.windows)
        ListTile(
          dense: true,
          leading: const Icon(VendorIcons.windows),
          title: Text(AppLocalizations.of(context).sentFromWindows),
          subtitle: vendorDetail.isNotEmpty ? Text(vendorDetail) : null,
        )
    ];

    return ListView.separated(
      shrinkWrap: true,
      separatorBuilder: (context, index) => const Divider(height: 0),
      itemCount: listChildren.length,
      itemBuilder: (context, index) => listChildren[index],
    );
  }
}

enum Choice {
  displayInBBCode,
  dispalyInRichText,
  copyLinkToClipboard,
  editThisPost,
  replyToThisPost,
  quoteFromThisPost,
  commentOnThisPost,
}

class _PopupMenuButton extends StatelessWidget {
  final int categoryId;
  final int topicId;
  final int postId;
  final bool sentByMe;
  final String baseUrl;

  final DisplayMode _displayMode;
  final ValueChanged<DisplayMode> changeDisplayMode;

  const _PopupMenuButton({
    Key key,
    @required this.categoryId,
    @required this.topicId,
    @required this.postId,
    @required this.baseUrl,
    @required this.sentByMe,
    @required DisplayMode displayMode,
    @required this.changeDisplayMode,
  })  : _displayMode = displayMode,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Choice>(
      child: Container(
        padding: EdgeInsets.all(8.0),
        child: const Icon(
          Icons.more_vert,
          color: Colors.grey,
          size: 16.0,
        ),
      ),
      itemBuilder: (contenxt) => [
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
        PopupMenuItem<Choice>(
          value: Choice.copyLinkToClipboard,
          child: Text(
            AppLocalizations.of(context).copyLinkToClipboard,
            style: Theme.of(context).textTheme.body1,
          ),
        ),
        if (sentByMe)
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
      ],
      onSelected: (choice) => _onMenuSelected(context, choice),
    );
  }

  _onMenuSelected(BuildContext context, Choice choice) async {
    switch (choice) {
      case Choice.displayInBBCode:
        changeDisplayMode(DisplayMode.bbCode);
        break;
      case Choice.dispalyInRichText:
        changeDisplayMode(DisplayMode.richText);
        break;
      case Choice.copyLinkToClipboard:
        await Clipboard.setData(ClipboardData(
          text: Uri.https(baseUrl, 'read.php', {
            'tid': topicId.toString(),
            'pid': postId.toString(),
          }).toString(),
        ));
        Scaffold.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context).copiedLinkToClipboard),
          ));
        break;
      case Choice.editThisPost:
        Navigator.pushNamed(context, '/e', arguments: {
          'action': EditorAction.modify,
          'categoryId': categoryId,
          'topicId': topicId,
          'postId': postId,
        });
        break;
      case Choice.replyToThisPost:
        Navigator.pushNamed(context, '/e', arguments: {
          'action': EditorAction.reply,
          'categoryId': categoryId,
          'topicId': topicId,
          'postId': postId,
        });
        break;
      case Choice.quoteFromThisPost:
        Navigator.pushNamed(context, '/e', arguments: {
          'action': EditorAction.quote,
          'categoryId': categoryId,
          'topicId': topicId,
          'postId': postId,
        });
        break;
      case Choice.commentOnThisPost:
        Navigator.pushNamed(context, '/e', arguments: {
          'action': EditorAction.comment,
          'categoryId': categoryId,
          'topicId': topicId,
          'postId': postId,
        });
        break;
    }
  }
}

class _Footer extends StatelessWidget {
  final BuiltList<Attachment> attachments;
  final Function(BuiltList<Attachment>) openAttachmentSheet;

  final BuiltList<int> topReplyIds;
  final Function(BuiltList<int>) openTopReplySheet;

  final BuiltList<int> commentIds;
  final Function(BuiltList<int>) openCommentSheet;

  final int vote;
  final VoidCallback upvote;
  final VoidCallback downvote;

  const _Footer({
    Key key,
    @required this.attachments,
    @required this.openAttachmentSheet,
    @required this.topReplyIds,
    @required this.openTopReplySheet,
    @required this.commentIds,
    @required this.openCommentSheet,
    @required this.vote,
    @required this.upvote,
    @required this.downvote,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        if (attachments.isNotEmpty)
          Padding(
            padding: EdgeInsets.all(8.0),
            child: InkResponse(
              child: Icon(
                Icons.attach_file,
                size: 16.0,
                color: Color.fromARGB(255, 144, 144, 144),
              ),
              onTap: () => openAttachmentSheet(attachments),
            ),
          ),
        if (attachments.length > 1)
          Text(
            '${attachments.length}',
            style: Theme.of(context).textTheme.caption,
          ),
        if (commentIds.isNotEmpty)
          Padding(
            padding: EdgeInsets.all(8.0),
            child: InkResponse(
              child: Icon(
                Icons.comment,
                size: 16,
                color: Color.fromARGB(255, 144, 144, 144),
              ),
              onTap: () => openCommentSheet(commentIds),
            ),
          ),
        if (commentIds.length > 1)
          Text(
            '${commentIds.length}',
            style: Theme.of(context).textTheme.caption,
          ),
        if (topReplyIds.isNotEmpty)
          Padding(
            padding: EdgeInsets.all(8.0),
            child: InkResponse(
              child: Icon(
                Icons.whatshot,
                size: 16,
                color: Color.fromARGB(255, 144, 144, 144),
              ),
              onTap: () => openTopReplySheet(topReplyIds),
            ),
          ),
        if (topReplyIds.length > 1)
          Text(
            '${topReplyIds.length}',
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
            onTap: upvote,
          ),
        ),
        if (vote > 0)
          Text(
            vote.toString(),
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
            onTap: downvote,
          ),
        ),
      ],
    );
  }
}
