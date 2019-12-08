import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

import 'package:ngnga/bbcode/render.dart';
import 'package:ngnga/models/post.dart';

class AttachmentSheet extends StatelessWidget {
  final List<Attachment> attachments;

  const AttachmentSheet({
    Key key,
    @required this.attachments,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: BouncingScrollPhysics(),
      slivers: <Widget>[
        SliverStickyHeader(
          header: Container(
            color: Theme.of(context).cardColor,
            child: Row(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(16.0),
                  child: Icon(Icons.attach_file),
                ),
                Text(
                  'Attachment',
                  style: Theme.of(context).textTheme.subhead,
                ),
              ],
            ),
          ),
          sliver: SliverGrid.count(
            crossAxisCount: 3,
            children: attachments.map(_buildAttachmentRect).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentRect(Attachment attachment) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: ClipRRect(
        child: CachedNetworkImage(
          imageUrl: 'https://img.nga.178.com/attachments/${attachment.url}',
          imageBuilder: (context, imageProvider) => GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HeroPhotoViewWrapper(
                    imageProvider: CachedNetworkImageProvider(
                      'https://img.nga.178.com/attachments/${attachment.url}',
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
      ),
    );
  }
}