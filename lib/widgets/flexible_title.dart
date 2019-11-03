import 'package:flutter/material.dart';

class FlexibleTitle extends StatelessWidget {
  final double scale;
  final String title;
  final Widget subtitle;

  FlexibleTitle({
    this.scale,
    this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    Widget titleWidget;
    if (scale == 1.0) {
      titleWidget = Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: 58.0),
        height: kToolbarHeight,
        child: Text(
          title,
          style: Theme.of(context).textTheme.subhead,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      );
    } else {
      double width = MediaQuery.of(context).size.width / (1.5 - (0.5 * scale)) -
          58.0 * scale;
      titleWidget = Container(
        width: width,
        padding: EdgeInsets.only(left: 58.0 * scale),
        alignment: Alignment.centerLeft,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            subtitle,
            ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: kToolbarHeight,
              ),
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.subhead,
                ),
              ),
            )
          ],
        ),
      );
    }

    return FlexibleSpaceBar(
      title: titleWidget,
      titlePadding: EdgeInsets.all(0.0),
    );
  }
}
