import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

import 'package:ngnga/bbcode/render.dart';
import 'package:ngnga/localizations.dart';
import 'package:ngnga/store/state.dart';

class EditorAttachs extends StatelessWidget {
  final List<AttachmentItem> attachs;
  final Function(LocalAttachment) addAttachment;
  final Function(LocalAttachment) removeAttachment;
  final Future<void> Function(LocalAttachment) uploadAttachment;

  final ValueChanged<String> insertImage;

  EditorAttachs({
    @required this.attachs,
    @required this.addAttachment,
    @required this.removeAttachment,
    @required this.uploadAttachment,
    @required this.insertImage,
  })  : assert(attachs != null),
        assert(addAttachment != null),
        assert(insertImage != null),
        assert(removeAttachment != null),
        assert(uploadAttachment != null);

  @override
  Widget build(BuildContext context) {
    if (attachs.isEmpty) {
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
        for (AttachmentItem attach in attachs)
          if (attach is RemoteAttachment)
            RemoteAttachmentGridTile(
              attach: attach,
              insertImage: insertImage,
            )
          else if (attach is LocalAttachment)
            LocalAttachmentGridTile(
              attach: attach,
              upload: () => uploadAttachment(attach),
            )
          else if (attach is UploadedAttachment)
            UploadedAttachmentGridTile(
              attach: attach,
              insertImage: insertImage,
            ),
        InkResponse(
          onTap: _pickImage,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Center(child: Icon(Icons.add)),
          ),
        ),
      ],
    );
  }

  _pickImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) addAttachment(LocalAttachment(image));
  }
}

class RemoteAttachmentGridTile extends StatelessWidget {
  final RemoteAttachment attach;
  final ValueChanged<String> insertImage;

  const RemoteAttachmentGridTile({
    Key key,
    @required this.attach,
    @required this.insertImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridTile(
      child: _networkImageRect(attach.url),
      footer: _insertImageFooter(
        context,
        () => insertImage(attach.url),
      ),
    );
  }
}

class LocalAttachmentGridTile extends StatefulWidget {
  final LocalAttachment attach;
  final VoidCallback upload;

  const LocalAttachmentGridTile({
    Key key,
    @required this.attach,
    @required this.upload,
  }) : super(key: key);

  @override
  _LocalAttachmentGridTileState createState() =>
      _LocalAttachmentGridTileState();
}

class _LocalAttachmentGridTileState extends State<LocalAttachmentGridTile> {
  bool isUploading = false;

  @override
  Widget build(BuildContext context) {
    return GridTile(
      child: _fileImageRect(context, widget.attach.file),
      footer: GestureDetector(
        child: GridTileBar(
          backgroundColor: Color.fromRGBO(0, 0, 0, 0.2),
          leading: isUploading ? null : Icon(Icons.file_upload),
          title: Text(
            isUploading
                ? AppLocalizations.of(context).uploading
                : AppLocalizations.of(context).upload,
          ),
        ),
        onTap: isUploading
            ? null
            : () {
                widget.upload();
                setState(() => isUploading = true);
              },
      ),
    );
  }
}

class UploadedAttachmentGridTile extends StatelessWidget {
  final UploadedAttachment attach;
  final ValueChanged<String> insertImage;

  const UploadedAttachmentGridTile({
    Key key,
    @required this.attach,
    @required this.insertImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridTile(
      child: _fileImageRect(context, attach.file),
      footer: _insertImageFooter(
        context,
        () => insertImage(attach.url),
      ),
    );
  }
}

Widget _networkImageRect(String url) {
  return ClipRRect(
    child: CachedNetworkImage(
      imageUrl: 'https://img.nga.178.com/attachments/$url',
      imageBuilder: (context, imageProvider) => GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HeroPhotoViewWrapper(
                imageProvider: CachedNetworkImageProvider(
                  'https://img.nga.178.com/attachments/$url',
                ),
              ),
            ),
          );
        },
        child: Hero(
          // FIXME: better way to create unique tag
          tag: 'tag${DateTime.now().toString()}',
          child: Image(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
    ),
    borderRadius: BorderRadius.circular(4.0),
  );
}

Widget _fileImageRect(BuildContext context, File file) {
  return ClipRRect(
    child: GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HeroPhotoViewWrapper(
              imageProvider: FileImage(file),
            ),
          ),
        );
      },
      child: Hero(
        // FIXME: better way to create unique tag
        tag: 'tag${DateTime.now().toString()}',
        child: Image.file(file, fit: BoxFit.cover),
      ),
    ),
    borderRadius: BorderRadius.circular(4.0),
  );
}

Widget _insertImageFooter(BuildContext context, VoidCallback insertImage) {
  return GestureDetector(
    child: GridTileBar(
      backgroundColor: Color.fromRGBO(0, 0, 0, 0.2),
      leading: Icon(Icons.insert_photo),
      title: Text(AppLocalizations.of(context).insert),
    ),
    onTap: insertImage,
  );
}
