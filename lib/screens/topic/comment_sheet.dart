import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';

import 'package:ngnga/bbcode/render.dart';
import 'package:ngnga/models/post.dart';
import 'package:ngnga/store/state.dart';

class CommentSheet extends StatelessWidget {
  final List<PostItem> posts;

  const CommentSheet({
    Key key,
    @required this.posts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      separatorBuilder: (context, index) => Divider(),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        if (posts[index] == null) {
          return Text(
            'Comment not found',
            style: Theme.of(context)
                .textTheme
                .caption
                .copyWith(fontStyle: FontStyle.italic),
          );
        }

        return BBCodeRender(
          raw: posts[index].inner.content,
          // TODO
          openLink: (x) => {},
          openPost: (x, y, z) => {},
          openUser: (x) => {},
        );
      },
    );
  }
}

class CommentSheetConnector extends StatelessWidget {
  final List<int> postIds;

  const CommentSheetConnector({
    Key key,
    @required this.postIds,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ViewModel>(
      model: ViewModel(postIds: postIds),
      builder: (context, vm) => CommentSheet(
        posts: vm.posts,
      ),
    );
  }
}

class ViewModel extends BaseModel<AppState> {
  final List<int> postIds;

  List<PostItem> posts;

  ViewModel({this.postIds});

  ViewModel.build({
    @required this.postIds,
    @required this.posts,
  });

  @override
  ViewModel fromStore() {
    return ViewModel.build(
      postIds: postIds,
      posts: postIds.map((id) => state.posts[id]).toList(),
    );
  }
}
