import 'package:expandable/expandable.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import './sticker.dart';
import '../bbcode.dart';

class BBCode extends StatefulWidget {
  final String data;

  BBCode(String data) : this.data = data.replaceAll("<br/>", "\n");

  @override
  _BBCodeState createState() => _BBCodeState();
}

class _BBCodeState extends State<BBCode> {
  final List<GestureRecognizer> _recognizers = <GestureRecognizer>[];

  TextStyle style;

  @override
  Widget build(BuildContext context) {
    var tags = BBCodeParser(widget.data).parse();
    var iter = tags.iterator;
    style = Theme.of(context).textTheme.body1;

    List<Widget> children = [];

    iter.moveNext();

    while (iter.current != null) {
      _applyStyle(iter.current);
      switch (iter.current.type) {
        case BBCodeTagType.Bold:
        case BBCodeTagType.Color:
        case BBCodeTagType.Delete:
        case BBCodeTagType.Font:
        case BBCodeTagType.Italics:
        case BBCodeTagType.Size:
          break;
        case BBCodeTagType.Image:
        case BBCodeTagType.Sticker:
        case BBCodeTagType.Metions:
        case BBCodeTagType.Underline:
        case BBCodeTagType.PlainLink:
        case BBCodeTagType.Text:
        case BBCodeTagType.Link:
        case BBCodeTagType.Pid:
        case BBCodeTagType.Uid:
          children.add(_buildInlines(iter));
          break;
        case BBCodeTagType.Collapse:
          children.add(_buildCollapse(iter));
          break;
        case BBCodeTagType.Quote:
          children.add(_buildQuote(iter));
          break;
        case BBCodeTagType.Table:
          children.add(_buildTable(iter));
          break;
        case BBCodeTagType.Heading:
          children.add(_buildHeading(iter));
          break;
        case BBCodeTagType.TableRow:
        case BBCodeTagType.TableCell:
          // TODO:
          iter.moveNext();
          break;
        case BBCodeTagType.Rule:
          children.add(_buildRule(iter));
          break;
        case BBCodeTagType.Align:
          // TODO:
          iter.moveNext();
          break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _buildInlines(Iterator<BBCodeTag> iter) {
    List<InlineSpan> spans = [];

    outerloop:
    do {
      _applyStyle(iter.current);
      switch (iter.current.type) {
        case BBCodeTagType.Bold:
        case BBCodeTagType.Italics:
        case BBCodeTagType.Underline:
        case BBCodeTagType.Delete:
        case BBCodeTagType.Font:
        case BBCodeTagType.Color:
        case BBCodeTagType.Size:
          break;
        case BBCodeTagType.Text:
          spans.add(TextSpan(text: iter.current.content, style: style));
          break;
        case BBCodeTagType.Image:
          spans.add(_buildImage(iter));
          break;
        case BBCodeTagType.PlainLink:
          spans.add(_buildPlainLink(iter));
          break;
        case BBCodeTagType.Link:
          spans.add(_buildLink(iter));
          break;
        case BBCodeTagType.Sticker:
          spans.add(_buildSticker(iter));
          break;
        case BBCodeTagType.Metions:
          spans.add(_buildMetions(iter));
          break;
        case BBCodeTagType.Pid:
          // TODO: Handle this case.
          break;
        case BBCodeTagType.Uid:
          // TODO: Handle this case.
          break;
        case BBCodeTagType.Align:
          // TODO: Handle this case.
          break;
        case BBCodeTagType.Rule:
        case BBCodeTagType.Quote:
        case BBCodeTagType.Collapse:
        case BBCodeTagType.Table:
        case BBCodeTagType.TableRow:
        case BBCodeTagType.TableCell:
        case BBCodeTagType.Heading:
          break outerloop;
      }
    } while (iter.moveNext());

    return Container(
      child: RichText(text: TextSpan(children: spans)),
    );
  }

  Widget _buildCollapse(Iterator<BBCodeTag> iter) {
    assert(iter.current.type == BBCodeTagType.Collapse);
    assert(iter.current.beg == true);

    String collapseDescription = iter.current.content;
    List<Widget> children = [];

    while (iter.moveNext()) {
      _applyStyle(iter.current);
      switch (iter.current.type) {
        case BBCodeTagType.Italics:
        case BBCodeTagType.Delete:
        case BBCodeTagType.Bold:
        case BBCodeTagType.Font:
        case BBCodeTagType.Color:
        case BBCodeTagType.Size:
        case BBCodeTagType.Underline:
          // style tag, ignoring
          break;
        case BBCodeTagType.Collapse:
          assert(iter.current.beg == false, 'Nested collapse is not allowed');
          break;
        case BBCodeTagType.Image:
        case BBCodeTagType.Text:
        case BBCodeTagType.PlainLink:
        case BBCodeTagType.Link:
        case BBCodeTagType.Sticker:
        case BBCodeTagType.Metions:
        case BBCodeTagType.Pid:
        case BBCodeTagType.Uid:
          children.add(_buildInlines(iter));
          break;
        case BBCodeTagType.Quote:
          assert(iter.current.beg == true);
          children.add(_buildQuote(iter));
          break;
        case BBCodeTagType.Table:
          assert(iter.current.beg == true);
          children.add(_buildTable(iter));
          break;
        case BBCodeTagType.Heading:
          children.add(_buildHeading(iter));
          break;
        case BBCodeTagType.TableRow:
        case BBCodeTagType.TableCell:
          break;
        case BBCodeTagType.Rule:
          children.add(_buildRule(iter));
          break;
        case BBCodeTagType.Align:
          // TODO: Handle this case.
          break;
      }

      if (iter.current.type == BBCodeTagType.Collapse) {
        assert(iter.current.beg == false);
        iter.moveNext();
        break;
      }
    }

    return ExpandablePanel(
      header: Text(collapseDescription ?? '点击显示隐藏的内容'),
      expanded: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
      tapHeaderToExpand: true,
      hasIcon: false,
    );
  }

  Widget _buildQuote(Iterator<BBCodeTag> iter) {
    assert(iter.current.type == BBCodeTagType.Quote);
    assert(iter.current.beg == true);

    List<Widget> children = [];

    while (iter.moveNext()) {
      _applyStyle(iter.current);
      switch (iter.current.type) {
        case BBCodeTagType.Quote:
          if (iter.current.beg == true) {
            children.add(_buildQuote(iter));
          }
          break;
        case BBCodeTagType.Italics:
        case BBCodeTagType.Delete:
        case BBCodeTagType.Bold:
        case BBCodeTagType.Font:
        case BBCodeTagType.Color:
        case BBCodeTagType.Size:
        case BBCodeTagType.Underline:
          // style tag, ignoring
          break;
        case BBCodeTagType.Text:
        case BBCodeTagType.Image:
        case BBCodeTagType.PlainLink:
        case BBCodeTagType.Link:
        case BBCodeTagType.Sticker:
        case BBCodeTagType.Metions:
        case BBCodeTagType.Pid:
        case BBCodeTagType.Uid:
          children.add(_buildInlines(iter));
          break;
        case BBCodeTagType.Collapse:
          assert(iter.current.beg == true);
          children.add(_buildCollapse(iter));
          break;
        case BBCodeTagType.Table:
          assert(iter.current.beg == true);
          children.add(_buildTable(iter));
          break;
        case BBCodeTagType.Heading:
          children.add(_buildHeading(iter));
          break;
        case BBCodeTagType.TableRow:
        case BBCodeTagType.TableCell:
          break;
        case BBCodeTagType.Rule:
          children.add(_buildRule(iter));
          break;
        case BBCodeTagType.Align:
          // TODO: Handle this case.
          break;
      }

      if (iter.current.type == BBCodeTagType.Quote) {
        assert(iter.current.beg == false);
        iter.moveNext();
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
        padding: EdgeInsets.only(left: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  TextSpan _buildImage(Iterator<BBCodeTag> iter) {
    assert(iter.current.type == BBCodeTagType.Image);

    // TODO:

    return TextSpan(text: "IMAGE", style: TextStyle(color: Colors.red));
  }

  WidgetSpan _buildSticker(Iterator<BBCodeTag> iter) {
    assert(iter.current.type == BBCodeTagType.Sticker);

    return WidgetSpan(child: Sticker(iter.current.content));
  }

  TextSpan _buildLink(Iterator<BBCodeTag> iter) {
    assert(iter.current.type == BBCodeTagType.Link);

    final TapGestureRecognizer recognizer = TapGestureRecognizer()
      ..onTap = () {};
    _recognizers.add(recognizer);

    return TextSpan(
      text: "LINK",
      style: TextStyle(color: Colors.red),
      recognizer: recognizer,
    );
  }

  TextSpan _buildPlainLink(Iterator<BBCodeTag> iter) {
    assert(iter.current.type == BBCodeTagType.PlainLink);

    final TapGestureRecognizer recognizer = TapGestureRecognizer()
      ..onTap = () {};
    _recognizers.add(recognizer);

    return TextSpan(
      text: iter.current.content,
      style: TextStyle(color: Colors.blue),
      recognizer: recognizer,
    );
  }

  TextSpan _buildMetions(Iterator<BBCodeTag> iter) {
    assert(iter.current.type == BBCodeTagType.Metions);

    return TextSpan(text: "METIONS", style: TextStyle(color: Colors.red));
  }

  Widget _buildRule(Iterator<BBCodeTag> iter) {
    assert(iter.current.type == BBCodeTagType.Rule);

    return DecoratedBox(
      child: const SizedBox(),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(width: 5.0, color: Colors.grey.shade300),
        ),
      ),
    );
  }

  Widget _buildTable(Iterator<BBCodeTag> iter) {
    assert(iter.current.type == BBCodeTagType.Table);

    // TODO:

    return Text("TABLE", style: TextStyle(color: Colors.red));
  }

  Widget _buildHeading(Iterator<BBCodeTag> iter) {
    assert(iter.current.type == BBCodeTagType.Heading);

    // TODO:

    return Text("HEADING", style: TextStyle(color: Colors.red));
  }

  _applyStyle(BBCodeTag tag) {
    switch (tag.type) {
      case BBCodeTagType.Bold:
        style = style.copyWith(
          fontWeight: tag.beg ? FontWeight.bold : FontWeight.normal,
        );
        break;
      case BBCodeTagType.Italics:
        style = style.copyWith(
          fontStyle: tag.beg ? FontStyle.italic : FontStyle.normal,
        );
        break;
      case BBCodeTagType.Underline:
        // TODO:
        // style = style.copyWith(
        //   decoration:
        //       tag.beg ? TextDecoration.underline : TextDecoration.none,
        // );
        break;
      case BBCodeTagType.Delete:
        style = style.copyWith(
          decoration:
              tag.beg ? TextDecoration.lineThrough : TextDecoration.none,
        );
        break;
      case BBCodeTagType.Font:
      case BBCodeTagType.Color:
      case BBCodeTagType.Size:
        break;
      default:
        break;
    }
  }
}
