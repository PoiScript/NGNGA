import 'dart:io';

import 'package:flutter/material.dart';

abstract class AttachmentItem {}

class RemoteAttachment extends AttachmentItem {
  final String url;

  RemoteAttachment(this.url);
}

class LocalAttachment extends AttachmentItem {
  final File file;

  LocalAttachment(this.file);
}

class UploadedAttachment extends AttachmentItem {
  final String checksum;
  final String code;
  final String url;
  final File file;

  UploadedAttachment({
    this.checksum,
    this.code,
    this.url,
    this.file,
  });
}

abstract class EditingState {
  const EditingState();
}

class EditingUninitialized extends EditingState {}

class EditingLoaded extends EditingState {
  final String uploadAuthCode;
  final String uploadUrl;
  final List<AttachmentItem> attachs;
  final String initialSubject;
  final String initialContent;

  const EditingLoaded({
    @required this.uploadAuthCode,
    @required this.uploadUrl,
    @required this.attachs,
    @required this.initialSubject,
    @required this.initialContent,
  })  : assert(uploadAuthCode != null),
        assert(uploadUrl != null),
        assert(attachs != null),
        assert(initialSubject != null),
        assert(initialContent != null);

  EditingLoaded copy({
    String uploadAuthCode,
    String uploadUrl,
    List<AttachmentItem> attachs,
    String initialSubject,
    String initialContent,
  }) =>
      EditingLoaded(
        uploadAuthCode: uploadAuthCode ?? this.uploadAuthCode,
        uploadUrl: uploadUrl ?? this.uploadUrl,
        attachs: attachs ?? this.attachs,
        initialSubject: initialSubject ?? this.initialSubject,
        initialContent: initialContent ?? this.initialContent,
      );
}
