import 'package:flutter/material.dart';

import '../bbcode.dart';
import '../peekable.dart';

class BBCode extends StatelessWidget {
  final String data;

  BBCode(this.data);

  @override
  Widget build(BuildContext context) {
    var tags = BBCodeParser(
      this.data.replaceAll("<br/>", "\n").replaceAll(RegExp(r"\n{2,}"), "\n"),
    ).parse();
    var iter = PeekableIterator(tags.iterator);

    List<Widget> children = [];

    while (iter.peek() != null) {
      switch (iter.peek().type) {
        case BBCodeTagType.Bold:
        case BBCodeTagType.Color:
        case BBCodeTagType.Delete:
        case BBCodeTagType.Font:
        case BBCodeTagType.Image:
        case BBCodeTagType.Italics:
        case BBCodeTagType.Metions:
        case BBCodeTagType.Size:
        case BBCodeTagType.Sticker:
        case BBCodeTagType.Text:
        case BBCodeTagType.Underline:
        case BBCodeTagType.Url:
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
          iter.moveNext();
          break;
        case BBCodeTagType.Rule:
          children.add(_buildRule(iter));
          break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  static Widget _buildInlines(PeekableIterator<BBCodeTag> iter) {
    TextStyle style = TextStyle(
      color: Colors.black,
      decoration: TextDecoration.none,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
    );
    List<TextSpan> spans = [];

    outerloop:
    while (iter.peek() != null) {
      var tag = iter.peek();
      switch (tag.type) {
        case BBCodeTagType.Bold:
          style = style.copyWith(
            fontWeight: tag.beg ? FontWeight.w600 : FontWeight.normal,
          );
          break;
        case BBCodeTagType.Italics:
          style = style.copyWith(
            fontStyle: tag.beg ? FontStyle.italic : FontStyle.normal,
          );
          break;
        case BBCodeTagType.Underline:
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
        case BBCodeTagType.Text:
          spans.add(TextSpan(text: tag.content, style: style));
          break;
        case BBCodeTagType.Font:
          // TODO: Handle this case.
          break;
        case BBCodeTagType.Color:
          // TODO: Handle this case.
          break;
        case BBCodeTagType.Size:
          // TODO: Handle this case.
          break;
        case BBCodeTagType.Image:
          spans.add(_buildImage(iter));
          break;
        case BBCodeTagType.Url:
          spans.add(_buildLink(iter));
          break;
        case BBCodeTagType.Sticker:
          spans.add(_buildSticker(iter));
          break;
        case BBCodeTagType.Metions:
          spans.add(_buildMetions(iter));
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
      iter.moveNext();
    }

    assert(style.decoration == TextDecoration.none);
    assert(style.fontWeight == FontWeight.normal);
    assert(style.fontStyle == FontStyle.normal);

    return Container(
      child: RichText(text: TextSpan(children: spans)),
    );
  }

  static Widget _buildCollapse(PeekableIterator<BBCodeTag> iter) {
    iter.moveNext();
    assert(iter.current.type == BBCodeTagType.Collapse);
    assert(iter.current.beg == true);

    List<Widget> children = [];

    outerloop:
    while (iter.peek() != null) {
      switch (iter.peek().type) {
        case BBCodeTagType.Collapse:
          if (iter.peek().beg == true) {
            children.add(_buildCollapse(iter));
          } else {
            iter.moveNext();
            break outerloop;
          }
          break;
        case BBCodeTagType.Italics:
        case BBCodeTagType.Delete:
        case BBCodeTagType.Text:
        case BBCodeTagType.Bold:
        case BBCodeTagType.Font:
        case BBCodeTagType.Color:
        case BBCodeTagType.Size:
        case BBCodeTagType.Underline:
        case BBCodeTagType.Image:
        case BBCodeTagType.Url:
        case BBCodeTagType.Sticker:
        case BBCodeTagType.Metions:
          children.add(_buildInlines(iter));
          break;
        case BBCodeTagType.Quote:
          assert(iter.peek().beg == true);
          children.add(_buildQuote(iter));
          break;
        case BBCodeTagType.Table:
          assert(iter.peek().beg == true);
          children.add(_buildTable(iter));
          break;
        case BBCodeTagType.Heading:
          children.add(_buildHeading(iter));
          break;
        case BBCodeTagType.TableRow:
        case BBCodeTagType.TableCell:
          iter.moveNext();
          break;
        case BBCodeTagType.Rule:
          children.add(_buildRule(iter));
          break;
      }
    }

    return ExpansionPanelList(
      children: [
        ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return Text("EXPAN", style: TextStyle(color: Colors.red));
          },
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
          isExpanded: false,
        )
      ],
    );
  }

  static Widget _buildQuote(PeekableIterator<BBCodeTag> iter) {
    iter.moveNext();
    assert(iter.current.type == BBCodeTagType.Quote);
    assert(iter.current.beg == true);

    List<Widget> children = [];

    outerloop:
    while (iter.peek() != null) {
      switch (iter.peek().type) {
        case BBCodeTagType.Quote:
          if (iter.peek().beg == true) {
            children.add(_buildQuote(iter));
          } else {
            iter.moveNext();
            break outerloop;
          }
          break;
        case BBCodeTagType.Italics:
        case BBCodeTagType.Delete:
        case BBCodeTagType.Text:
        case BBCodeTagType.Bold:
        case BBCodeTagType.Font:
        case BBCodeTagType.Color:
        case BBCodeTagType.Size:
        case BBCodeTagType.Underline:
        case BBCodeTagType.Image:
        case BBCodeTagType.Url:
        case BBCodeTagType.Sticker:
        case BBCodeTagType.Metions:
          children.add(_buildInlines(iter));
          break;
        case BBCodeTagType.Collapse:
          assert(iter.peek().beg == true);
          children.add(_buildCollapse(iter));
          break;
        case BBCodeTagType.Table:
          assert(iter.peek().beg == true);
          children.add(_buildTable(iter));
          break;
        case BBCodeTagType.Heading:
          children.add(_buildHeading(iter));
          break;
        case BBCodeTagType.TableRow:
        case BBCodeTagType.TableCell:
          iter.moveNext();
          break;
        case BBCodeTagType.Rule:
          children.add(_buildRule(iter));
          break;
      }
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(2.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  static TextSpan _buildImage(PeekableIterator<BBCodeTag> iter) {
    iter.moveNext();
    assert(iter.current.type == BBCodeTagType.Image);

    return TextSpan(text: "IMAGE", style: TextStyle(color: Colors.red));
  }

  static TextSpan _buildSticker(PeekableIterator<BBCodeTag> iter) {
    iter.moveNext();
    assert(iter.current.type == BBCodeTagType.Sticker);

    return TextSpan(text: "STICKER", style: TextStyle(color: Colors.red));
  }

  static TextSpan _buildLink(PeekableIterator<BBCodeTag> iter) {
    iter.moveNext();
    assert(iter.current.type == BBCodeTagType.Url);

    return TextSpan(text: "LINK", style: TextStyle(color: Colors.red));
  }

  static TextSpan _buildMetions(PeekableIterator<BBCodeTag> iter) {
    iter.moveNext();
    assert(iter.current.type == BBCodeTagType.Metions);

    return TextSpan(text: "METIONS", style: TextStyle(color: Colors.red));
  }

  static Widget _buildRule(PeekableIterator<BBCodeTag> iter) {
    iter.moveNext();
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

  static Widget _buildTable(PeekableIterator<BBCodeTag> iter) {
    iter.moveNext();
    assert(iter.current.type == BBCodeTagType.Table);

    return Text("TABLE", style: TextStyle(color: Colors.red));
  }

  static Widget _buildHeading(PeekableIterator<BBCodeTag> iter) {
    iter.moveNext();
    assert(iter.current.type == BBCodeTagType.Heading);

    return Text("HEADING", style: TextStyle(color: Colors.red));
  }
}
