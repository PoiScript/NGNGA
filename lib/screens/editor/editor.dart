import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ngnga/localizations.dart';
import 'package:ngnga/store/actions.dart';
import 'package:ngnga/store/state.dart';

import 'attachs.dart';
import 'preview_dialog.dart';
import 'sticker.dart';
import 'styling.dart';

enum EditorAction {
  newTopic,
  newPost,
  quote,
  reply,
  modify,
  comment,
  noop,
}

class EditorPage extends StatefulWidget {
  final bool perpared;

  final Event<String> setSubjectEvt;
  final Event<String> setContentEvt;
  final List<AttachmentItem> attachments;

  final ValueChanged<LocalAttachment> addAttachment;
  final ValueChanged<LocalAttachment> removeAttachment;
  final Future<void> Function(LocalAttachment) uploadAttachment;
  final Future<void> Function({String subject, String content}) applyEditing;
  final VoidCallback clearEditing;

  EditorPage({
    @required this.perpared,
    @required this.setSubjectEvt,
    @required this.setContentEvt,
    @required this.attachments,
    @required this.addAttachment,
    @required this.removeAttachment,
    @required this.uploadAttachment,
    @required this.applyEditing,
    @required this.clearEditing,
  })  : assert(setSubjectEvt != null),
        assert(perpared != null),
        assert(setContentEvt != null),
        assert(applyEditing != null),
        assert(attachments != null),
        assert(addAttachment != null),
        assert(removeAttachment != null),
        assert(uploadAttachment != null),
        assert(clearEditing != null);

  @override
  _EditorPageState createState() => _EditorPageState();
}

enum DisplayToolbar {
  styling,
  sticker,
  attachs,
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

  bool isSending = false;

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
    String subject = widget.setSubjectEvt.consume();
    if (subject != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _subjectController.text = subject;
        }
      });
    }

    String content = widget.setContentEvt.consume();
    if (content != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _contentController.text = content;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.perpared) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return WillPopScope(
      onWillPop: () async {
        if (showToolbar) {
          setState(() => showToolbar = false);
          return false;
        }
        widget.clearEditing();
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
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: 8.0,
              right: 8.0,
              bottom: 8.0 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              children: [
                TextField(
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
                TextField(
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
                    color:
                        showToolbar && displayToolbar == DisplayToolbar.styling
                            ? Theme.of(context).accentColor
                            : null,
                    icon: Icon(Icons.add_box),
                    onPressed: disableToolbar
                        ? null
                        : () => _toggleToolbar(DisplayToolbar.styling),
                  ),
                  IconButton(
                    color:
                        showToolbar && displayToolbar == DisplayToolbar.sticker
                            ? Theme.of(context).accentColor
                            : null,
                    icon: Icon(Icons.face),
                    onPressed: disableToolbar
                        ? null
                        : () => _toggleToolbar(DisplayToolbar.sticker),
                  ),
                  IconButton(
                    color:
                        showToolbar && displayToolbar == DisplayToolbar.attachs
                            ? Theme.of(context).accentColor
                            : null,
                    icon: Icon(Icons.attach_file),
                    onPressed: disableToolbar
                        ? null
                        : () => _toggleToolbar(DisplayToolbar.attachs),
                  ),
                  IconButton(
                    icon: Icon(Icons.style),
                    onPressed: () => _openPreviewDailog(context),
                  ),
                ],
              ),
              AnimatedContainer(
                constraints: const BoxConstraints(minWidth: double.infinity),
                duration: const Duration(milliseconds: 500),
                height: (!disableToolbar && showToolbar) ? 150.0 : 0.0,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: _buildToolbarContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolbarContent() {
    switch (displayToolbar) {
      case DisplayToolbar.sticker:
        return EditorSticker(
          insertSticker: (name) => _insertContent('[s:$name]'),
        );
      case DisplayToolbar.attachs:
        return EditorAttachs(
          attachs: widget.attachments,
          addAttachment: widget.addAttachment,
          removeAttachment: widget.removeAttachment,
          uploadAttachment: widget.uploadAttachment,
          insertImage: (url) => _insertContent('[img]./$url[/img]'),
        );
      case DisplayToolbar.styling:
        return EditorStyling(
          insertBold: () => _insertPair('[b]', '[/b]'),
          insertItalic: () => _insertPair('[i]', '[/i]'),
          insertUnderline: () => _insertPair('[u]', '[/u]'),
          insertDelete: () => _insertPair('[del]', '[/del]'),
          insertQuote: () => _insertPair('[quote]', '[/quote]'),
          insertHeading: () => _insertPair('[h]', '[/h]'),
        );
    }
    return null;
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
    setState(() => showToolbar = false);

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
    setState(() => showToolbar = false);

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

  _openPreviewDailog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => PreviewDialog(
        content: _contentController.text,
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => isSending = true);

    await widget.applyEditing(
      subject: _subjectController.text,
      content: _contentController.text,
    );

    // close editor page
    Navigator.pop(context);
  }
}

class EditorPageConnector extends StatelessWidget {
  final EditorAction action;
  final int categoryId;
  final int topicId;
  final int postId;

  EditorPageConnector({
    @required this.action,
    @required this.categoryId,
    @required this.topicId,
    @required this.postId,
  })  : assert(action != null),
        assert(_validateArgs(action, categoryId, topicId, postId));

  static bool _validateArgs(
      EditorAction action, int categoryId, int topicId, int postId) {
    switch (action) {
      case EditorAction.newTopic:
        return categoryId != null && topicId == null && postId == null;
      case EditorAction.newPost:
        return categoryId == null && topicId != null && postId == null;
      case EditorAction.quote:
      case EditorAction.reply:
      case EditorAction.modify:
      case EditorAction.comment:
        return categoryId == null && topicId != null && postId != null;
      case EditorAction.noop:
        return categoryId == null && topicId == null && postId == null;
    }
    return false;
  }

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
        setSubjectEvt: vm.setSubjectEvt,
        setContentEvt: vm.setContentEvt,
        attachments: vm.attachs,
        perpared: vm.perpared,
        addAttachment: vm.addAttachment,
        removeAttachment: vm.removeAttachment,
        uploadAttachment: vm.uploadAttachment,
        applyEditing: vm.applyEditing,
        clearEditing: vm.clearEditing,
      ),
    );
  }
}

class ViewModel extends BaseModel<AppState> {
  final EditorAction action;
  final int categoryId;
  final int topicId;
  final int postId;

  bool perpared;
  List<AttachmentItem> attachs;

  Event<String> setSubjectEvt;
  Event<String> setContentEvt;

  ValueChanged<LocalAttachment> addAttachment;
  ValueChanged<LocalAttachment> removeAttachment;
  Future<void> Function(LocalAttachment) uploadAttachment;
  Future<void> Function({String subject, String content}) applyEditing;
  VoidCallback clearEditing;

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
    @required this.perpared,
    @required this.attachs,
    @required this.setSubjectEvt,
    @required this.setContentEvt,
    @required this.addAttachment,
    @required this.removeAttachment,
    @required this.uploadAttachment,
    @required this.applyEditing,
    @required this.clearEditing,
  }) : super(equals: [setSubjectEvt, setContentEvt, attachs, perpared]);

  @override
  BaseModel fromStore() {
    return ViewModel.build(
      action: action,
      categoryId: categoryId,
      topicId: topicId,
      postId: postId,
      perpared: state.editingState.perpared,
      attachs: state.editingState.attachs,
      setSubjectEvt: state.editingState.setSubjectEvt,
      setContentEvt: state.editingState.setContentEvt,
      applyEditing: ({subject, content}) => dispatchFuture(ApplyEditingAction(
        action: action,
        categoryId: categoryId,
        topicId: topicId,
        postId: postId,
        subject: subject,
        content: content,
      )),
      clearEditing: () => dispatch(ClearEditingAction()),
      addAttachment: (attach) => dispatch(AddAttachmentAction(attach)),
      removeAttachment: (attach) => dispatch(RemoveAttachmentAction(attach)),
      uploadAttachment: (attach) =>
          dispatchFuture(UploadAttachmentAction(attach, categoryId)),
    );
  }
}
