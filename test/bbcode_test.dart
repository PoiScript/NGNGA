import 'package:flutter_test/flutter_test.dart';

import 'package:ngnga/bbcode/parser.dart';
import 'package:ngnga/bbcode/tag.dart';

void main() {
  test("BBCode parser", () {
    assert(listEquals(
      parseBBCode("foo,bar,baz"),
      [
        ParagraphStart(),
        Text("foo,bar,baz"),
        ParagraphEnd(),
      ],
    ));

    assert(listEquals(
      parseBBCode("[b]bold[/b]"),
      [
        ParagraphStart(),
        BoldStart(),
        Text("bold"),
        BoldEnd(),
        ParagraphEnd(),
      ],
    ));

    assert(listEquals(
      parseBBCode("[b]bold[b]"),
      [
        ParagraphStart(),
        Text("[b]bold[b]"),
        ParagraphEnd(),
      ],
    ));

    assert(listEquals(
      parseBBCode("A[b][quote]content[/quote]B[/b]"),
      [
        ParagraphStart(),
        Text("A"),
        BoldStart(),
        ParagraphEnd(),
        QuoteStart(),
        ParagraphStart(),
        Text("content"),
        ParagraphEnd(),
        QuoteEnd(),
        ParagraphStart(),
        Text("B"),
        BoldEnd(),
        ParagraphEnd(),
      ],
    ));

    assert(listEquals(
      parseBBCode("A[b][quote]content[/quote]B[/b]"),
      [
        ParagraphStart(),
        Text("A"),
        BoldStart(),
        ParagraphEnd(),
        QuoteStart(),
        ParagraphStart(),
        Text("content"),
        ParagraphEnd(),
        QuoteEnd(),
        ParagraphStart(),
        Text("B"),
        BoldEnd(),
        ParagraphEnd(),
      ],
    ));

    assert(listEquals(
      parseBBCode("[collapse]A[quote]B[quote]C[/quote]D[/quote]E[/collapse]"),
      [
        CollapseStart(null),
        ParagraphStart(),
        Text("A"),
        ParagraphEnd(),
        QuoteStart(),
        ParagraphStart(),
        Text("B"),
        ParagraphEnd(),
        QuoteStart(),
        ParagraphStart(),
        Text("C"),
        ParagraphEnd(),
        QuoteEnd(),
        ParagraphStart(),
        Text("D"),
        ParagraphEnd(),
        QuoteEnd(),
        ParagraphStart(),
        Text("E"),
        ParagraphEnd(),
        CollapseEnd(),
      ],
    ));

    assert(listEquals(
      parseBBCode("[collapse][quote]AB[/quote][/collapse]"),
      [
        CollapseStart(null),
        QuoteStart(),
        ParagraphStart(),
        Text("AB"),
        ParagraphEnd(),
        QuoteEnd(),
        CollapseEnd(),
      ],
    ));

    assert(listEquals(
      parseBBCode("[collapse][quote][/collapse][/quote]"),
      [
        CollapseStart(null),
        ParagraphStart(),
        Text("[quote]"),
        ParagraphEnd(),
        CollapseEnd(),
        ParagraphStart(),
        Text("[/quote]"),
        ParagraphEnd(),
      ],
    ));

    assert(listEquals(
      parseBBCode("[collapse]A[quote]B[quote]C[/collapse]D[/quote]E[/quote]"),
      [
        CollapseStart(null),
        ParagraphStart(),
        Text("A[quote]B[quote]C"),
        ParagraphEnd(),
        CollapseEnd(),
        ParagraphStart(),
        Text("D[/quote]E[/quote]"),
        ParagraphEnd(),
      ],
    ));

    assert(listEquals(
      parseBBCode("[quote][collapse][url]example.com[/url][/collapse][/quote]"),
      [
        QuoteStart(),
        CollapseStart(null),
        ParagraphStart(),
        LinkStart("example.com"),
        Text("example.com"),
        LinkEnd(),
        ParagraphEnd(),
        CollapseEnd(),
        QuoteEnd(),
      ],
    ));
  });
}
