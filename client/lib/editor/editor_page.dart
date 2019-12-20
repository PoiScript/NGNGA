import 'dart:io';

import 'package:business/editor/models/editing_state.dart';
import 'package:flutter/material.dart' hide Builder;
import 'package:flutter/services.dart';

import 'package:ngnga/localizations.dart';

import 'attachs.dart';
import 'preview_dialog.dart';
import 'sticker.dart';
import 'styling.dart';

class EditorPage extends StatefulWidget {
  final EditingState editingState;

  final ValueChanged<File> selectFile;
  final ValueChanged<int> unselectFile;
  final Future<void> Function(int) uploadFile;

  final Future<void> Function(String, String) applyEditing;

  const EditorPage({
    @required this.editingState,
    @required this.selectFile,
    @required this.unselectFile,
    @required this.uploadFile,
    @required this.applyEditing,
  });

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
    String content = widget.editingState.contentEvt.consume();
    if (content != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _contentController.text = content;
          if (_contentFocusNode.hasFocus) {
            _contentController.selection =
                TextSelection.collapsed(offset: content.length);
          }
        }
      });
    }

    String subject = widget.editingState.subjectEvt.consume();
    if (content != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _subjectController.text = subject;
          if (_subjectFocusNode.hasFocus) {
            _subjectController.selection =
                TextSelection.collapsed(offset: subject.length);
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.editingState.initialized) {
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
        body: _buildBody(),
        floatingActionButton: FloatingActionButton(
          onPressed: isSending ? null : _submit,
          child: Icon(Icons.send),
        ),
        bottomSheet: BottomAppBar(
          color: Theme.of(context).scaffoldBackgroundColor,
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

  Widget _buildBody() {
    return ScrollConfiguration(
      behavior: _Behavior(),
      child: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            leading: BackButton(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
            title: Text(
              'Editor',
              style: Theme.of(context).textTheme.body2,
            ),
            titleSpacing: 0.0,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            pinned: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                focusNode: _subjectFocusNode,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).subject,
                  border: InputBorder.none,
                ),
                maxLines: null,
                controller: _subjectController,
                style: Theme.of(context)
                    .textTheme
                    .subhead
                    .copyWith(fontFamily: 'Noto Sans CJK SC'),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                bottom: kToolbarHeight,
              ),
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: TextField(
                focusNode: _contentFocusNode,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).content,
                  border: InputBorder.none,
                ),
                controller: _contentController,
                maxLines: null,
                autofocus: true,
                style: Theme.of(context)
                    .textTheme
                    .body1
                    .copyWith(fontFamily: 'Noto Sans CJK SC'),
              ),
            ),
          ),
        ],
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
          files: widget.editingState.files,
          attachments: widget.editingState.attachments,
          selectFile: widget.selectFile,
          unselectFile: widget.unselectFile,
          uploadFile: widget.uploadFile,
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
      _subjectController.text,
      _contentController.text,
    );

    // close editor page
    Navigator.pop(context);
  }
}

class _Behavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
