import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ngnga/bbcode/render.dart';
import 'package:ngnga/screens/editor/sticker.dart';
import 'package:ngnga/store/actions.dart';
import 'package:ngnga/store/state.dart';

import 'sticker.dart';
import 'styling.dart';

// use int instead of enum to indicate edit action, so it can be passed from routing argument
const int ACTION_NEW_TOPIC = 0;
const int ACTION_QUOTE = 1;
const int ACTION_REPLY = 2;
const int ACTION_MODIFY = 3;
const int ACTION_COMMENT = 4;
const int ACTION_NOOP = 5;

class EditorPage extends StatefulWidget {
  final Event<Editing> setEditingEvt;

  final Future<void> Function(String, String) applyEditing;

  EditorPage({
    @required this.setEditingEvt,
    @required this.applyEditing,
  })  : assert(setEditingEvt != null),
        assert(applyEditing != null);

  @override
  _EditorPageState createState() => _EditorPageState();
}

enum DisplayToolbar {
  styling,
  sticker,
}

class _EditorPageState extends State<EditorPage> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final FocusNode _subjectFocusNode = FocusNode();
  final FocusNode _contentFocusNode = FocusNode();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool showToolbar = false;
  bool disableToolbar = false;

  DisplayToolbar displayToolbar;

  bool isPreviewing = false;
  bool isSending = false;
  bool isLoading = true;

  String attachUrl;

  @override
  void initState() {
    super.initState();

    _contentFocusNode.addListener(() {
      if (_contentFocusNode.hasFocus) {
        setState(() {
          disableToolbar = false;
        });
      }
    });

    _subjectFocusNode.addListener(() {
      if (_subjectFocusNode.hasFocus) {
        setState(() {
          showToolbar = false;
          disableToolbar = true;
        });
      }
    });
  }

  @override
  void didUpdateWidget(EditorPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _consumeEvents();
  }

  _consumeEvents() {
    Editing editing = widget.setEditingEvt.consume();
    if (editing != null)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => isLoading = false);
          _subjectController.text = editing.subject;
          _contentController.text = editing.content;
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Stack(
      children: <Widget>[
        Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            leading: const BackButton(color: Colors.black),
            elevation: 0.0,
            title: Text(
              "Editor",
              style: Theme.of(context)
                  .textTheme
                  .body1
                  .copyWith(color: Colors.black),
            ),
            backgroundColor: Colors.white,
            actions: <Widget>[
              FlatButton(
                child: isPreviewing ? Text("Edit") : Text("Preview"),
                onPressed: () {
                  setState(() => isPreviewing = !isPreviewing);
                },
              ),
              FlatButton(
                child: Text("Send"),
                onPressed: () => _submit(),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (!isPreviewing)
                    TextField(
                      focusNode: _subjectFocusNode,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: 'Subject',
                        border: InputBorder.none,
                      ),
                      controller: _subjectController,
                      style: Theme.of(context)
                          .textTheme
                          .subhead
                          .copyWith(fontFamily: "Noto Sans CJK SC"),
                    ),
                  if (!isPreviewing)
                    TextField(
                      focusNode: _contentFocusNode,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        labelText: 'Content',
                        border: InputBorder.none,
                      ),
                      controller: _contentController,
                      maxLines: null,
                      autofocus: true,
                      style: Theme.of(context)
                          .textTheme
                          .body1
                          .copyWith(fontFamily: "Noto Sans CJK SC"),
                    ),
                  if (isPreviewing && _subjectController.text.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        _subjectController.text,
                        style: Theme.of(context)
                            .textTheme
                            .subhead
                            .copyWith(fontFamily: "Noto Sans CJK SC"),
                      ),
                    ),
                  if (isPreviewing && _contentController.text.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: BBCodeRender(
                        data: _contentController.text,
                        // TODO
                        openLink: (x) => {},
                        openPost: (x, y, z) => {},
                        openUser: (x) => {},
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          right: 0.0,
          left: 0.0,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Divider(height: 0.0),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  height: showToolbar ? 250.0 : 0.0,
                  padding:
                      const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                  child: displayToolbar == DisplayToolbar.sticker
                      ? EditorSticker(
                          insertSticker: (name) => _insertContent("[s:$name]"),
                        )
                      : EditorStyling(
                          insertBold: () => _insertPair("[b]", "[/b]"),
                          insertItalic: () => _insertPair("[i]", "[/i]"),
                          insertUnderline: () => _insertPair("[u]", "[/u]"),
                          insertDelete: () => _insertPair("[del]", "[/del]"),
                          insertQuote: () => _insertPair("[quote]", "[/quote]"),
                          insertHeading: () => _insertPair("[h]", "[/h]"),
                        ),
                ),
                Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        child: Icon(Icons.add_box, size: 24.0),
                        onTap: disableToolbar
                            ? null
                            : () {
                                SystemChannels.textInput
                                    .invokeMethod('TextInput.hide');
                                setState(() {
                                  if (showToolbar) {
                                    if (displayToolbar ==
                                        DisplayToolbar.styling) {
                                      showToolbar = false;
                                    } else {
                                      displayToolbar = DisplayToolbar.styling;
                                    }
                                  } else {
                                    showToolbar = true;
                                    displayToolbar = DisplayToolbar.styling;
                                  }
                                });
                              },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        child: Icon(Icons.face, size: 24.0),
                        onTap: disableToolbar
                            ? null
                            : () {
                                SystemChannels.textInput
                                    .invokeMethod('TextInput.hide');
                                setState(() {
                                  if (showToolbar) {
                                    if (displayToolbar ==
                                        DisplayToolbar.sticker) {
                                      showToolbar = false;
                                    } else {
                                      displayToolbar = DisplayToolbar.sticker;
                                    }
                                  } else {
                                    showToolbar = true;
                                    displayToolbar = DisplayToolbar.sticker;
                                  }
                                });
                              },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _insertContent(String content) {
    int baseOffset = _contentController.selection.baseOffset;
    int extentOffset = _contentController.selection.extentOffset;
    String text = _contentController.text;

    _contentController.value = _contentController.value.copyWith(
      text:
          "${text.substring(0, baseOffset)}$content${text.substring(extentOffset)}",
      selection: TextSelection.collapsed(offset: baseOffset + content.length),
    );
  }

  _insertPair(String start, String end) {
    int baseOffset = _contentController.selection.baseOffset;
    int extentOffset = _contentController.selection.extentOffset;
    String text = _contentController.text;

    if (baseOffset != extentOffset) {
      _contentController.value = _contentController.value.copyWith(
        text:
            "${text.substring(0, baseOffset)}$start${text.substring(baseOffset, extentOffset)}$end${text.substring(extentOffset)}",
        selection: TextSelection(
          baseOffset: baseOffset + start.length,
          extentOffset: extentOffset + start.length,
        ),
      );
    } else {
      _contentController.value = _contentController.value.copyWith(
        text:
            "${text.substring(0, baseOffset)}$start$end${text.substring(extentOffset)}",
        selection: TextSelection.collapsed(offset: baseOffset + start.length),
      );
    }
  }

  Future<void> _submit() async {
    setState(() => isSending = true);

    await widget.applyEditing(
      _subjectController.text,
      _contentController.text,
    );

    // close editor page
    Navigator.pop(context);
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
  })  : assert(action == ACTION_NEW_TOPIC ||
            action == ACTION_QUOTE ||
            action == ACTION_REPLY ||
            action == ACTION_MODIFY ||
            action == ACTION_COMMENT ||
            action == ACTION_NOOP),
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
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ViewModel>(
      model: ViewModel(
        action: action,
        categoryId: categoryId,
        topicId: topicId,
        postId: postId,
      ),
      onInit: (store) => store.dispatch(PrepareEditingAction(
        action: action,
        categoryId: categoryId,
        topicId: topicId,
        postId: postId,
      )),
      builder: (context, vm) => EditorPage(
        setEditingEvt: vm.setEditingEvt,
        applyEditing: vm.applyEditing,
      ),
    );
  }
}

class ViewModel extends BaseModel<AppState> {
  final int action;
  final int categoryId;
  final int topicId;
  final int postId;

  Event<Editing> setEditingEvt;
  Future<void> Function(String, String) applyEditing;

  ViewModel({
    @required this.action,
    @required this.categoryId,
    @required this.topicId,
    @required this.postId,
  });

  ViewModel.build({
    @required this.action,
    @required this.categoryId,
    @required this.topicId,
    @required this.postId,
    @required this.setEditingEvt,
    @required this.applyEditing,
  }) : super(equals: [setEditingEvt]);

  @override
  BaseModel fromStore() {
    return ViewModel.build(
      action: action,
      categoryId: categoryId,
      topicId: topicId,
      postId: postId,
      setEditingEvt: state.setEditingEvt,
      applyEditing: (subject, content) => dispatchFuture(ApplyEditingAction(
        action: action,
        categoryId: categoryId,
        topicId: topicId,
        postId: postId,
        subject: subject,
        content: content,
      )),
    );
  }
}
