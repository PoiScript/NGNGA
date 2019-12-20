import 'package:async_redux/async_redux.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:business/models/editor_action.dart';

import '../../models/attachment.dart';
import 'upload_file.dart';

part 'editing_state.g.dart';

abstract class EditingState
    implements Built<EditingState, EditingStateBuilder> {
  EditingState._();

  factory EditingState([Function(EditingStateBuilder) updates]) =
      _$EditingState;

  EditorAction get editorAction;
  @nullable
  int get categoryId;
  @nullable
  int get topicId;
  @nullable
  int get postId;
  bool get initialized;
  String get uploadAuthCode;
  String get uploadUrl;
  BuiltList<UploadFile> get files;
  BuiltList<Attachment> get attachments;
  Event<String> get subjectEvt;
  Event<String> get contentEvt;

  static void _initializeBuilder(EditingStateBuilder b) => b
    ..editorAction = EditorAction.noop
    ..initialized = false
    ..uploadAuthCode = ''
    ..uploadUrl = ''
    ..subjectEvt = Event.spent()
    ..contentEvt = Event.spent();
}
