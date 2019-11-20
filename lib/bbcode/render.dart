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
    style = Theme.of(context).textTheme.body1;

    List<Widget> _children = [];

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
          _children.add(_buildParagraph(context, iter));
          break;
        case TagType.Reply:
          _children.add(_buildReply(context, iter.current as Reply, true));
          break;
        case TagType.Image:
        case TagType.Sticker:
        case TagType.Metions:
        case TagType.UnderlineStart:
        case TagType.PlainLink:
        case TagType.Text:
        case TagType.LinkStart:
        case TagType.Pid:
        case TagType.Uid:
          throw "Execpted block element, fount ${iter.current.type}.";
          break;
        case TagType.CollapseStart:
          _children.add(_buildCollapse(context, iter));
          break;
        case TagType.QuoteStart:
          _children.add(_buildQuote(context, iter));
          break;
        case TagType.TableStart:
          _children.add(_buildTable(context, iter));
          break;
        case TagType.HeadingStart:
          _children.add(_buildHeading(context, iter));
          break;
        case TagType.TableRowStart:
        case TagType.TableCellStart:
          throw "TableRow and TableCell are not allowed outside of Table.";
          break;
        case TagType.Rule:
          _children.add(_buildRule(context));
          break;
        case TagType.AlignStart:
          // TODO:
          iter.moveNext();
          break;
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
          throw "Excepted start or empty element.";
          break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _children,
    );
  }

  Widget _buildParagraph(BuildContext context, Iterator<Tag> iter) {
    assert(iter.current.type == TagType.ParagraphStart);

    List<InlineSpan> _spans = [];

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
          _spans.add(_buildText(context, iter.current as Text));
          break;
        case TagType.Image:
          _spans.add(_buildImage(context, iter.current as Image));
          break;
        case TagType.PlainLink:
          _spans.add(_buildPlainLink(context, iter.current as PlainLink));
          break;
        case TagType.LinkStart:
          _spans.add(_buildLink(context, iter));
          break;
        case TagType.LinkEnd:
          throw "Unexpected end element ${iter.current.type}.";
          break;
        case TagType.Sticker:
          _spans.add(_buildSticker(context, iter.current as Sticker));
          break;
        case TagType.Metions:
          _spans.add(_buildMetions(context, iter.current as Metions));
          break;
        case TagType.Pid:
          _spans.add(_buildPid(context, iter.current as Pid));
          break;
        case TagType.Uid:
          _spans.add(_buildUid(context, iter.current as Uid));
          break;
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
        case TagType.Reply:
          throw "Execpted inline element, fount ${iter.current.type}.";
          break;
        case TagType.TableRowStart:
        case TagType.TableRowEnd:
        case TagType.TableCellStart:
        case TagType.TableCellEnd:
          throw "TableRow and TableCell are not allowed outside of Table.";
          break;
      }
    }

    return Container(
      padding: EdgeInsets.only(bottom: 6.0),
      child: RichText(
        text: TextSpan(children: _spans),
      ),
    );
  }

  Widget _buildCollapse(BuildContext context, Iterator<Tag> iter) {
    assert(iter.current.type == TagType.CollapseStart);

    String _description = (iter.current as CollapseStart).description;
    List<Widget> _children = [];

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
          _children.add(_buildParagraph(context, iter));
          break;
        case TagType.Reply:
          _children.add(_buildReply(context, iter.current as Reply, false));
          break;
        case TagType.Image:
        case TagType.Text:
        case TagType.PlainLink:
        case TagType.LinkStart:
        case TagType.LinkEnd:
        case TagType.Sticker:
        case TagType.Metions:
        case TagType.Pid:
        case TagType.Uid:
          throw "Execpted block element, fount ${iter.current.type}.";
          break;
        case TagType.QuoteStart:
          _children.add(_buildQuote(context, iter));
          break;
        case TagType.TableStart:
          _children.add(_buildTable(context, iter));
          break;
        case TagType.HeadingStart:
          _children.add(_buildHeading(context, iter));
          break;
        case TagType.TableRowStart:
        case TagType.TableRowEnd:
        case TagType.TableCellStart:
        case TagType.TableCellEnd:
          throw "TableRow and TableCell are not allowed outside of Table.";
          break;
        case TagType.Rule:
          _children.add(_buildRule(context));
          break;
        case TagType.AlignStart:
          // TODO: Handle this case.
          break;
        case TagType.QuoteEnd:
        case TagType.TableEnd:
        case TagType.HeadingEnd:
        case TagType.AlignEnd:
        case TagType.ParagraphEnd:
          throw "Unexpected end element ${iter.current.type}.";
      }
    }

    return Collapse(
      description: _description,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: _children,
      ),
    );
  }

  Widget _buildQuote(BuildContext context, Iterator<Tag> iter) {
    assert(iter.current.type == TagType.QuoteStart);

    List<Widget> _children = [];

    outerloop:
    while (iter.moveNext()) {
      switch (iter.current.type) {
        case TagType.QuoteStart:
          _children.add(_buildQuote(context, iter));
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
          _children.add(_buildReply(context, iter.current as Reply, false));
          break;
        case TagType.Text:
        case TagType.Image:
        case TagType.PlainLink:
        case TagType.LinkStart:
        case TagType.LinkEnd:
        case TagType.Sticker:
        case TagType.Metions:
        case TagType.Pid:
        case TagType.Uid:
          throw "Execpted block element, fount ${iter.current.type}.";
          break;
        case TagType.ParagraphStart:
          _children.add(_buildParagraph(context, iter));
          break;
        case TagType.CollapseStart:
          _children.add(_buildCollapse(context, iter));
          break;
        case TagType.TableStart:
          _children.add(_buildTable(context, iter));
          break;
        case TagType.HeadingStart:
          _children.add(_buildHeading(context, iter));
          break;
        case TagType.TableRowStart:
        case TagType.TableCellStart:
        case TagType.TableRowEnd:
        case TagType.TableCellEnd:
          throw "TableRow and TableCell are not allowed outside of Table.";
          break;
        case TagType.Rule:
          _children.add(_buildRule(context));
          break;
        case TagType.AlignStart:
          // TODO: Handle this case.
          break;
        case TagType.TableEnd:
        case TagType.CollapseEnd:
        case TagType.HeadingEnd:
        case TagType.AlignEnd:
        case TagType.ParagraphEnd:
          throw "Unexpected end element ${iter.current.type}.";
          break;
      }
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
        children: _children,
      ),
    );
  }

  TextSpan _buildLink(BuildContext context, Iterator<Tag> iter) {
    assert(iter.current.type == TagType.LinkStart);

    final url = (iter.current as LinkStart).url;

    final recognizer = TapGestureRecognizer()
      ..onTap = () => widget.openLink(url);

    List<InlineSpan> _spans = [];

    outerloop:
    while (iter.moveNext()) {
      switch (iter.current.type) {
        case TagType.LinkStart:
        case TagType.PlainLink:
          throw "Nested Link is not allowed.";
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
          _spans.add(TextSpan(
            recognizer: recognizer,
            text: (iter.current as Text).content,
            style: style.copyWith(color: Colors.blue),
          ));
          break;
        case TagType.Image:
          _spans.add(_buildImage(context, iter.current as Image));
          break;
        case TagType.Sticker:
          _spans.add(_buildSticker(context, iter.current as Sticker));
          break;
        case TagType.Metions:
          _spans.add(_buildMetions(context, iter.current as Metions));
          break;
        case TagType.Pid:
          _spans.add(_buildPid(context, iter.current as Pid));
          break;
        case TagType.Uid:
          _spans.add(_buildUid(context, iter.current as Uid));
          break;
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
          throw "Execpted inline element, fount ${iter.current.type}.";
          break;
        case TagType.TableRowStart:
        case TagType.TableRowEnd:
        case TagType.TableCellStart:
        case TagType.TableCellEnd:
          throw "TableRow and TableCell are not allowed outside of Table.";
          break;
      }
    }

    return TextSpan(children: _spans);
  }

  WidgetSpan _buildImage(BuildContext context, Image image) {
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

  WidgetSpan _buildSticker(BuildContext context, Sticker sticker) {
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Container(
        margin: EdgeInsets.all(2.0),
        child: material.Image.asset(sticker.path, width: 32.0),
      ),
    );
  }

  WidgetSpan _buildPid(BuildContext context, Pid pid) {
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

  WidgetSpan _buildUid(BuildContext context, Uid uid) {
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

  TextSpan _buildPlainLink(BuildContext context, PlainLink link) {
    return TextSpan(
      text: link.url,
      style: TextStyle(color: Colors.blue),
      recognizer: TapGestureRecognizer()
        ..onTap = () => widget.openLink(link.url),
    );
  }

  WidgetSpan _buildMetions(BuildContext context, Metions metions) {
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

  TextSpan _buildText(BuildContext context, Text text) {
    return TextSpan(
      text: text.content,
      style: style,
    );
  }

  Widget _buildRule(
    BuildContext context,
  ) {
    return DecoratedBox(
      child: const SizedBox(),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(width: 5.0, color: Colors.grey.shade300),
        ),
      ),
    );
  }

  Widget _buildTable(BuildContext context, Iterator<Tag> iter) {
    assert(iter.current.type == TagType.TableStart);

    // TODO:

    return material.Text("TABLE", style: TextStyle(color: Colors.red));
  }

  Widget _buildHeading(BuildContext context, Iterator<Tag> iter) {
    assert(iter.current.type == TagType.HeadingStart);

    // TODO:

    return material.Text("HEADING", style: TextStyle(color: Colors.red));
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
        throw "Excepted style element, found ${tag.type}";
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
