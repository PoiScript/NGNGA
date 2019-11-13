import 'dart:convert';

import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'package:ngnga/bbcode/render.dart';
import 'package:ngnga/models/post.dart';
import 'package:ngnga/models/user.dart';
import 'package:ngnga/store/state.dart';
import 'package:ngnga/utils/duration_to_now.dart';
import 'package:ngnga/widgets/user_dialog.dart';

import 'link_dialog.dart';

class PostDialog extends StatefulWidget {
  final int topicId, postId;
  final Map<int, User> users;
  final Map<int, TopicState> topics;
  final Map<String, String> cookies;

  PostDialog({
    @required this.topicId,
    @required this.postId,
    @required this.users,
    @required this.topics,
    @required this.cookies,
  })  : assert(topicId != null),
        assert(postId != null),
        assert(users != null),
        assert(topics != null),
        assert(cookies != null);

  @override
  _PostDialogState createState() => _PostDialogState();
}

class _PostDialogState extends State<PostDialog> {
  final List<Future<Post>> posts = [];
  final List<int> postIds = [];

  @override
  void initState() {
    super.initState();
    postIds.add(widget.postId);
    posts.add(_findPostContent(widget.topicId, widget.postId));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(maxHeight: 600.0, minHeight: 300.0),
        padding: EdgeInsets.all(16.0),
        // height: ,
        decoration: new BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(4.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: const Offset(0.0, 10.0),
            ),
          ],
        ),
        child: ListView.separated(
          reverse: true,
          itemCount: posts.length,
          separatorBuilder: (context, index) => Divider(),
          itemBuilder: (context, index) => FutureBuilder<Post>(
            future: posts[index],
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var post = snapshot.data;
                return Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          widget.users[post.userId].username,
                          style: Theme.of(context).textTheme.caption,
                        ),
                        const Spacer(),
                        Text(
                          durationToNow(post.createdAt),
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ],
                    ),
                    BBCodeRender(
                      data: post.content,
                      openLink: (url) {
                        showDialog(
                          context: context,
                          builder: (context) => LinkDialog(url),
                        );
                      },
                      openUser: (userId) {
                        showDialog(
                          context: context,
                          builder: (context) => UserDialog(userId),
                        );
                      },
                      openPost: _openPost,
                    ),
                  ],
                );
              }
              return Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }

  _openPost(int topicId, int page, int postId) {
    if (!postIds.contains(postId)) {
      setState(() {
        postIds.add(postId);
        posts.add(_findPostContent(topicId, postId));
      });
    }
  }

  Future<Post> _findPostContent(int topicId, int postId) async {
    var topic = widget.topics[topicId];
    if (topic != null) {
      var post = topic.posts.where((post) => post.id == postId);
      if (post.isNotEmpty) {
        return post.first;
      }
    }
    var response = await _fetchOnePost(topicId, postId, widget.cookies);
    return response.post;
  }
}

class PostDialogConnector extends StatelessWidget {
  final int topicId, postId;

  PostDialogConnector({
    @required this.topicId,
    @required this.postId,
  })  : assert(topicId != null),
        assert(postId != null);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ViewModel>(
      model: ViewModel(),
      builder: (context, vm) => PostDialog(
        topics: vm.topics,
        users: vm.users,
        cookies: vm.cookies,
        topicId: topicId,
        postId: postId,
      ),
    );
  }
}

class _FetchPostResponse {
  final Post post;

  _FetchPostResponse({this.post});

  factory _FetchPostResponse.fromJson(Map<String, dynamic> json) {
    return _FetchPostResponse(
      post: Post.fromJson(json["data"]["__R"].first),
    );
  }
}

Future<_FetchPostResponse> _fetchOnePost(
  int topicId,
  int postId,
  Map<String, String> cookies,
) async {
  final uri = Uri.https("nga.178.com", "read.php", {
    "pid": postId.toString(),
    "tid": topicId.toString(),
    "__output": "11",
  });

  print(uri);

  final res = await get(uri, headers: {
    "cookie":
        cookies.entries.map((entry) => "${entry.key}=${entry.value}").join(";")
  });

  final json = jsonDecode(res.body);

  return _FetchPostResponse.fromJson(json);
}

class ViewModel extends BaseModel<AppState> {
  Map<int, User> users;
  Map<int, TopicState> topics;
  Map<String, String> cookies;

  ViewModel();

  ViewModel.build({
    @required this.topics,
    @required this.users,
    @required this.cookies,
  }) : super(equals: [topics, users, cookies]);

  @override
  ViewModel fromStore() {
    return ViewModel.build(
      topics: state.topics,
      users: state.users,
      cookies: state.cookies,
    );
  }
}