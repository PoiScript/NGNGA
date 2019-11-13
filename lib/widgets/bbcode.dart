import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:async_redux/async_redux.dart';
import 'package:http/http.dart';

import 'package:ngnga/models/post.dart';
import 'package:ngnga/models/user.dart';
import 'package:ngnga/store/state.dart';
import 'package:ngnga/bbcode/render.dart';

class BBCode extends StatefulWidget {
  final String data;

  final Map<int, User> users;
  final Map<int, TopicState> topics;
  final Map<String, String> cookies;

  BBCode({
    @required this.data,
    @required this.users,
    @required this.topics,
    @required this.cookies,
  })  : assert(data != null),
        assert(users != null),
        assert(topics != null),
        assert(cookies != null);

  @override
  BBCodeState createState() => BBCodeState();
}

class BBCodeState extends State<BBCode> {
  @override
  Widget build(BuildContext context) {
    return BBCodeRender(
      data: widget.data,
      openUser: _openUserDialog,
      openLink: _openLinkDialog,
      openPost: _openPostDialog,
    );
  }

  _openLinkDialog(String url) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Open Link?'),
          content: Text('This is the content of the material dialog'),
          actions: <Widget>[
            FlatButton(
                onPressed: () {
                  _dismissDialog();
                },
                child: Text('Close')),
            FlatButton(
              onPressed: () {
                print('HelloWorld!');
                _dismissDialog();
              },
              child: Text('Print HelloWorld!'),
            )
          ],
        );
      },
    );
  }

  Future<String> _findPostContent(int topicId, int postId) async {
    print("$topicId, $postId");
    var topic = widget.topics[topicId];
    if (topic != null) {
      print('found topic');
      print('$topic');
      var post = topic.posts.singleWhere((post) => post.id == postId);
      print('$post');
      if (post != null) {
        print('found post');
        return post.content;
      }
      print('not found');
    }
    print('not found');
    var response = await _fetchOnePost(topicId, postId, widget.cookies);
    return response.post.content;
  }

  _openPostDialog(int topicId, int page, int postId) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        contentPadding: EdgeInsets.all(16.0),
        children: <Widget>[
          FutureBuilder(
            future: _findPostContent(topicId, postId),
            builder: (context, snapshot) => snapshot.hasData
                ? BBCodeConnector(snapshot.data)
                : Center(child: CircularProgressIndicator()),
          )
        ],
      ),
    );
  }

  _openUserDialog(int userId) {}

  _dismissDialog() {
    Navigator.pop(context);
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
  final uri = Uri.https("nga.178.com", "thread.php", {
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

class BBCodeConnector extends StatelessWidget {
  final String data;

  BBCodeConnector(this.data) : assert(data != null);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ViewModel>(
      model: ViewModel(),
      builder: (BuildContext context, ViewModel vm) => BBCode(
        topics: vm.topics,
        users: vm.users,
        cookies: vm.cookies,
        data: data,
      ),
    );
  }
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
