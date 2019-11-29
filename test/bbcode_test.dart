import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ngnga/bbcode/parser.dart';
import 'package:ngnga/bbcode/tag.dart';

void main() {
  test('BBCode parser', () {
    assert(listEquals(
      parseBBCode('foo,bar,baz'),
      [
        ParagraphStartTag(),
        TextTag('foo,bar,baz'),
        ParagraphEndTag(),
      ],
    ));

    assert(listEquals(
      parseBBCode('[b]bold[/b]'),
      [
        ParagraphStartTag(),
        BoldStartTag(),
        TextTag('bold'),
        BoldEndTag(),
        ParagraphEndTag(),
      ],
    ));

    assert(listEquals(
      parseBBCode('[b]bold[b]'),
      [
        ParagraphStartTag(),
        TextTag('[b]bold[b]'),
        ParagraphEndTag(),
      ],
    ));

    assert(listEquals(
      parseBBCode('A[b][quote]content[/quote]B[/b]'),
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
      parseBBCode('A[b][quote]content[/quote]B[/b]'),
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
      parseBBCode('[collapse]A[quote]B[quote]C[/quote]D[/quote]E[/collapse]'),
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
      parseBBCode('[collapse][quote]AB[/quote][/collapse]'),
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
      parseBBCode('[collapse][quote][/collapse][/quote]'),
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
      parseBBCode('[collapse]A[quote]B[quote]C[/collapse]D[/quote]E[/quote]'),
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
      parseBBCode('[quote][collapse][url]example.com[/url][/collapse][/quote]'),
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
  });
}
