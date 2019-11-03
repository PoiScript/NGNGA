import 'package:flutter/material.dart';

import '../../models/post.dart';
import '../../widgets/bbcode.dart';
import '../../widgets/duration_to_now.dart';
import '../../models/user.dart';

class PostRow extends StatelessWidget {
  final Post post;

  PostRow(this.post);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                post.userId.toString(),
                style: Theme.of(context).textTheme.caption,
              ),
              Spacer(),
              DurationToNow(
                post.createdAt,
                style: Theme.of(context).textTheme.caption,
              ),
            ],
          ),
          BBCode(post.content),
        ],
      ),
    );
  }
}
