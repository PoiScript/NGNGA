import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ngnga/bbcode/parser.dart';
import 'package:ngnga/bbcode/tag.dart';

void main() {
  test("BBCode parser", () {
    assert(listEquals(
      parseBBCode("foo,bar,baz").toList(),
      [
        ParagraphStart(),
        Text("foo,bar,baz"),
        ParagraphEnd(),
      ],
    ));

    assert(listEquals(
      parseBBCode("[b]bold[/b]").toList(),
      [
        ParagraphStart(),
        BoldStart(),
        Text("bold"),
        BoldEnd(),
        ParagraphEnd(),
      ],
    ));

    assert(listEquals(
      parseBBCode("[b]bold[b]").toList(),
      [
        ParagraphStart(),
        Text("[b]bold[b]"),
        ParagraphEnd(),
      ],
    ));

    assert(listEquals(
      parseBBCode("A[b][quote]content[/quote]B[/b]").toList(),
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
      parseBBCode("A[b][quote]content[/quote]B[/b]").toList(),
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
  });
}
