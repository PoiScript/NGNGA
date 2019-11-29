import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ngnga/models/post.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class AttachViewer extends StatelessWidget {
  final List<Attachment> attachs;

  AttachViewer(this.attachs) : assert(attachs != null && attachs.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: <Widget>[
            PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              builder: _buildItem,
              itemCount: attachs.length,
              // loadingChild: widget.loadingChild,
              // backgroundDecoration: widget.backgroundDecoration,
              // pageController: widget.pageController,
              // onPageChanged: onPageChanged,
              // scrollDirection: widget.scrollDirection,
            ),
            // Container(
            //   padding: const EdgeInsets.all(20.0),
            //   child: Text(
            //     'Image ${currentIndex + 1}',
            //     style: const TextStyle(
            //       color: Colors.white,
            //       fontSize: 17.0,
            //       decoration: null,
            //     ),
            //   ),
            // )
          ],
        ),
      ),
    );
  }

  PhotoViewGalleryPageOptions _buildItem(BuildContext context, int index) {
    final Attachment item = attachs[index];

    return PhotoViewGalleryPageOptions(
      imageProvider: CachedNetworkImageProvider(
        'https://img.nga.178.com/attachments/${item.url}',
      ),
      initialScale: PhotoViewComputedScale.contained,
      minScale: PhotoViewComputedScale.contained * (0.5 + index / 10),
      maxScale: PhotoViewComputedScale.covered * 1.1,
      heroAttributes: PhotoViewHeroAttributes(tag: item.url),
    );
  }
}
