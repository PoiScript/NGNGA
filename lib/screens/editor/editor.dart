import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';

import 'package:ngnga/bbcode/render.dart';
import 'package:ngnga/store/apply_editing.dart';
import 'package:ngnga/store/prepare_editing.dart';
import 'package:ngnga/store/state.dart';

class ToolbarIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  ToolbarIcon({this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Icon(icon, size: 30.0),
      onTap: onTap,
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

class _EditorPageState extends State<EditorPage> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isPreviewing = false;
  bool isSending = false;
  bool isLoading = true;
  OverlayEntry overlayEntry;

  String attachUrl;

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _displayOverlay();
      } else {
        _removeOverlay();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _removeOverlay();
  }

  _removeOverlay() {
    if (overlayEntry != null) {
      overlayEntry.remove();
      overlayEntry = null;
    }
  }

  _displayOverlay() {
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        right: 0.0,
        left: 0.0,
        child: Container(
          alignment: Alignment.center,
          color: Theme.of(context).cardColor,
          child: Wrap(
            children: <Widget>[
              ToolbarIcon(
                icon: Icons.format_bold,
                onTap: () => _insertPair("[b]", "[/b]"),
              ),
              ToolbarIcon(
                icon: Icons.format_italic,
                onTap: () => _insertPair("[i]", "[/i]"),
              ),
              ToolbarIcon(
                icon: Icons.format_underlined,
                onTap: () => _insertPair("[u]", "[/u]"),
              ),
              ToolbarIcon(
                icon: Icons.format_quote,
                onTap: () => _insertPair("[quote]", "[/quote]"),
              ),
              ToolbarIcon(
                icon: Icons.format_strikethrough,
                onTap: () => _insertPair("[del]", "[/del]"),
              ),
              ToolbarIcon(
                icon: Icons.format_list_bulleted,
                onTap: () {},
              ),
              ToolbarIcon(
                icon: Icons.title,
                onTap: () => _insertPair("[h]", "[/h]"),
              ),
              ToolbarIcon(
                icon: Icons.code,
                onTap: () => _insertPair("[code]", "[/code]"),
              ),
            ],
          ),
        ),
      ),
    );

    OverlayState overlayState = Overlay.of(context);
    overlayState.insert(overlayEntry);
  }

  @override
  void didUpdateWidget(EditorPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    consumeEvents();
  }

  consumeEvents() {
    Editing editing = widget.setEditingEvt.consume();
    if (editing != null)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
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
                  if (!isPreviewing) _removeOverlay();
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
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: 'Subject',
                        border: InputBorder.none,
                      ),
                      controller: _subjectController,
                    ),
                  if (!isPreviewing)
                    TextField(
                      focusNode: _focusNode,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        labelText: 'Content',
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                      controller: _contentController,
                      autofocus: true,
                    ),
                  if (isPreviewing && _subjectController.text.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        _subjectController.text,
                        style: Theme.of(context).textTheme.subhead,
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
        if (isSending) ModalBarrier(color: Colors.red.withOpacity(0.4)),
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

    _removeOverlay();

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
