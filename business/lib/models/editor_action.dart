import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';

part 'editor_action.g.dart';

class EditorAction extends EnumClass {
  static const EditorAction newTopic = _$newTopic;
  static const EditorAction newPost = _$newPost;
  static const EditorAction quote = _$quote;
  static const EditorAction reply = _$reply;
  static const EditorAction modify = _$modify;
  static const EditorAction comment = _$comment;
  static const EditorAction noop = _$noop;

  const EditorAction._(String name) : super(name);

  static BuiltSet<EditorAction> get values => _$actValues;
  static EditorAction valueOf(String name) => _$actValueOf(name);

  String toParameters() {
    switch (this) {
      case EditorAction.newTopic:
        return 'new';
      case EditorAction.quote:
        return 'quote';
      case EditorAction.reply:
        return 'reply';
      case EditorAction.modify:
        return 'modify';
      case EditorAction.comment:
        return 'reply';
      case EditorAction.newPost:
        return 'reply';
    }
    throw ArgumentError(this);
  }
}
