import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

import 'package:ngnga/bbcode/render.dart';
import 'package:ngnga/localizations.dart';
import 'package:ngnga/models/attachment.dart';
import 'package:ngnga/store/editing.dart';

class EditorAttachs extends StatelessWidget {
  final List<Attachment> attachments;

  final List<FileState> files;
  final Function(File) selectFile;
  final Function(int) unselectFile;
  final Future<void> Function(int) uploadFile;

  final ValueChanged<String> insertImage;

  EditorAttachs({
    @required this.attachments,
    @required this.files,
    @required this.selectFile,
    @required this.unselectFile,
    @required this.uploadFile,
    @required this.insertImage,
  })  : assert(files != null),
        assert(selectFile != null),
        assert(insertImage != null),
        assert(unselectFile != null),
        assert(uploadFile != null);

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty && files.isEmpty) {
      return Center(
        child: FlatButton.icon(
          icon: Icon(Icons.add_photo_alternate),
          label: Text(AppLocalizations.of(context).addImage),
          onPressed: _pickImage,
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      physics: AlwaysScrollableScrollPhysics(),
      children: <Widget>[
        for (Attachment attachment in attachments)
          GridTile(
            child: _AttachmentRect(attachment: attachment),
            footer: _FileUploadedBar(
              insertImage: () => insertImage(attachment.url),
            ),
          ),
        for (int index = 0; index < files.length; index++)
          GridTile(
            child: _FileImageRect(file: files[index].file),
            footer: _buildGridFooter(context, index),
          ),
        InkResponse(
          onTap: _pickImage,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Center(child: Icon(Icons.add_photo_alternate)),
          ),
        ),
      ],
    );
  }

  Widget _buildGridFooter(BuildContext context, int index) {
    FileState state = files[index];
    if (state is FileSelected) {
      return _FileSelectedBar(
        uploadFile: () => uploadFile(index),
      );
    }

    if (state is FileUploading) {
      return const _FileUploadingBar();
    }

    if (state is FileUploaded) {
      return _FileUploadedBar(
        insertImage: () => insertImage(state.url),
      );
    }

    return null;
  }

  _pickImage() async {
    File file = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (file != null) selectFile(file);
  }
}

class _AttachmentRect extends StatelessWidget {
  final Attachment attachment;

  const _AttachmentRect({
    Key key,
    @required this.attachment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // FIXME: better way to create unique tag
    String tag = 'tag${DateTime.now().toString()}';

    return ClipRRect(
      borderRadius: BorderRadius.circular(4.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HeroPhotoViewWrapper(
                tag: tag,
                imageProvider: CachedNetworkImageProvider(attachment.fullUrl),
              ),
            ),
          );
        },
        child: Hero(
          tag: tag,
          child: Image(
            image: CachedNetworkImageProvider(attachment.thumbUrl),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class _FileImageRect extends StatelessWidget {
  final File file;

  const _FileImageRect({
    Key key,
    @required this.file,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // FIXME: better way to create unique tag
    String tag = 'tag${DateTime.now().toString()}';
    ImageProvider imageProvider = FileImage(file);

    return ClipRRect(
      borderRadius: BorderRadius.circular(4.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HeroPhotoViewWrapper(
                tag: tag,
                imageProvider: imageProvider,
              ),
            ),
          );
        },
        child: Hero(
          tag: tag,
          child: Image(image: imageProvider, fit: BoxFit.cover),
        ),
      ),
    );
  }
}

class _FileSelectedBar extends StatelessWidget {
  final Future<void> Function() uploadFile;

  const _FileSelectedBar({
    Key key,
    @required this.uploadFile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: GridTileBar(
        backgroundColor: Color.fromRGBO(0, 0, 0, 0.2),
        leading: Icon(Icons.file_upload),
        title: Text(AppLocalizations.of(context).upload),
      ),
      onTap: uploadFile,
    );
  }
}

class _FileUploadingBar extends StatelessWidget {
  const _FileUploadingBar();

  @override
  Widget build(BuildContext context) {
    return GridTileBar(
      backgroundColor: Color.fromRGBO(0, 0, 0, 0.2),
      title: Text(AppLocalizations.of(context).uploading),
    );
  }
}

class _FileUploadedBar extends StatelessWidget {
  final VoidCallback insertImage;

  const _FileUploadedBar({
    Key key,
    @required this.insertImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: GridTileBar(
        backgroundColor: Color.fromRGBO(0, 0, 0, 0.2),
        leading: Icon(Icons.insert_photo),
        title: Text(AppLocalizations.of(context).insert),
      ),
      onTap: insertImage,
    );
  }
}
