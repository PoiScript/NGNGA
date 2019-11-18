import 'dart:convert';

import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'package:ngnga/bbcode/render.dart';
import 'package:ngnga/store/state.dart';
import 'package:ngnga/utils/gbk_encode.dart';

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
      // TODO: error handling
      return _PrepareEditResponse();
    }
  }
}

class _AppleEditResponse {
  final int code;
  final String message;

  _AppleEditResponse({
    @required this.code,
    @required this.message,
  });

  factory _AppleEditResponse.fromJson(Map<String, dynamic> json) {
    return _AppleEditResponse(
      code: json['code'],
      message: json['msg'],
    );
  }
}

// use int instead of enum to indicate edit action, so it can be passed from routing argument
const int ACTION_NEW_TOPIC = 0;
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
        assert(action == ACTION_NEW_TOPIC ||
            action == ACTION_QUOTE ||
            action == ACTION_REPLY ||
            action == ACTION_MODIFY ||
            action == ACTION_COMMENT),
        assert(action != ACTION_NEW_TOPIC ||
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

class _EditorPageState extends State<EditorPage> {
  final TextEditingController _controller = TextEditingController();

  bool isSending = false;
  bool isPreview = false;
  bool isLoading = true;
  String subject;
  String attachUrl;

  @override
  void initState() {
    super.initState();
    _prepareEditing().then((res) {
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
          FlatButton(
            child: isPreview ? Text("Edit") : Text("Preview"),
            onPressed: () => setState(() => isPreview = !isPreview),
          ),
          FlatButton(
            child: Text("Send"),
            onPressed: () async {
              _showIndicatorDialog();
              // TODO: FIXME: display snack bar
              try {
                final res = await _applyEditing();
                if (res.code == 1) {
                  // Scaffold.of(context).showSnackBar(SnackBar(
                  //   content: Text("Post sent."),
                  // ));
                  // close dialog
                  Navigator.pop(context);
                  // close editor page
                  Navigator.pop(context);
                } else {
                  print(res.message);
                  // Scaffold.of(context).showSnackBar(SnackBar(
                  //   content: Text("Failed to send."),
                  // ));
                  // close dialog
                  Navigator.pop(context);
                }
              } catch (e) {
                print(e);
                // Scaffold.of(context).showSnackBar(SnackBar(
                //   content: Text("Failed to send."),
                // ));
                // close dialog
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: isPreview ? _previewSection() : _editorSection(),
    );
  }

  Widget _previewSection() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: BBCodeRender(
          data: _controller.text,
          // TODO
          openLink: (x) => {},
          openPost: (x, y, z) => {},
          openUser: (x) => {},
        ),
      ),
    );
  }

  Widget _editorSection() {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: TextField(
        keyboardType: TextInputType.multiline,
        minLines: 10,
        maxLines: null,
        controller: _controller,
        autofocus: true,
      ),
    );
  }

  _showIndicatorDialog() {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        children: <Widget>[
          Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  StringBuffer _getQuery() {
    final sb = StringBuffer("__output=14");

    switch (widget.action) {
      case ACTION_NEW_TOPIC:
        sb.write("&action=new");
        break;
      case ACTION_QUOTE:
        sb.write("&action=quote");
        break;
      case ACTION_REPLY:
        sb.write("&action=reply");
        break;
      case ACTION_MODIFY:
        sb.write("&action=modify");
        break;
      case ACTION_COMMENT:
        sb..write("&action=reply")..write("&comment=1");
        break;
    }

    if (widget.categoryId != null) {
      sb.write("&fid=${widget.categoryId}");
    }

    if (widget.topicId != null) {
      sb.write("&tid=${widget.topicId}");
    }

    if (widget.postId != null) {
      sb.write("&pid=${widget.postId}");
    }

    return sb;
  }

  Future<_PrepareEditResponse> _prepareEditing() async {
    final query = _getQuery();

    final uri = "https://nga.178.com/post.php?${query.toString()}";

    print(uri);

    final res = await get(uri, headers: {"cookie": widget.cookies.join(";")});

    final json = jsonDecode(res.body);

    return _PrepareEditResponse.fromJson(json);
  }

  Future<_AppleEditResponse> _applyEditing() async {
    final query = _getQuery()..write("&step=2");

    query.write("&post_content=${encodeUrlGbk(_controller.text).toString()}");

    // we're manually encode url here, so we have to concatenate it by hand
    final uri = "https://nga.178.com/post.php?${query.toString()}";

    print(uri);

    final res = await post(uri, headers: {"cookie": widget.cookies.join(";")});

    final json = jsonDecode(res.body);

    return _AppleEditResponse.fromJson(json);
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
