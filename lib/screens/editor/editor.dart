import 'dart:convert';

import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'package:ngnga/bbcode/render.dart';
import 'package:ngnga/store/state.dart';

class _PrepareEditResponse {
  final String content;
  final String subject;
  final String attachUrl;

  _PrepareEditResponse({
    this.content,
    this.subject,
    this.attachUrl,
  });

  factory _PrepareEditResponse.fromJson(Map<String, dynamic> json) {
    if (json['code'] is int && json['code'] == 0) {
      return _PrepareEditResponse(
        content: json['result'][0]['content'],
        subject: json['result'][0]['subject'],
        attachUrl: json['result'][0]['attach_url'],
      );
    } else {
      return _PrepareEditResponse();
    }
  }
}

const int ACTION_NEWTOPIC = 0;
const int ACTION_QUOTE = 1;
const int ACTION_REPLY = 2;
const int ACTION_MODIFY = 3;
const int ACTION_COMMENT = 4;

class EditorPage extends StatefulWidget {
  final int action;
  final int categoryId;
  final int topicId;
  final int postId;
  final List<String> cookies;

  EditorPage({
    @required this.action,
    @required this.categoryId,
    @required this.topicId,
    @required this.postId,
    @required this.cookies,
    List<String> cookis,
  })  : assert(cookies != null),
        assert(action != ACTION_NEWTOPIC ||
            (categoryId != null && topicId == null && postId == null)),
        assert(
            action != ACTION_QUOTE || (categoryId == null && topicId != null)),
        assert(
            action != ACTION_REPLY || (categoryId == null && topicId != null)),
        assert(
            action != ACTION_MODIFY || (categoryId == null && topicId != null)),
        assert(action != ACTION_COMMENT ||
            (categoryId == null && topicId != null));

  @override
  _EditorPageState createState() => _EditorPageState();
}

enum DisplayMode {
  BBCode,
  RichText,
}

class _EditorPageState extends State<EditorPage> {
  TextEditingController _controller = TextEditingController();
  DisplayMode _displayMode = DisplayMode.BBCode;
  bool isLoading = true;
  String subject;
  String attachUrl;

  @override
  void initState() {
    super.initState();
    _prepareEdit().then((res) {
      setState(() {
        isLoading = false;
        _controller.text = res.content;
        subject = res.subject;
        attachUrl = res.attachUrl;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        elevation: 0.0,
        title: Text(
          "Editor",
          style:
              Theme.of(context).textTheme.body1.copyWith(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.subject, color: Colors.black),
            onPressed: () {
              setState(() {
                _displayMode = DisplayMode.RichText;
              });
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.subject,
              color: Colors.black,
            ),
            onPressed: () {
              setState(() {
                _displayMode = DisplayMode.BBCode;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(8.0),
          child: _displayMode == DisplayMode.BBCode
              ? TextField(
                  keyboardType: TextInputType.multiline,
                  minLines: 10,
                  maxLines: null,
                  controller: _controller,
                )
              : BBCodeRender(
                  data: _controller.text,
                  // TODO
                  openLink: (x) => {},
                  openPost: (x, y, z) => {},
                  openUser: (x) => {},
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _applyEdit();
        },
        child: Icon(Icons.send),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Map<String, String> _getQueryPara() {
    final query = {"__output": "14"};

    if (widget.categoryId != null) {
      query.putIfAbsent("fid", () => widget.categoryId.toString());
    }

    if (widget.topicId != null) {
      query.putIfAbsent("tid", () => widget.topicId.toString());
    }

    if (widget.postId != null) {
      query.putIfAbsent("pid", () => widget.postId.toString());
    }

    switch (widget.action) {
      case ACTION_NEWTOPIC:
        query.putIfAbsent("action", () => "new");
        break;
      case ACTION_QUOTE:
        query.putIfAbsent("action", () => "quote");
        break;
      case ACTION_REPLY:
        query.putIfAbsent("action", () => "reply");
        break;
      case ACTION_MODIFY:
        query.putIfAbsent("action", () => "modify");
        break;
      case ACTION_COMMENT:
        query.putIfAbsent("action", () => "reply");
        query.putIfAbsent("comment", () => "1");
        break;
      default:
        throw "invalid action value";
        break;
    }

    return query;
  }

  Future<_PrepareEditResponse> _prepareEdit() async {
    final query = _getQueryPara();

    final uri = Uri.https("nga.178.com", "post.php", query);

    print(uri);

    final res = await get(uri, headers: {"cookie": widget.cookies.join(";")});

    final json = jsonDecode(res.body);

    return _PrepareEditResponse.fromJson(json);
  }

  Future<void> _applyEdit() async {
    final query = _getQueryPara();

    query.putIfAbsent("step", () => "2");

    // TODO: encode as gbk 
    query.putIfAbsent("post_content", () => _controller.text);

    final uri = Uri.https("nga.178.com", "post.php", query);

    print(uri);

    var res = await post(uri, headers: {"cookie": widget.cookies.join(";")});

    print(res.body);
  }
}

class EditorPageConnector extends StatelessWidget {
  final int action;
  final int categoryId;
  final int topicId;
  final int postId;

  EditorPageConnector({
    @required this.action,
    @required this.categoryId,
    @required this.topicId,
    @required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ViewModel>(
      model: ViewModel(),
      builder: (context, vm) => EditorPage(
        action: action,
        categoryId: categoryId,
        topicId: topicId,
        postId: postId,
        cookies: vm.cookies,
      ),
    );
  }
}

class ViewModel extends BaseModel<AppState> {
  List<String> cookies;

  ViewModel();

  ViewModel.build({
    @required this.cookies,
  });

  @override
  BaseModel fromStore() {
    return ViewModel.build(
      cookies: state.cookies,
    );
  }
}
