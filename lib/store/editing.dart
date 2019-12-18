import 'dart:io';

import 'package:async_redux/async_redux.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';

import 'package:ngnga/models/attachment.dart';

part 'editing.g.dart';

abstract class FileState {
  File get file;

  const FileState();
}

class FileSelected extends FileState {
  final File file;

  const FileSelected(this.file);
}

class FileUploading extends FileState {
  final File file;

  const FileUploading(this.file);
}

class FileUploaded extends FileState {
  final String check;
  final String code;
  final String url;
  final File file;

  const FileUploaded({this.check, this.code, this.url, this.file});
}

abstract class EditingState
    implements Built<EditingState, EditingStateBuilder> {
  EditingState._();

  factory EditingState([Function(EditingStateBuilder) updates]) =
      _$EditingState;

  bool get initialized;
  String get uploadAuthCode;
  String get uploadUrl;
  BuiltList<FileState> get files;
  BuiltList<Attachment> get attachments;
  Event<String> get subjectEvt;
  Event<String> get contentEvt;

  static void _initializeBuilder(EditingStateBuilder b) => b
    ..initialized = false
    ..uploadAuthCode = ''
    ..uploadUrl = ''
    ..subjectEvt = Event.spent()
    ..contentEvt = Event.spent();
}
