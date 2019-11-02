import 'package:flutter_test/flutter_test.dart';

import '../lib/peekable.dart';

void main() {
  test("Peekable iterator", () {
    var iter = PeekableIterator([1, 2, 3].iterator);

    expect(iter.peek(), equals(1));
    expect(iter.moveNext(), equals(true));
    expect(iter.current, equals(1));

    expect(iter.moveNext(), equals(true));
    expect(iter.current, equals(2));

    expect(iter.peek(), equals(3));
    expect(iter.peek(), equals(3));

    expect(iter.moveNext(), equals(true));
    expect(iter.current, equals(3));

    expect(iter.peek(), equals(null));
    expect(iter.moveNext(), equals(false));
    expect(iter.current, equals(null));
  });
}
