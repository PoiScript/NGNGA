import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:business/bbcode/parser.dart';
import 'package:business/bbcode/tag.dart';

void main() {
  test('BBCode parsing', () {
    assert(listEquals(
      parseBBCode('foo,bar,baz').toList(),
      [
        ParagraphStartTag(),
        TextTag('foo,bar,baz'),
        ParagraphEndTag(),
      ],
    ));

    assert(listEquals(
      parseBBCode('[b]bold[/b]').toList(),
      [
        ParagraphStartTag(),
        BoldStartTag(),
        TextTag('bold'),
        BoldEndTag(),
        ParagraphEndTag(),
      ],
    ));

    assert(listEquals(
      parseBBCode('[b]bold[b]').toList(),
      [
        ParagraphStartTag(),
        TextTag('[b]bold[b]'),
        ParagraphEndTag(),
      ],
    ));

    assert(listEquals(
      parseBBCode('A[b][quote]content[/quote]B[/b]').toList(),
      [
        ParagraphStartTag(),
        TextTag('A'),
        BoldStartTag(),
        ParagraphEndTag(),
        QuoteStartTag(),
        ParagraphStartTag(),
        TextTag('content'),
        ParagraphEndTag(),
        QuoteEndTag(),
        ParagraphStartTag(),
        TextTag('B'),
        BoldEndTag(),
        ParagraphEndTag(),
      ],
    ));

    assert(listEquals(
      parseBBCode('A[b][quote]content[/quote]B[/b]').toList(),
      [
        ParagraphStartTag(),
        TextTag('A'),
        BoldStartTag(),
        ParagraphEndTag(),
        QuoteStartTag(),
        ParagraphStartTag(),
        TextTag('content'),
        ParagraphEndTag(),
        QuoteEndTag(),
        ParagraphStartTag(),
        TextTag('B'),
        BoldEndTag(),
        ParagraphEndTag(),
      ],
    ));

    assert(listEquals(
      parseBBCode('[collapse]A[quote]B[quote]C[/quote]D[/quote]E[/collapse]')
          .toList(),
      [
        CollapseStartTag(null),
        ParagraphStartTag(),
        TextTag('A'),
        ParagraphEndTag(),
        QuoteStartTag(),
        ParagraphStartTag(),
        TextTag('B'),
        ParagraphEndTag(),
        QuoteStartTag(),
        ParagraphStartTag(),
        TextTag('C'),
        ParagraphEndTag(),
        QuoteEndTag(),
        ParagraphStartTag(),
        TextTag('D'),
        ParagraphEndTag(),
        QuoteEndTag(),
        ParagraphStartTag(),
        TextTag('E'),
        ParagraphEndTag(),
        CollapseEndTag(),
      ],
    ));

    assert(listEquals(
      parseBBCode('[collapse][quote]AB[/quote][/collapse]').toList(),
      [
        CollapseStartTag(null),
        QuoteStartTag(),
        ParagraphStartTag(),
        TextTag('AB'),
        ParagraphEndTag(),
        QuoteEndTag(),
        CollapseEndTag(),
      ],
    ));

    assert(listEquals(
      parseBBCode('[collapse][quote][/collapse][/quote]').toList(),
      [
        CollapseStartTag(null),
        ParagraphStartTag(),
        TextTag('[quote]'),
        ParagraphEndTag(),
        CollapseEndTag(),
        ParagraphStartTag(),
        TextTag('[/quote]'),
        ParagraphEndTag(),
      ],
    ));

    assert(listEquals(
      parseBBCode('[collapse]A[quote]B[quote]C[/collapse]D[/quote]E[/quote]')
          .toList(),
      [
        CollapseStartTag(null),
        ParagraphStartTag(),
        TextTag('A[quote]B[quote]C'),
        ParagraphEndTag(),
        CollapseEndTag(),
        ParagraphStartTag(),
        TextTag('D[/quote]E[/quote]'),
        ParagraphEndTag(),
      ],
    ));

    assert(listEquals(
      parseBBCode('[quote][collapse][url]example.com[/url][/collapse][/quote]')
          .toList(),
      [
        QuoteStartTag(),
        CollapseStartTag(null),
        ParagraphStartTag(),
        LinkStartTag('example.com'),
        TextTag('example.com'),
        LinkEndTag(),
        ParagraphEndTag(),
        CollapseEndTag(),
        QuoteEndTag(),
      ],
    ));

    assert(listEquals(
      parseBBCode('[color=red]Red[color=blue]Blue[/color]Red[/color]').toList(),
      [
        ParagraphStartTag(),
        ColorStartTag('red'),
        TextTag('Red'),
        ColorStartTag('blue'),
        TextTag('Blue'),
        ColorEndTag(),
        TextTag('Red'),
        ColorEndTag(),
        ParagraphEndTag(),
      ],
    ));

    assert(listEquals(
      parseBBCode('[list] item 1 [*]item 2  [*] [*] [*]  item 3[/list]')
          .toList(),
      [
        ListItemStartTag(),
        ParagraphStartTag(),
        TextTag('item 1'),
        ParagraphEndTag(),
        ListItemEndTag(),
        ListItemStartTag(),
        ParagraphStartTag(),
        TextTag('item 2'),
        ParagraphEndTag(),
        ListItemEndTag(),
        ListItemStartTag(),
        ParagraphStartTag(),
        TextTag('item 3'),
        ParagraphEndTag(),
        ListItemEndTag(),
      ],
    ));
  });
}
