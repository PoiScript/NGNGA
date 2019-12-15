import 'dart:io';

import 'package:async_redux/async_redux.dart';
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
  final Event<String> setSubjectEvt;
  final Event<String> setContentEvt;

  const EditingLoaded({
    @required this.uploadAuthCode,
    @required this.uploadUrl,
    @required this.attachs,
    @required this.setSubjectEvt,
    @required this.setContentEvt,
  })  : assert(uploadAuthCode != null),
        assert(uploadUrl != null),
        assert(attachs != null),
        assert(setSubjectEvt != null),
        assert(setContentEvt != null);

  EditingLoaded copy({
    String uploadAuthCode,
    String uploadUrl,
    List<AttachmentItem> attachs,
    Event<String> setSubjectEvt,
    Event<String> setContentEvt,
  }) =>
      EditingLoaded(
        uploadAuthCode: uploadAuthCode ?? this.uploadAuthCode,
        uploadUrl: uploadUrl ?? this.uploadUrl,
        attachs: attachs ?? this.attachs,
        setSubjectEvt: setSubjectEvt ?? this.setSubjectEvt,
        setContentEvt: setContentEvt ?? this.setContentEvt,
      );
}
