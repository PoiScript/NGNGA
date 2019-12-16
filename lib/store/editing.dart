import 'dart:io';

import 'package:flutter/material.dart';

import 'package:ngnga/models/attachment.dart';

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

abstract class EditingState {
  const EditingState();
}

class EditingUninitialized extends EditingState {}

class EditingLoaded extends EditingState {
  final String uploadAuthCode;
  final String uploadUrl;
  final List<FileState> files;
  final List<Attachment> attachments;
  final String initialSubject;
  final String initialContent;

  const EditingLoaded({
    @required this.uploadAuthCode,
    @required this.uploadUrl,
    @required this.files,
    @required this.attachments,
    @required this.initialSubject,
    @required this.initialContent,
  })  : assert(uploadAuthCode != null),
        assert(uploadUrl != null),
        assert(attachments != null),
        assert(initialSubject != null),
        assert(initialContent != null);

  EditingLoaded copy({
    String uploadAuthCode,
    String uploadUrl,
    List<FileState> files,
    List<Attachment> attachments,
    String initialSubject,
    String initialContent,
  }) =>
      EditingLoaded(
        uploadAuthCode: uploadAuthCode ?? this.uploadAuthCode,
        uploadUrl: uploadUrl ?? this.uploadUrl,
        attachments: attachments ?? this.attachments,
        files: files ?? this.files,
        initialSubject: initialSubject ?? this.initialSubject,
        initialContent: initialContent ?? this.initialContent,
      );
}
