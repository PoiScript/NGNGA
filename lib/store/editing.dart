import 'dart:io';

import 'package:async_redux/async_redux.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';

import 'package:ngnga/models/attachment.dart';

part 'editing.g.dart';

abstract class UploadFile implements Built<UploadFile, UploadFileBuilder> {
  UploadFile._() {
    assert(!uploaded || !isUploading);
    if (uploaded) {
      assert(check != null);
      assert(code != null);
      assert(url != null);
    }
  }

  factory UploadFile([Function(UploadFileBuilder) updates]) = _$UploadFile;

  bool get isUploading;
  bool get uploaded;

  File get file;
  @nullable
  String get check;
  @nullable
  String get code;
  @nullable
  String get url;

  static void _initializeBuilder(UploadFileBuilder b) => b
    ..isUploading = false
    ..uploaded = false;
}

abstract class EditingState
    implements Built<EditingState, EditingStateBuilder> {
  EditingState._();

  factory EditingState([Function(EditingStateBuilder) updates]) =
      _$EditingState;

  bool get initialized;
  String get uploadAuthCode;
  String get uploadUrl;
  BuiltList<UploadFile> get files;
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
