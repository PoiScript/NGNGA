import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
// import Text and Image widget under the material namespace
import 'package:flutter/material.dart' as material show Text, Image;
import 'package:flutter/material.dart' hide Text, Image;
import 'package:photo_view/photo_view.dart';

import 'collapse.dart';
import 'parser.dart';
import 'tag.dart';

class BBCodeRender extends StatefulWidget {
  final String data;

  final void Function(int, int, int) openPost;
  final void Function(int) openUser;
  final void Function(String) openLink;

  BBCodeRender({
    @required String data,
    @required this.openPost,
    @required this.openUser,
    @required this.openLink,
  })  : assert(data != null),
        assert(openPost != null),
        assert(openUser != null),
        assert(openLink != null),
        this.data = data.replaceAll("<br/>", "\n");

  @override
  _BBCodeRenderState createState() => _BBCodeRenderState();
}

class _BBCodeRenderState extends State<BBCodeRender> {
  TextStyle style;

  @override
  Widget build(BuildContext context) {
    var tags = parseBBCode(widget.data);
    var iter = tags.iterator;
    style = Theme.of(context)
        .textTheme
        .body1
        .copyWith(fontFamily: "Noto Sans CJK SC");

    List<Widget> children = [];

    while (iter.moveNext()) {
      switch (iter.current.type) {
        case TagType.BoldStart:
        case TagType.ColorStart:
        case TagType.DeleteStart:
        case TagType.FontStart:
        case TagType.ItalicStart:
        case TagType.SizeStart:
          _applyStyle(context, iter.current);
          break;
        case TagType.ParagraphStart:
          children.add(_buildParagraph(context, iter));
          break;
        case TagType.Reply:
          children.add(_buildReply(context, iter.current as Reply, true));
          break;
        case TagType.CollapseStart:
          children.add(_buildCollapse(context, iter));
          break;
        case TagType.QuoteStart:
          children.add(_buildQuote(context, iter));
          break;
        case TagType.TableStart:
          children.add(_buildTable(context, iter));
          break;
        case TagType.HeadingStart:
          children.add(_buildHeading(context, iter));
          break;
        case TagType.Rule:
          children.add(_buildRule(context));
          break;
        case TagType.AlignStart:
          children.add(_buildHeading(context, iter));
          // TODO:
          iter.moveNext();
          break;
        case TagType.TableRowStart:
        case TagType.Image:
        case TagType.Sticker:
        case TagType.Metions:
        case TagType.UnderlineStart:
        case TagType.Text:
        case TagType.LinkStart:
        case TagType.Pid:
        case TagType.Uid:
        case TagType.TableCellStart:
        case TagType.QuoteEnd:
        case TagType.TableEnd:
        case TagType.CollapseEnd:
        case TagType.BoldEnd:
        case TagType.FontEnd:
        case TagType.ColorEnd:
        case TagType.SizeEnd:
        case TagType.UnderlineEnd:
        case TagType.ItalicEnd:
        case TagType.DeleteEnd:
        case TagType.LinkEnd:
        case TagType.HeadingEnd:
        case TagType.TableRowEnd:
        case TagType.TableCellEnd:
        case TagType.AlignEnd:
        case TagType.ParagraphEnd:
          throw "Unexcepted element: ${iter.current}";
          break;
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
    assert(iter.current.type == TagType.ParagraphStart);

    List<InlineSpan> spans = [];

    outerloop:
    while (iter.moveNext()) {
      switch (iter.current.type) {
        case TagType.ParagraphStart:
          throw "Nested paragraph is not allowed";
          break;
        case TagType.ParagraphEnd:
          break outerloop;
        case TagType.BoldStart:
        case TagType.BoldEnd:
        case TagType.ItalicStart:
        case TagType.ItalicEnd:
        case TagType.UnderlineStart:
        case TagType.UnderlineEnd:
        case TagType.DeleteStart:
        case TagType.DeleteEnd:
        case TagType.FontStart:
        case TagType.FontEnd:
        case TagType.ColorStart:
        case TagType.ColorEnd:
        case TagType.SizeStart:
        case TagType.SizeEnd:
          _applyStyle(context, iter.current);
          break;
        case TagType.Text:
          spans.add(_buildText(context, iter.current as Text));
          break;
        case TagType.Image:
          spans.add(_buildImage(context, iter.current as Image));
          break;
        case TagType.LinkStart:
          spans.add(_buildLink(context, iter));
          break;
        case TagType.Sticker:
          spans.add(_buildSticker(context, iter.current as Sticker));
          break;
        case TagType.Metions:
          spans.add(_buildMetions(context, iter.current as Metions));
          break;
        case TagType.Pid:
          spans.add(_buildPid(context, iter.current as Pid));
          break;
        case TagType.Uid:
          spans.add(_buildUid(context, iter.current as Uid));
          break;
        case TagType.AlignStart:
        case TagType.LinkEnd:
        case TagType.AlignEnd:
        case TagType.Rule:
        case TagType.QuoteStart:
        case TagType.QuoteEnd:
        case TagType.CollapseStart:
        case TagType.CollapseEnd:
        case TagType.TableStart:
        case TagType.TableEnd:
        case TagType.HeadingStart:
        case TagType.HeadingEnd:
        case TagType.Reply:
        case TagType.TableRowStart:
        case TagType.TableRowEnd:
        case TagType.TableCellStart:
        case TagType.TableCellEnd:
          throw "Unexecpted element: ${iter.current}.";
      }
    }

    if (spans.length == 1) {
      return Container(
        padding: EdgeInsets.only(bottom: 6.0),
        child: RichText(text: spans[0]),
      );
    }

    return Container(
      padding: EdgeInsets.only(bottom: 6.0),
      child: RichText(
        text: TextSpan(children: spans),
      ),
    );
  }

  Widget _buildCollapse(BuildContext context, Iterator<Tag> iter) {
    assert(iter.current.type == TagType.CollapseStart);

    String description = (iter.current as CollapseStart).description;
    List<Widget> children = [];

    outerloop:
    while (iter.moveNext()) {
      switch (iter.current.type) {
        case TagType.CollapseStart:
          throw "Nested collapse is not allowed";
        case TagType.CollapseEnd:
          break outerloop;
        case TagType.ItalicStart:
        case TagType.ItalicEnd:
        case TagType.DeleteStart:
        case TagType.DeleteEnd:
        case TagType.BoldStart:
        case TagType.BoldEnd:
        case TagType.FontStart:
        case TagType.FontEnd:
        case TagType.ColorStart:
        case TagType.ColorEnd:
        case TagType.SizeStart:
        case TagType.SizeEnd:
        case TagType.UnderlineStart:
        case TagType.UnderlineEnd:
          _applyStyle(context, iter.current);
          break;
        case TagType.ParagraphStart:
          children.add(_buildParagraph(context, iter));
          break;
        case TagType.Reply:
          children.add(_buildReply(context, iter.current as Reply, false));
          break;
        case TagType.QuoteStart:
          children.add(_buildQuote(context, iter));
          break;
        case TagType.TableStart:
          children.add(_buildTable(context, iter));
          break;
        case TagType.HeadingStart:
          children.add(_buildHeading(context, iter));
          break;
        case TagType.Rule:
          children.add(_buildRule(context));
          break;
        case TagType.AlignStart:
          // TODO: Handle this case.
          break;
        case TagType.TableRowStart:
        case TagType.TableRowEnd:
        case TagType.TableCellStart:
        case TagType.TableCellEnd:
        case TagType.Image:
        case TagType.Text:
        case TagType.LinkStart:
        case TagType.LinkEnd:
        case TagType.Sticker:
        case TagType.Metions:
        case TagType.Pid:
        case TagType.Uid:
        case TagType.QuoteEnd:
        case TagType.TableEnd:
        case TagType.HeadingEnd:
        case TagType.AlignEnd:
        case TagType.ParagraphEnd:
          throw "Unexpected element: ${iter.current}.";
      }
    }

    if (children.length == 1) {
      return Collapse(
        description: description,
        child: children[0],
      );
    }

    return Collapse(
      description: description,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildQuote(BuildContext context, Iterator<Tag> iter) {
    assert(iter.current.type == TagType.QuoteStart);

    List<Widget> children = [];

    outerloop:
    while (iter.moveNext()) {
      switch (iter.current.type) {
        case TagType.QuoteStart:
          children.add(_buildQuote(context, iter));
          break;
        case TagType.QuoteEnd:
          break outerloop;
        case TagType.ItalicStart:
        case TagType.ItalicEnd:
        case TagType.DeleteStart:
        case TagType.DeleteEnd:
        case TagType.BoldStart:
        case TagType.BoldEnd:
        case TagType.FontStart:
        case TagType.FontEnd:
        case TagType.ColorStart:
        case TagType.ColorEnd:
        case TagType.SizeStart:
        case TagType.SizeEnd:
        case TagType.UnderlineStart:
        case TagType.UnderlineEnd:
          _applyStyle(context, iter.current);
          break;
        case TagType.Reply:
          children.add(_buildReply(context, iter.current as Reply, false));
          break;
        case TagType.ParagraphStart:
          children.add(_buildParagraph(context, iter));
          break;
        case TagType.CollapseStart:
          children.add(_buildCollapse(context, iter));
          break;
        case TagType.TableStart:
          children.add(_buildTable(context, iter));
          break;
        case TagType.HeadingStart:
          children.add(_buildHeading(context, iter));
          break;
        case TagType.Rule:
          children.add(_buildRule(context));
          break;
        case TagType.AlignStart:
          // TODO: Handle this case.
          break;
        case TagType.Text:
        case TagType.Image:
        case TagType.LinkStart:
        case TagType.LinkEnd:
        case TagType.Sticker:
        case TagType.Metions:
        case TagType.Pid:
        case TagType.Uid:
        case TagType.TableEnd:
        case TagType.CollapseEnd:
        case TagType.HeadingEnd:
        case TagType.AlignEnd:
        case TagType.ParagraphEnd:
        case TagType.TableRowStart:
        case TagType.TableCellStart:
        case TagType.TableRowEnd:
        case TagType.TableCellEnd:
          throw "Unexpected element: ${iter.current}.";
          break;
      }
    }

    if (children.length == 1) {
      return Container(
        constraints: const BoxConstraints(minWidth: double.infinity),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              width: 5.0,
              color: Color.fromARGB(255, 0xe9, 0xe9, 0xe9),
            ),
          ),
          color: Color.fromARGB(255, 0xf4, 0xf4, 0xf4),
        ),
        padding: EdgeInsets.only(left: 4.0 + 5.0, top: 6.0, right: 6.0),
        margin: EdgeInsets.only(bottom: 8.0),
        child: children[0],
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            width: 5.0,
            color: Color.fromARGB(255, 0xe9, 0xe9, 0xe9),
          ),
        ),
        color: Color.fromARGB(255, 0xf4, 0xf4, 0xf4),
      ),
      padding: EdgeInsets.only(left: 4.0 + 5.0, top: 6.0, right: 6.0),
      margin: EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  // TODO:
  // Widget _buildAlign(BuildContext context, Iterator<Tag> iter) {
  //   return null;
  // }

  Widget _buildTable(BuildContext context, Iterator<Tag> iter) {
    assert(iter.current.type == TagType.TableStart);

    // TODO:

    return material.Text("TABLE", style: TextStyle(color: Colors.red));
  }

  Widget _buildHeading(BuildContext context, Iterator<Tag> iter) {
    assert(iter.current.type == TagType.HeadingStart);

    List<Widget> children = [];

    final previousSize = style.fontSize;
    style =
        style.copyWith(fontSize: Theme.of(context).textTheme.subhead.fontSize);

    outerloop:
    while (iter.moveNext()) {
      switch (iter.current.type) {
        case TagType.HeadingStart:
          throw "Nested heading is not allowed";
        case TagType.HeadingEnd:
          break outerloop;
        case TagType.ItalicStart:
        case TagType.ItalicEnd:
        case TagType.DeleteStart:
        case TagType.DeleteEnd:
        case TagType.BoldStart:
        case TagType.BoldEnd:
        case TagType.FontStart:
        case TagType.FontEnd:
        case TagType.ColorStart:
        case TagType.ColorEnd:
        case TagType.SizeStart:
        case TagType.SizeEnd:
        case TagType.UnderlineStart:
        case TagType.UnderlineEnd:
          _applyStyle(context, iter.current);
          break;
        case TagType.ParagraphStart:
          children.add(_buildParagraph(context, iter));
          break;
        case TagType.ParagraphEnd:
        case TagType.AlignStart:
        case TagType.AlignEnd:
        case TagType.Rule:
        case TagType.QuoteStart:
        case TagType.QuoteEnd:
        case TagType.CollapseStart:
        case TagType.CollapseEnd:
        case TagType.TableStart:
        case TagType.Reply:
        case TagType.TableEnd:
        case TagType.Text:
        case TagType.Image:
        case TagType.Sticker:
        case TagType.Metions:
        case TagType.Pid:
        case TagType.Uid:
        case TagType.LinkStart:
        case TagType.LinkEnd:
        case TagType.TableRowStart:
        case TagType.TableRowEnd:
        case TagType.TableCellStart:
        case TagType.TableCellEnd:
          throw "Unexecpted element: ${iter.current}.";
          break;
      }
    }

    style = style.copyWith(fontSize: previousSize);

    return Container(
      padding: EdgeInsets.only(bottom: 6.0),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildRule(BuildContext context) {
    return Divider();
  }

  Widget _buildReply(BuildContext context, Reply reply, bool wrapQuote) {
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
          material.Text(
            reply.username ?? "#ANONYMOUS#",
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
              color: Color.fromARGB(255, 0xe9, 0xe9, 0xe9),
            ),
          ),
          color: Color.fromARGB(255, 0xf4, 0xf4, 0xf4),
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

  InlineSpan _buildLink(BuildContext context, Iterator<Tag> iter) {
    assert(iter.current.type == TagType.LinkStart);

    final url = (iter.current as LinkStart).url;

    final recognizer = TapGestureRecognizer()
      ..onTap = () => widget.openLink(url);

    List<InlineSpan> spans = [];

    outerloop:
    while (iter.moveNext()) {
      switch (iter.current.type) {
        case TagType.LinkStart:
          throw "Nested link is not allowed.";
          break;
        case TagType.LinkEnd:
          break outerloop;
        case TagType.ItalicStart:
        case TagType.ItalicEnd:
        case TagType.DeleteStart:
        case TagType.DeleteEnd:
        case TagType.BoldStart:
        case TagType.BoldEnd:
        case TagType.FontStart:
        case TagType.FontEnd:
        case TagType.ColorStart:
        case TagType.ColorEnd:
        case TagType.SizeStart:
        case TagType.SizeEnd:
        case TagType.UnderlineStart:
        case TagType.UnderlineEnd:
          _applyStyle(context, iter.current);
          break;
        case TagType.Text:
          spans.add(TextSpan(
            recognizer: recognizer,
            text: (iter.current as Text).content,
            style: style.copyWith(color: Colors.blue),
          ));
          break;
        case TagType.Image:
          spans.add(_buildImage(context, iter.current as Image));
          break;
        case TagType.Sticker:
          spans.add(_buildSticker(context, iter.current as Sticker));
          break;
        case TagType.Metions:
        case TagType.Pid:
        case TagType.Uid:
        case TagType.AlignStart:
        case TagType.AlignEnd:
        case TagType.Rule:
        case TagType.QuoteStart:
        case TagType.QuoteEnd:
        case TagType.CollapseStart:
        case TagType.CollapseEnd:
        case TagType.TableStart:
        case TagType.TableEnd:
        case TagType.HeadingStart:
        case TagType.HeadingEnd:
        case TagType.ParagraphStart:
        case TagType.ParagraphEnd:
        case TagType.Reply:
        case TagType.TableRowStart:
        case TagType.TableRowEnd:
        case TagType.TableCellStart:
        case TagType.TableCellEnd:
          throw "Unexecpted element: ${iter.current}.";
          break;
      }
    }

    if (spans.length == 1) {
      return spans[0];
    }

    return TextSpan(children: spans);
  }

  InlineSpan _buildImage(BuildContext context, Image image) {
    var url;

    if (image.url.startsWith("./")) {
      url = "https://img.nga.178.com/attachments${image.url.substring(1)}";
    } else if (image.url.startsWith("/")) {
      url = "https://nga.178.com${image.url}";
    } else {
      url = image.url;
    }

    return WidgetSpan(
      child: CachedNetworkImage(
        imageUrl: url,
        imageBuilder: (context, imageProvider) => GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HeroPhotoViewWrapper(
                  imageProvider: CachedNetworkImageProvider(url),
                ),
              ),
            );
          },
          child: Hero(
            // FIXME: better way to create unique tag
            tag: "tag${DateTime.now().toString()}",
            child: material.Image.network(url),
          ),
        ),
        placeholder: (context, url) => Center(
          child: CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) => material.Text(
          "fialed to load image $url",
        ),
      ),
    );
  }

  InlineSpan _buildSticker(BuildContext context, Sticker sticker) {
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Container(
        margin: EdgeInsets.all(2.0),
        child: material.Image.asset(sticker.path, width: 32.0),
      ),
    );
  }

  InlineSpan _buildPid(BuildContext context, Pid pid) {
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

  InlineSpan _buildUid(BuildContext context, Uid uid) {
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
          child: material.Text(
            "@${uid.username}",
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

  InlineSpan _buildMetions(BuildContext context, Metions metions) {
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
          child: material.Text(
            "@${metions.username}",
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

  InlineSpan _buildText(BuildContext context, Text text) {
    return TextSpan(text: text.content, style: style);
  }

  _applyStyle(BuildContext context, Tag tag) {
    switch (tag.type) {
      case TagType.BoldStart:
        style = style.copyWith(fontWeight: FontWeight.w500);
        break;
      case TagType.BoldEnd:
        style = style.copyWith(fontWeight: FontWeight.w400);
        break;
      case TagType.ItalicStart:
        style = style.copyWith(fontStyle: FontStyle.italic);
        break;
      case TagType.ItalicEnd:
        style = style.copyWith(fontStyle: FontStyle.normal);
        break;
      case TagType.UnderlineStart:
      case TagType.UnderlineEnd:
        // TODO:
        break;
      case TagType.DeleteStart:
        style = style.copyWith(decoration: TextDecoration.lineThrough);
        break;
      case TagType.DeleteEnd:
        style = style.copyWith(decoration: TextDecoration.none);
        break;
      case TagType.FontStart:
      case TagType.FontEnd:
      case TagType.ColorStart:
      case TagType.ColorEnd:
      case TagType.SizeStart:
      case TagType.SizeEnd:
        break;
      default:
        break;
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
        heroAttributes: const PhotoViewHeroAttributes(tag: "someTag"),
      ),
    );
  }
}
