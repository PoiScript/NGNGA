import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import 'collapse.dart';
import 'parser.dart';
import 'sticker.dart';
import 'tag.dart';

class BBCodeRender extends StatefulWidget {
  final String data;

  final void Function(int, int, int) openPost;
  final void Function(int) openUser;
  final void Function(String) openLink;

  BBCodeRender({
    @required String raw,
    @required this.openPost,
    @required this.openUser,
    @required this.openLink,
  })  : assert(raw != null),
        assert(openPost != null),
        assert(openUser != null),
        assert(openLink != null),
        data = raw.replaceAll('<br/>', '\n');

  @override
  _BBCodeRenderState createState() => _BBCodeRenderState();
}

class _BBCodeRenderState extends State<BBCodeRender> {
  TextStyle style;

  @override
  Widget build(BuildContext context) {
    Iterator<Tag> iter = parseBBCode(widget.data).iterator;
    style = Theme.of(context)
        .textTheme
        .body1
        .copyWith(fontFamily: 'Noto Sans CJK SC');

    List<Widget> children = [];

    while (iter.moveNext()) {
      if (iter.current is BoldStartTag ||
          iter.current is ColorStartTag ||
          iter.current is DeleteStartTag ||
          iter.current is FontStartTag ||
          iter.current is ItalicStartTag ||
          iter.current is SizeStartTag) {
        _applyStyle(context, iter.current);
      } else if (iter.current is ParagraphStartTag) {
        children.add(_buildParagraph(context, iter));
      } else if (iter.current is ReplyTag) {
        children.add(_buildReply(context, iter.current, true));
      } else if (iter.current is CollapseStartTag) {
        children.add(_buildCollapse(context, iter.current, iter));
      } else if (iter.current is QuoteStartTag) {
        children.add(_buildQuote(context, iter));
      } else if (iter.current is TableStartTag) {
        children.add(_buildTable(context, iter));
      } else if (iter.current is HeadingStartTag) {
        children.add(_buildHeading(context, iter));
      } else if (iter.current is RuleTag) {
        children.add(_buildRule(context));
      } else if (iter.current is AlignStartTag) {
        children.add(_buildAlign(context, iter.current, iter));
      } else if (iter.current is ListItemStartTag) {
        children.add(_buildListItem(context, iter));
      } else {
        throw 'Unexcepted element: ${iter.current}';
      }
    }

    if (children.length == 1) {
      return children[0];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _buildParagraph(BuildContext context, Iterator<Tag> iter) {
    assert(iter.current is ParagraphStartTag);

    List<InlineSpan> spans = [];

    while (iter.moveNext()) {
      if (iter.current is ParagraphStartTag) {
        throw 'Nested paragraph is not allowed';
      } else if (iter.current is ParagraphEndTag) {
        break;
      } else if (_isStyle(iter.current)) {
        _applyStyle(context, iter.current);
      } else if (iter.current is TextTag) {
        spans.add(_buildText(context, iter.current));
      } else if (iter.current is ImageTag) {
        spans.add(_buildImage(context, iter.current));
      } else if (iter.current is LinkStartTag) {
        spans.add(_buildLink(context, iter.current, iter));
      } else if (iter.current is StickerTag) {
        spans.add(_buildSticker(context, iter.current));
      } else if (iter.current is MetionsTag) {
        spans.add(_buildMetions(context, iter.current));
      } else if (iter.current is PidTag) {
        spans.add(_buildPid(context, iter.current));
      } else if (iter.current is UidTag) {
        spans.add(_buildUid(context, iter.current));
      } else {
        throw 'Unexecpted element: ${iter.current}.';
      }
    }

    return Container(
      padding: EdgeInsets.only(bottom: 6.0),
      child: spans.length == 1
          ? RichText(text: spans[0])
          : RichText(
              text: TextSpan(children: spans),
            ),
    );
  }

  Widget _buildCollapse(
    BuildContext context,
    CollapseStartTag tag,
    Iterator<Tag> iter,
  ) {
    List<Widget> children = [];

    while (iter.moveNext()) {
      if (iter.current is CollapseStartTag) {
        throw 'Nested collapse is not allowed';
      } else if (iter.current is CollapseEndTag) {
        break;
      } else if (_isStyle(iter.current)) {
        _applyStyle(context, iter.current);
      } else if (iter.current is ParagraphStartTag) {
        children.add(_buildParagraph(context, iter));
      } else if (iter.current is ReplyTag) {
        children.add(_buildReply(context, iter.current, false));
      } else if (iter.current is QuoteStartTag) {
        children.add(_buildQuote(context, iter));
      } else if (iter.current is TableStartTag) {
        children.add(_buildTable(context, iter));
      } else if (iter.current is HeadingStartTag) {
        children.add(_buildHeading(context, iter));
      } else if (iter.current is RuleTag) {
        children.add(_buildRule(context));
      } else if (iter.current is AlignStartTag) {
        children.add(_buildAlign(context, iter.current, iter));
      } else if (iter.current is ListItemStartTag) {
        children.add(_buildListItem(context, iter));
      } else {
        throw 'Unexpected element: ${iter.current}.';
      }
    }

    return Collapse(
      description: tag.description,
      child: children.length == 1
          ? children[0]
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
    );
  }

  Widget _buildQuote(BuildContext context, Iterator<Tag> iter) {
    assert(iter.current is QuoteStartTag);

    List<Widget> children = [];

    while (iter.moveNext()) {
      if (iter.current is QuoteStartTag) {
        children.add(_buildQuote(context, iter));
      } else if (iter.current is QuoteEndTag) {
        break;
      } else if (_isStyle(iter.current)) {
        _applyStyle(context, iter.current);
      } else if (iter.current is ReplyTag) {
        children.add(_buildReply(context, iter.current, false));
      } else if (iter.current is ParagraphStartTag) {
        children.add(_buildParagraph(context, iter));
      } else if (iter.current is CollapseStartTag) {
        children.add(_buildCollapse(context, iter.current, iter));
      } else if (iter.current is TableStartTag) {
        children.add(_buildTable(context, iter));
      } else if (iter.current is HeadingStartTag) {
        children.add(_buildHeading(context, iter));
      } else if (iter.current is RuleTag) {
        children.add(_buildRule(context));
      } else if (iter.current is AlignStartTag) {
        children.add(_buildAlign(context, iter.current, iter));
      } else if (iter.current is ListItemStartTag) {
        children.add(_buildListItem(context, iter));
      } else {
        throw 'Unexpected element: ${iter.current}.';
      }
    }

    return Container(
      constraints: const BoxConstraints(minWidth: double.infinity),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            width: 5.0,
            color: Theme.of(context).brightness == Brightness.dark
                ? Color.fromARGB(255, 0x31, 0x31, 0x31)
                : Color.fromARGB(255, 0xe9, 0xe9, 0xe9),
          ),
        ),
        color: Theme.of(context).brightness == Brightness.dark
            ? Color.fromARGB(255, 0x3c, 0x3c, 0x3c)
            : Color.fromARGB(255, 0xf4, 0xf4, 0xf4),
      ),
      padding: EdgeInsets.only(left: 4.0 + 5.0, top: 6.0, right: 6.0),
      margin: EdgeInsets.only(bottom: 8.0),
      child: children.length == 1
          ? children[0]
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
    );
  }

  Widget _buildAlign(
    BuildContext context,
    AlignStartTag tag,
    Iterator<Tag> iter,
  ) {
    List<Widget> children = [];

    while (iter.moveNext()) {
      if (iter.current is AlignStartTag) {
        children.add(_buildAlign(context, iter.current, iter));
      } else if (iter.current is AlignEndTag) {
        break;
      } else if (_isStyle(iter.current)) {
        _applyStyle(context, iter.current);
      } else if (iter.current is ReplyTag) {
        children.add(_buildReply(context, iter.current, false));
      } else if (iter.current is ParagraphStartTag) {
        children.add(_buildParagraph(context, iter));
      } else if (iter.current is CollapseStartTag) {
        children.add(_buildCollapse(context, iter.current, iter));
      } else if (iter.current is TableStartTag) {
        children.add(_buildTable(context, iter));
      } else if (iter.current is HeadingStartTag) {
        children.add(_buildHeading(context, iter));
      } else if (iter.current is RuleTag) {
        children.add(_buildRule(context));
      } else if (iter.current is QuoteStartTag) {
        children.add(_buildQuote(context, iter));
      } else if (iter.current is ListItemStartTag) {
        children.add(_buildListItem(context, iter));
      } else {
        throw 'Unexpected element: ${iter.current}.';
      }
    }

    if (children.length == 1) {
      return Align(
        alignment: tag.value == 'center'
            ? Alignment.center
            : tag.value == 'left'
                ? Alignment.centerLeft
                : Alignment.centerRight,
        child: children[0],
      );
    } else {
      return Column(
        crossAxisAlignment: tag.value == 'center'
            ? CrossAxisAlignment.end
            : tag.value == 'left'
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
        children: children,
      );
    }
  }

  Widget _buildListItem(BuildContext context, Iterator<Tag> iter) {
    assert(iter.current is ListItemStartTag);

    List<Widget> children = [];

    while (iter.moveNext()) {
      if (iter.current is ListItemStartTag) {
        children.add(_buildListItem(context, iter));
      } else if (iter.current is ListItemEndTag) {
        break;
      } else if (_isStyle(iter.current)) {
        _applyStyle(context, iter.current);
      } else if (iter.current is ReplyTag) {
        children.add(_buildReply(context, iter.current, false));
      } else if (iter.current is ParagraphStartTag) {
        children.add(_buildParagraph(context, iter));
      } else if (iter.current is CollapseStartTag) {
        children.add(_buildCollapse(context, iter.current, iter));
      } else if (iter.current is TableStartTag) {
        children.add(_buildTable(context, iter));
      } else if (iter.current is HeadingStartTag) {
        children.add(_buildHeading(context, iter));
      } else if (iter.current is RuleTag) {
        children.add(_buildRule(context));
      } else if (iter.current is QuoteStartTag) {
        children.add(_buildQuote(context, iter));
      } else if (iter.current is AlignStartTag) {
        children.add(_buildAlign(context, iter.current, iter));
      } else {
        throw 'Unexpected element: ${iter.current}.';
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 24.0,
          child: Text(
            '•',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.body1,
          ),
        ),
        Expanded(
          child: children.length == 1
              ? children[0]
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children,
                ),
        ),
      ],
    );
  }

  Widget _buildTable(BuildContext context, Iterator<Tag> iter) {
    assert(iter.current is TableStartTag);

    // TODO:

    return Text('TABLE', style: TextStyle(color: Colors.red));
  }

  Widget _buildHeading(BuildContext context, Iterator<Tag> iter) {
    assert(iter.current is HeadingStartTag);

    List<Widget> children = [];

    final previousSize = style.fontSize;
    style =
        style.copyWith(fontSize: Theme.of(context).textTheme.subhead.fontSize);

    while (iter.moveNext()) {
      if (iter.current is HeadingStartTag) {
        throw 'Nested heading is not allowed';
      } else if (iter.current is HeadingEndTag) {
        break;
      } else if (_isStyle(iter.current)) {
        _applyStyle(context, iter.current);
      } else if (iter.current is ParagraphStartTag) {
        children.add(_buildParagraph(context, iter));
      } else {
        throw 'Unexecpted element: ${iter.current}.';
      }
    }

    style = style.copyWith(fontSize: previousSize);

    return Container(
      padding: EdgeInsets.only(bottom: 6.0),
      child: children.length == 1
          ? children[0]
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
    );
  }

  Widget _buildRule(BuildContext context) {
    return Divider();
  }

  Widget _buildReply(
    BuildContext context,
    ReplyTag reply,
    bool wrapQuote,
  ) {
    var row = InkWell(
      onTap: () => widget.openPost(
        reply.topicId,
        reply.pageIndex,
        reply.postId,
      ),
      child: Row(
        children: [
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(pi),
            child: Icon(
              Icons.reply,
              color: Colors.grey[500],
            ),
          ),
          Text(
            reply.username ?? '#ANONYMOUS#',
            style: Theme.of(context)
                .textTheme
                .body2
                .copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

    if (wrapQuote) {
      return Container(
        margin: EdgeInsets.only(bottom: 8.0),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              width: 5.0,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Color.fromARGB(255, 0x31, 0x31, 0x31)
                  : Color.fromARGB(255, 0xe9, 0xe9, 0xe9),
            ),
          ),
          color: Theme.of(context).brightness == Brightness.dark
              ? Color.fromARGB(255, 0x3c, 0x3c, 0x3c)
              : Color.fromARGB(255, 0xf4, 0xf4, 0xf4),
        ),
        padding: EdgeInsets.only(left: 8.0, top: 6.0, bottom: 6.0),
        child: row,
      );
    } else {
      return Container(
        padding: EdgeInsets.only(bottom: 4.0),
        child: row,
      );
    }
  }

  InlineSpan _buildLink(
    BuildContext context,
    LinkStartTag tag,
    Iterator<Tag> iter,
  ) {
    final recognizer = TapGestureRecognizer()
      ..onTap = () => widget.openLink(tag.url);

    List<InlineSpan> spans = [];

    while (iter.moveNext()) {
      if (iter.current is LinkStartTag) {
        throw 'Nested link is not allowed.';
      } else if (iter.current is LinkEndTag) {
        break;
      } else if (_isStyle(iter.current)) {
        _applyStyle(context, iter.current);
      } else if (iter.current is TextTag) {
        spans.add(TextSpan(
          recognizer: recognizer,
          text: (iter.current as TextTag).content,
          style: style.copyWith(color: Colors.blue),
        ));
      } else if (iter.current is ImageTag) {
        spans.add(_buildImage(context, iter.current));
      } else if (iter.current is StickerTag) {
        spans.add(_buildSticker(context, iter.current));
      } else {
        throw 'Unexecpted element: ${iter.current}.';
      }
    }

    if (spans.length == 1) {
      return spans[0];
    } else {
      return TextSpan(children: spans);
    }
  }

  InlineSpan _buildImage(BuildContext context, ImageTag image) {
    String url, originalUrl;

    if (image.url.startsWith('./')) {
      url = 'https://img.nga.178.com/attachments${image.url.substring(1)}';
      if (url.endsWith('.thumb_ss.jpg')) {
        originalUrl = url.substring(0, url.length - 13);
      } else if (url.endsWith('.thumb_s.jpg')) {
        originalUrl = url.substring(0, url.length - 12);
      } else if (url.endsWith('.thumb.jpg')) {
        originalUrl = url.substring(0, url.length - 10);
      } else if (url.endsWith('.medium.jpg')) {
        originalUrl = url.substring(0, url.length - 11);
      } else {
        originalUrl = url;
      }
    } else {
      url = originalUrl = image.url;
    }

    return WidgetSpan(
      child: CachedNetworkImage(
        imageUrl: url,
        imageBuilder: (context, imageProvider) => GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => originalUrl == url
                    ? HeroPhotoViewWrapper(imageProvider: imageProvider)
                    : HeroPhotoViewWrapper(
                        imageProvider: CachedNetworkImageProvider(originalUrl),
                      ),
              ),
            );
          },
          child: Hero(
            // FIXME: better way to create unique tag
            tag: 'tag${DateTime.now().toString()}',
            child: Image(image: imageProvider),
          ),
        ),
        placeholder: (context, url) => Center(
          child: CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) => Text(
          'fialed to load image $url',
          style: Theme.of(context)
              .textTheme
              .body1
              .copyWith(color: Theme.of(context).errorColor),
        ),
      ),
    );
  }

  InlineSpan _buildSticker(BuildContext context, StickerTag sticker) {
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Sticker(name: sticker.name),
    );
  }

  InlineSpan _buildPid(BuildContext context, PidTag pid) {
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: InkWell(
        onTap: () => widget.openPost(pid.topicId, pid.pageIndex, pid.postId),
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationY(pi),
          child: Icon(
            Icons.reply,
            color: Colors.grey[500],
          ),
        ),
      ),
    );
  }

  InlineSpan _buildUid(BuildContext context, UidTag uid) {
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: InkWell(
        onTap: () => widget.openUser(uid.id),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 2.0,
            vertical: 1.0,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.0),
            color: Color.fromARGB(255, 0xe9, 0xe9, 0xe9),
          ),
          child: Text(
            '@${uid.username}',
            style: Theme.of(context)
                .textTheme
                .body2
                .copyWith(color: Color.fromARGB(255, 0x64, 0x64, 0x64)),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  InlineSpan _buildMetions(BuildContext context, MetionsTag metions) {
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: InkWell(
        onTap: () => widget.openUser(0),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 2.0,
            vertical: 1.0,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.0),
            color: Color.fromARGB(255, 0xe9, 0xe9, 0xe9),
          ),
          child: Text(
            '@${metions.username}',
            style: Theme.of(context)
                .textTheme
                .body2
                .copyWith(color: Color.fromARGB(255, 0x64, 0x64, 0x64)),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  InlineSpan _buildText(BuildContext context, TextTag text) {
    return TextSpan(text: text.content, style: style);
  }

  bool _isStyle(Tag tag) =>
      tag is ParagraphEndTag ||
      tag is BoldStartTag ||
      tag is BoldEndTag ||
      tag is ItalicStartTag ||
      tag is ItalicEndTag ||
      tag is UnderlineStartTag ||
      tag is UnderlineEndTag ||
      tag is DeleteStartTag ||
      tag is DeleteEndTag ||
      tag is FontStartTag ||
      tag is FontEndTag ||
      tag is ColorStartTag ||
      tag is ColorEndTag ||
      tag is SizeStartTag ||
      tag is SizeEndTag;

  _applyStyle(BuildContext context, Tag tag) {
    if (tag is BoldStartTag) {
      style = style.copyWith(fontWeight: FontWeight.w500);
    } else if (tag is BoldEndTag) {
      style = style.copyWith(fontWeight: FontWeight.w400);
    } else if (tag is ItalicStartTag) {
      style = style.copyWith(fontStyle: FontStyle.italic);
    } else if (tag is ItalicEndTag) {
      style = style.copyWith(fontStyle: FontStyle.normal);
    } else if (tag is UnderlineStartTag) {
      // TODO
    } else if (tag is UnderlineEndTag) {
      // TODO:
    } else if (tag is DeleteStartTag) {
      style = style.copyWith(decoration: TextDecoration.lineThrough);
    } else if (tag is DeleteEndTag) {
      style = style.copyWith(decoration: TextDecoration.none);
    } else if (tag is FontStartTag) {
      // TODO:
    } else if (tag is FontEndTag) {
      // TODO:
    } else if (tag is ColorStartTag) {
      // TODO:
    } else if (tag is ColorEndTag) {
      // TODO:
    } else if (tag is SizeStartTag) {
      // TODO:
    } else if (tag is SizeEndTag) {
      // TODO:
    }
  }
}

class HeroPhotoViewWrapper extends StatelessWidget {
  const HeroPhotoViewWrapper({@required this.imageProvider});

  final ImageProvider imageProvider;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.expand(
        height: MediaQuery.of(context).size.height,
      ),
      child: PhotoView(
        imageProvider: imageProvider,
        heroAttributes: const PhotoViewHeroAttributes(tag: 'someTag'),
      ),
    );
  }
}
