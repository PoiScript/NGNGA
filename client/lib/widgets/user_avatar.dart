import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:business/models/user.dart';

class UserAvatar extends StatelessWidget {
  final double size;
  final User user;
  final int index;

  const UserAvatar({
    Key key,
    @required this.size,
    @required this.user,
    @required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final letterAvatar = CircleAvatar(
      radius: size / 2,
      child: Text(
        user.username[0].toUpperCase(),
        style: Theme.of(context)
            .textTheme
            .body2
            .copyWith(color: Colors.white, fontSize: size / 2),
      ),
      backgroundColor: _numberToColor(
        user.id,
        Theme.of(context).brightness == Brightness.dark,
      ),
    );

    if (user.avatars.isEmpty) return letterAvatar;

    // wrap the avatar with a sized box,
    // so it can take up enough space even when loading image
    return SizedBox(
      width: size,
      height: size,
      child: CachedNetworkImage(
        // user can have mulitples avatars, so we pick one of them randomly to display
        imageUrl: user.avatars[index % user.avatars.length],
        imageBuilder: (context, imageProvider) => CircleAvatar(
          radius: size / 2,
          backgroundImage: imageProvider,
          backgroundColor: Colors.transparent,
        ),
        errorWidget: (context, url, error) => letterAvatar,
      ),
    );
  }

  Color _numberToColor(int number, bool dark) {
    int hash = 0;

    for (var rune in number.toString().runes) {
      hash = rune + ((hash << 5) - hash);
    }

    int h = hash % 360;

    return HSLColor.fromAHSL(
      1.0,
      h.toDouble(),
      0.3,
      dark ? 0.5 : 0.8,
    ).toColor();
  }
}
