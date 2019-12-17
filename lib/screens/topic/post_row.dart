import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:ngnga/bbcode/render.dart';
import 'package:ngnga/localizations.dart';
import 'package:ngnga/models/attachment.dart';
import 'package:ngnga/models/post.dart';
import 'package:ngnga/models/user.dart';
import 'package:ngnga/screens/editor/editor.dart';
import 'package:ngnga/utils/duration.dart';
import 'package:ngnga/utils/open_link.dart';
import 'package:ngnga/utils/vendor_icons.dart';
import 'package:ngnga/widgets/user_avatar.dart';

final _dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');

final _everyMinutes = StreamController<DateTime>.broadcast()
  ..addStream(
    Stream.periodic(Duration(minutes: 1), (_) => DateTime.now()),
  );

enum DisplayMode {
  bbCode,
  richText,
}

class PostRow extends StatefulWidget {
  final PostItem post;
  final User user;
  final bool sentByMe;
  final String baseUrl;

  final Future<void> Function() upvote;
  final Future<void> Function() downvote;

  final Function(int, int) openPost;
  final Function(List<Attachment>) openAttachmentSheet;
  final Function(List<int>) openCommentSheet;
  final Function(List<int>) openTopReplySheet;

  PostRow({
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

  Post get post => widget.post.inner;

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
                post.content.replaceAll('<br/>', '\n'),
              ),
            ),
          if (_displayMode == DisplayMode.richText)
            BBCodeRender(
              raw: post.content,
              openUser: (userId) {},
              openLink: (url) => openLink(context, url),
              openPost: (topicId, page, postId) =>
                  widget.openPost(topicId, postId),
            ),
          _Footer(
            attachments: post.attachments,
            openAttachmentSheet: widget.openAttachmentSheet,
            commentIds: post.commentIds,
            openCommentSheet: widget.openCommentSheet,
            topReplyIds:
                post is TopicPost ? (post as TopicPost).topReplyIds : [],
            openTopReplySheet: widget.openTopReplySheet,
            vote: post.vote,
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
              index: post.index,
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
            index: post.index,
            createdAt: post.createdAt,
            editedAt: post.editedAt,
            editedBy: post.editedBy,
            vendor: post.vendor,
            vendorDetail: post.vendorDetail,
          ),
          _PopupMenuButton(
            baseUrl: widget.baseUrl,
            topicId: post.topicId,
            postId: post.id,
            categoryId: post.categoryId,
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
                size: 16,
              ),
            if (vendor != null)
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
            StreamBuilder<DateTime>(
              initialData: DateTime.now(),
              stream: _everyMinutes.stream,
              builder: (context, snapshot) => Text(
                duration(snapshot.data, createdAt),
                style: Theme.of(context).textTheme.caption,
              ),
            ),
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
      if (vendor != null) _buildVendorListTile(context),
    ];

    return ListView.separated(
      shrinkWrap: true,
      separatorBuilder: (context, index) => const Divider(height: 0),
      itemCount: listChildren.length,
      itemBuilder: (context, index) => listChildren[index],
    );
  }

  ListTile _buildVendorListTile(BuildContext context) {
    String title;
    switch (vendor) {
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
    if (vendorDetail.isEmpty) {
      return ListTile(
        dense: true,
        leading: Icon(VendorIcons.fromVendor(vendor)),
        title: Text(title),
      );
    } else {
      return ListTile(
        dense: true,
        leading: Icon(VendorIcons.fromVendor(vendor)),
        title: Text(title),
        subtitle: Text(vendorDetail),
      );
    }
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
  final List<Attachment> attachments;
  final Function(List<Attachment>) openAttachmentSheet;

  final List<int> topReplyIds;
  final Function(List<int>) openTopReplySheet;

  final List<int> commentIds;
  final Function(List<int>) openCommentSheet;

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
