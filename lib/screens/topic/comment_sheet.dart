import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

import 'package:ngnga/bbcode/render.dart';
import 'package:ngnga/localizations.dart';
import 'package:ngnga/models/post.dart';
import 'package:ngnga/models/user.dart';
import 'package:ngnga/utils/duration.dart';

class CommentSheet extends StatelessWidget {
  final List<PostItem> posts;
  final Map<int, User> users;

  const CommentSheet({
    Key key,
    @required this.posts,
    @required this.users,
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
                  child: Icon(Icons.comment),
                ),
                Text(
                  'Comment',
                  style: Theme.of(context).textTheme.subhead,
                ),
              ],
            ),
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index.isOdd) {
                  return Divider();
                }

                int itemIndex = index ~/ 2;

                Post post = posts[itemIndex].inner;

                if (post == null) {
                  return Text(
                    AppLocalizations.of(context).commentNotFound,
                    style: Theme.of(context)
                        .textTheme
                        .caption
                        .copyWith(fontStyle: FontStyle.italic),
                  );
                }

                return Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              users[post.userId].username,
                              style: Theme.of(context).textTheme.caption,
                            ),
                          ),
                          Text(
                            duration(
                              DateTime.now(),
                              post.createdAt,
                            ),
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ],
                      ),
                      BBCodeRender(
                        raw: post.content,
                        // TODO
                        openLink: (x) => {},
                        openPost: (x, y, z) => {},
                        openUser: (x) => {},
                      ),
                      Row(
                        children: <Widget>[
                          Spacer(),
                          Text(
                            post.vote.toString(),
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
              childCount: posts.length * 2 - 1,
              semanticIndexCallback: (Widget _, int index) =>
                  index.isEven ? index ~/ 2 : null,
            ),
          ),
        ),
      ],
    );
  }
}

// class CommentSheetConnector extends StatelessWidget {
//   final List<int> postIds;

//   const CommentSheetConnector({
//     Key key,
//     @required this.postIds,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return StoreConnector<AppState, ViewModel>(
//       model: ViewModel(postIds: postIds),
//       builder: (context, vm) => CommentSheet(
//         posts: vm.posts,
//         users: vm.users,
//       ),
//     );
//   }
// }

// class ViewModel extends BaseModel<AppState> {
//   final List<int> postIds;

//   List<PostItem> posts;
//   List<User> users;

//   ViewModel({this.postIds});

//   ViewModel.build({
//     @required this.postIds,
//     @required this.posts,
//     @required this.users,
//   });

//   @override
//   ViewModel fromStore() {
//     List<PostItem> posts = postIds.map((id) => state.posts[id]).toList();
//     return ViewModel.build(
//       postIds: postIds,
//       posts: posts,
//       users: posts.map((p) => state.users[p?.inner?.userId]).toList(),
//     );
//   }
// }
