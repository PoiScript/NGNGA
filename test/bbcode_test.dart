import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/bbcode.dart';

void main() {
  test("BBCode parser", () {
    assert(listEquals(
      parseBBCode("foo,bar,baz").toList(),
      [
        BBCodeTag.paragraphBeg(),
        BBCodeTag.text("foo,bar,baz"),
        BBCodeTag.paragraphEnd(),
      ],
    ));

    assert(listEquals(
      parseBBCode("[b]bold[/b]").toList(),
      [
        BBCodeTag.paragraphBeg(),
        BBCodeTag.boldBeg(),
        BBCodeTag.text("bold"),
        BBCodeTag.boldEnd(),
        BBCodeTag.paragraphEnd(),
      ],
    ));

    assert(listEquals(
      parseBBCode("[b]bold[b]").toList(),
      [
        BBCodeTag.paragraphBeg(),
        BBCodeTag.text("[b]bold[b]"),
        BBCodeTag.paragraphEnd(),
      ],
    ));

    assert(listEquals(
      parseBBCode("A[b][quote]content[/quote]B[/b]").toList(),
      [
        BBCodeTag.paragraphBeg(),
        BBCodeTag.text("A"),
        BBCodeTag.boldBeg(),
        BBCodeTag.paragraphEnd(),
        BBCodeTag.quoteBeg(),
        BBCodeTag.paragraphBeg(),
        BBCodeTag.text("content"),
        BBCodeTag.paragraphEnd(),
        BBCodeTag.quoteEnd(),
        BBCodeTag.paragraphBeg(),
        BBCodeTag.text("B"),
        BBCodeTag.boldEnd(),
        BBCodeTag.paragraphEnd(),
      ],
    ));

    assert(listEquals(
      parseBBCode("A[b][quote]content[/quote]B[/b]").toList(),
      [
        BBCodeTag.paragraphBeg(),
        BBCodeTag.text("A"),
        BBCodeTag.boldBeg(),
        BBCodeTag.paragraphEnd(),
        BBCodeTag.quoteBeg(),
        BBCodeTag.paragraphBeg(),
        BBCodeTag.text("content"),
        BBCodeTag.paragraphEnd(),
        BBCodeTag.quoteEnd(),
        BBCodeTag.paragraphBeg(),
        BBCodeTag.text("B"),
        BBCodeTag.boldEnd(),
        BBCodeTag.paragraphEnd(),
      ],
    ));
  });
}
