import 'dart:io';

import 'package:built_value/built_value.dart';

part 'upload_file.g.dart';

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
