import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ngnga/bbcode/render.dart';
import 'package:ngnga/localizations.dart';
import 'package:ngnga/screens/editor/sticker.dart';
import 'package:ngnga/store/actions.dart';
import 'package:ngnga/store/state.dart';

import 'sticker.dart';
import 'styling.dart';

// use int instead of enum to indicate edit action, so it can be passed from routing argument
const int actionNewTopic = 0;
const int actionQuote = 1;
const int actionReply = 2;
const int actionModify = 3;
const int actionComment = 4;
const int actionNoop = 5;

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
  bool disableToolbar = true;

  DisplayToolbar displayToolbar;

  bool isPreviewing = false;
  bool isSending = false;
  bool isLoading = true;

  String attachUrl;

  @override
  void initState() {
    super.initState();

    _contentFocusNode.addListener(() {
      setState(() => disableToolbar = !_contentFocusNode.hasFocus);
    });

    _subjectFocusNode.addListener(() {
      if (_subjectFocusNode.hasFocus) {
        setState(() => showToolbar = false);
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
    if (editing != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => isLoading = false);
          _subjectController.text = editing.subject;
          _contentController.text = editing.content;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return WillPopScope(
      onWillPop: () async {
        if (showToolbar) {
          setState(() => showToolbar = false);
          return false;
        }
        return true;
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: BackButton(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
          elevation: 0.0,
          title: Text(
            'Editor',
            style: Theme.of(context).textTheme.body2,
          ),
          backgroundColor: Theme.of(context).cardColor,
          // actions: <Widget>[
          //   IconButton(
          //     icon: Icon(Icons.undo, color: Colors.black),
          //     onPressed: () {},
          //   ),
          //   IconButton(
          //     icon: Icon(Icons.redo, color: Colors.black),
          //     onPressed: () {},
          //   ),
          // ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
                readOnly: isPreviewing,
                focusNode: _subjectFocusNode,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).subject,
                  border: InputBorder.none,
                ),
                controller: _subjectController,
                style: Theme.of(context)
                    .textTheme
                    .subhead
                    .copyWith(fontFamily: 'Noto Sans CJK SC'),
              ),
              if (isPreviewing)
                Container(
                  padding: EdgeInsets.all(8.0),
                  alignment: Alignment.centerLeft,
                  child: BBCodeRender(
                    raw: _contentController.text,
                    // TODO
                    openLink: (x) => {},
                    openPost: (x, y, z) => {},
                    openUser: (x) => {},
                  ),
                )
              else
                TextField(
                  readOnly: isPreviewing,
                  focusNode: _contentFocusNode,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).content,
                    border: InputBorder.none,
                  ),
                  controller: _contentController,
                  maxLines: null,
                  autofocus: true,
                  style: Theme.of(context)
                      .textTheme
                      .body1
                      .copyWith(fontFamily: 'Noto Sans CJK SC'),
                )
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: isSending ? null : _submit,
          child: Icon(Icons.send),
        ),
        bottomSheet: BottomAppBar(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.add_box),
                    onPressed: disableToolbar
                        ? null
                        : () => _toggleToolbar(DisplayToolbar.styling),
                  ),
                  IconButton(
                    icon: Icon(Icons.face),
                    onPressed: disableToolbar
                        ? null
                        : () => _toggleToolbar(DisplayToolbar.sticker),
                  ),
                  IconButton(
                    icon: Icon(Icons.attach_file),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: isPreviewing ? Icon(Icons.edit) : Icon(Icons.style),
                    onPressed: () {
                      setState(() => isPreviewing = !isPreviewing);
                    },
                  ),
                ],
              ),
              AnimatedContainer(
                constraints: const BoxConstraints(minWidth: double.infinity),
                duration: const Duration(milliseconds: 500),
                height: (!disableToolbar && showToolbar) ? 150.0 : 0.0,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: displayToolbar == DisplayToolbar.sticker
                    ? EditorSticker(
                        insertSticker: (name) => _insertContent('[s:$name]'),
                      )
                    : EditorStyling(
                        insertBold: () => _insertPair('[b]', '[/b]'),
                        insertItalic: () => _insertPair('[i]', '[/i]'),
                        insertUnderline: () => _insertPair('[u]', '[/u]'),
                        insertDelete: () => _insertPair('[del]', '[/del]'),
                        insertQuote: () => _insertPair('[quote]', '[/quote]'),
                        insertHeading: () => _insertPair('[h]', '[/h]'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _toggleToolbar(DisplayToolbar toolbar) {
    setState(() {
      if (showToolbar) {
        if (displayToolbar == toolbar) {
          showToolbar = false;
        } else {
          displayToolbar = toolbar;
        }
      } else {
        showToolbar = true;
        displayToolbar = toolbar;
      }
    });
  }

  _insertContent(String content) {
    int baseOffset = _contentController.selection.baseOffset;
    int extentOffset = _contentController.selection.extentOffset;
    String text = _contentController.text;

    _contentController.value = _contentController.value.copyWith(
      text:
          '${text.substring(0, baseOffset)}$content${text.substring(extentOffset)}',
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
            '${text.substring(0, baseOffset)}$start${text.substring(baseOffset, extentOffset)}$end${text.substring(extentOffset)}',
        selection: TextSelection(
          baseOffset: baseOffset + start.length,
          extentOffset: extentOffset + start.length,
        ),
      );
    } else {
      _contentController.value = _contentController.value.copyWith(
        text:
            '${text.substring(0, baseOffset)}$start$end${text.substring(extentOffset)}',
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
  })  : assert(action == actionNewTopic ||
            action == actionQuote ||
            action == actionReply ||
            action == actionModify ||
            action == actionComment ||
            action == actionNoop),
        assert(action != actionNewTopic ||
            (categoryId != null && topicId == null && postId == null)),
        assert(
            action != actionQuote || (categoryId == null && topicId != null)),
        assert(
            action != actionReply || (categoryId == null && topicId != null)),
        assert(
            action != actionModify || (categoryId == null && topicId != null)),
        assert(
            action != actionComment || (categoryId == null && topicId != null));

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
