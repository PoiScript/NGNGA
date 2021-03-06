import 'package:built_collection/built_collection.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import 'package:business/models/attachment.dart';

class AttachViewer extends StatelessWidget {
  final BuiltList<Attachment> attachs;
  final int initialPage;

  const AttachViewer({
    this.attachs,
    this.initialPage,
  })  : assert(attachs != null),
        assert(initialPage != null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: PhotoViewGallery.builder(
          scrollPhysics: const BouncingScrollPhysics(),
          itemCount: attachs.length,
          pageController: PageController(initialPage: initialPage),
          builder: (context, index) {
            final Attachment attach = attachs[index];

            return PhotoViewGalleryPageOptions(
              imageProvider: CachedNetworkImageProvider(attach.fullUrl),
              initialScale: PhotoViewComputedScale.contained,
              minScale: PhotoViewComputedScale.contained * 0.5,
              maxScale: PhotoViewComputedScale.covered * 1.1,
              heroAttributes: PhotoViewHeroAttributes(tag: attach.url),
            );
          },
          backgroundDecoration: BoxDecoration(
            color: Colors.black,
          ),
          loadingChild: Container(
            color: Colors.black,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ),
    );
  }
}
