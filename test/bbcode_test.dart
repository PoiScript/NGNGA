import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/bbcode.dart';

void main() {
  test("BBCode parser", () {
    assert(listEquals(
      BBCodeParser("foo,bar,baz").parse().toList(),
      [
        BBCodeTag.text("foo,bar,baz"),
      ],
    ));

    assert(listEquals(
      BBCodeParser("[b]bold[/b]").parse().toList(),
      [
        BBCodeTag.boldBeg(),
        BBCodeTag.text("bold"),
        BBCodeTag.boldEnd(),
      ],
    ));

    assert(listEquals(
      BBCodeParser("[b]bold[b]").parse().toList(),
      [
        BBCodeTag.text("[b]bold[b]"),
      ],
    ));
  });
}
