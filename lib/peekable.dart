class PeekableIterator<E> extends Iterator<E> {
  final Iterator<E> _iterator;
  E _peeked;

  PeekableIterator(this._iterator);

  bool moveNext() {
    if (_peeked != null) {
      _peeked = null;
      return true;
    } else {
      return _iterator.moveNext();
    }
  }

  E peek() {
    if (_peeked == null) {
      _iterator.moveNext();
      _peeked = _iterator.current;
    }
    return _peeked;
  }

  E get current {
    return _peeked ?? _iterator.current;
  }
}
