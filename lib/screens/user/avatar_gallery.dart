import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class AvatarsGallery extends StatelessWidget {
  final List<String> avatars;

  AvatarsGallery(this.avatars) : assert(avatars != null && avatars.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: PhotoViewGallery.builder(
          scrollPhysics: const BouncingScrollPhysics(),
          itemCount: avatars.length,
          builder: (context, index) => PhotoViewGalleryPageOptions(
            imageProvider: CachedNetworkImageProvider(avatars[index]),
            initialScale: PhotoViewComputedScale.contained,
            minScale: PhotoViewComputedScale.contained * 0.5,
            maxScale: PhotoViewComputedScale.covered * 1.1,
            heroAttributes: PhotoViewHeroAttributes(tag: avatars[index]),
          ),
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
