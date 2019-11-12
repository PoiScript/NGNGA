import 'package:expandable/expandable.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/material.dart' hide Text, Image;
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/sticker.dart';

import './tag.dart';
import './parser.dart';

class BBCode extends StatefulWidget {
  final String data;

  BBCode(String data) : this.data = data.replaceAll("<br/>", "\n");

  @override
  _BBCodeState createState() => _BBCodeState();
}

class _BBCodeState extends State<BBCode> {
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
          _applyStyle(iter.current);
          break;
        case TagType.ParagraphStart:
          _children.add(_buildParagraph(iter));
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
          _children.add(_buildCollapse(iter));
          break;
        case TagType.QuoteStart:
          _children.add(_buildQuote(iter));
          break;
        case TagType.TableStart:
          _children.add(_buildTable(iter));
          break;
        case TagType.HeadingStart:
          _children.add(_buildHeading(iter));
          break;
        case TagType.TableRowStart:
        case TagType.TableCellStart:
          throw "TableRow and TableCell are not allowed outside of Table.";
          break;
        case TagType.Rule:
          _children.add(_buildRule());
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

  Widget _buildParagraph(Iterator<Tag> iter) {
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
          _applyStyle(iter.current);
          break;
        case TagType.Text:
          _spans.add(TextSpan(
            text: (iter.current as Text).content,
            style: style,
          ));
          break;
        case TagType.Image:
          _spans.add(_buildImage(iter.current as Image));
          break;
        case TagType.PlainLink:
          _spans.add(_buildPlainLink(iter.current as PlainLink));
          break;
        case TagType.LinkStart:
          _spans.add(_buildLink(iter));
          break;
        case TagType.LinkEnd:
          throw "Unexpected end element ${iter.current.type}.";
          break;
        case TagType.Sticker:
          _spans.add(_buildSticker(iter.current as Sticker));
          break;
        case TagType.Metions:
          _spans.add(_buildMetions(iter.current as Metions));
          break;
        case TagType.Pid:
          _spans.add(_buildPid(iter.current as Pid));
          break;
        case TagType.Uid:
          _spans.add(_buildUid(iter.current as Uid));
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
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: RichText(
        text: TextSpan(children: _spans),
      ),
    );
  }

  Widget _buildCollapse(Iterator<Tag> iter) {
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
          _applyStyle(iter.current);
          break;
        case TagType.ParagraphStart:
          _children.add(_buildParagraph(iter));
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
          _children.add(_buildQuote(iter));
          break;
        case TagType.TableStart:
          _children.add(_buildTable(iter));
          break;
        case TagType.HeadingStart:
          _children.add(_buildHeading(iter));
          break;
        case TagType.TableRowStart:
        case TagType.TableRowEnd:
        case TagType.TableCellStart:
        case TagType.TableCellEnd:
          throw "TableRow and TableCell are not allowed outside of Table.";
          break;
        case TagType.Rule:
          _children.add(_buildRule());
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

    return Container(
      color: Colors.grey[200],
      margin: EdgeInsets.all(8.0),
      child: ExpandablePanel(
        header: material.Text(
          _description ?? '点击显示隐藏的内容',
          style: style,
        ),
        expanded: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: _children,
        ),
        tapHeaderToExpand: true,
        hasIcon: false,
      ),
    );
  }

  Widget _buildQuote(Iterator<Tag> iter) {
    assert(iter.current.type == TagType.QuoteStart);

    List<Widget> _children = [];

    outerloop:
    while (iter.moveNext()) {
      switch (iter.current.type) {
        case TagType.QuoteStart:
          _children.add(_buildQuote(iter));
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
          _applyStyle(iter.current);
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
          _children.add(_buildParagraph(iter));
          break;
        case TagType.CollapseStart:
          _children.add(_buildCollapse(iter));
          break;
        case TagType.TableStart:
          _children.add(_buildTable(iter));
          break;
        case TagType.HeadingStart:
          _children.add(_buildHeading(iter));
          break;
        case TagType.TableRowStart:
        case TagType.TableCellStart:
        case TagType.TableRowEnd:
        case TagType.TableCellEnd:
          throw "TableRow and TableCell are not allowed outside of Table.";
          break;
        case TagType.Rule:
          _children.add(_buildRule());
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

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(width: 5.0, color: Colors.grey.shade300),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 8.0 + 5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _children,
        ),
      ),
    );
  }

  TextSpan _buildLink(Iterator<Tag> iter) {
    assert(iter.current.type == TagType.LinkStart);

    var url = (iter.current as LinkStart).url;
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
          _applyStyle(iter.current);
          break;
        case TagType.Text:
          _spans.add(TextSpan(
            text: (iter.current as Text).content,
            style: style,
          ));
          break;
        case TagType.Image:
          _spans.add(_buildImage(iter.current as Image));
          break;
        case TagType.Sticker:
          _spans.add(_buildSticker(iter.current as Sticker));
          break;
        case TagType.Metions:
          _spans.add(_buildMetions(iter.current as Metions));
          break;
        case TagType.Pid:
          _spans.add(_buildPid(iter.current as Pid));
          break;
        case TagType.Uid:
          _spans.add(_buildUid(iter.current as Uid));
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

    return TextSpan(
      style: TextStyle(color: Colors.red),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          launch(url);
        },
      children: _spans,
    );
  }

  WidgetSpan _buildImage(Image image) {
    // FIXME: better way to resolve attachmet url
    var url =
        Uri.https("img.nga.178.com", "").resolve("attachments/${image.url}");
    var imgUrl = url.toString();

    return WidgetSpan(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HeroPhotoViewWrapper(
                imageProvider: NetworkImage(imgUrl),
              ),
            ),
          );
        },
        child: Hero(
          // FIXME: better way to create unique tag
          tag: "tag${DateTime.now().toString()}",
          child: material.Image.network(imgUrl),
        ),
      ),
    );
  }

  WidgetSpan _buildSticker(Sticker sticker) {
    return WidgetSpan(
      alignment: material.PlaceholderAlignment.middle,
      child: material.Image.asset(
        stickerNameToPath[sticker.name],
        width: 32.0,
      ),
    );
  }

  TextSpan _buildPid(Pid pid) {
    return TextSpan(
      text: pid.content,
      style: TextStyle(color: Colors.red),
      recognizer: TapGestureRecognizer()..onTap = () {},
    );
  }

  TextSpan _buildUid(Uid uid) {
    return TextSpan(
      text: uid.username,
      style: TextStyle(color: Colors.red),
      recognizer: TapGestureRecognizer()..onTap = () {},
    );
  }

  TextSpan _buildPlainLink(PlainLink link) {
    return TextSpan(
      text: link.url,
      style: TextStyle(color: Colors.blue),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          launch(link.url);
        },
    );
  }

  TextSpan _buildMetions(Metions metions) {
    return TextSpan(text: "METIONS", style: TextStyle(color: Colors.red));
  }

  Widget _buildRule() {
    return DecoratedBox(
      child: const SizedBox(),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(width: 5.0, color: Colors.grey.shade300),
        ),
      ),
    );
  }

  Widget _buildTable(Iterator<Tag> iter) {
    assert(iter.current.type == TagType.TableStart);

    // TODO:

    return material.Text("TABLE", style: TextStyle(color: Colors.red));
  }

  Widget _buildHeading(Iterator<Tag> iter) {
    assert(iter.current.type == TagType.HeadingStart);

    // TODO:

    return material.Text("HEADING", style: TextStyle(color: Colors.red));
  }

  _applyStyle(Tag tag) {
    switch (tag.type) {
      case TagType.BoldStart:
        style = style.copyWith(fontWeight: FontWeight.bold);
        break;
      case TagType.BoldEnd:
        style = style.copyWith(fontWeight: FontWeight.normal);
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
