import 'package:flutter/material.dart';

class CookiesEditor extends StatefulWidget {
  final String uid;
  final String cid;

  final Function({String uid, String cid}) submitChanges;

  CookiesEditor({
    @required this.uid,
    @required this.cid,
    @required this.submitChanges,
  });

  @override
  _CookiesEditorState createState() => _CookiesEditorState();
}

class _CookiesEditorState extends State<CookiesEditor> {
  TextEditingController _uidController;
  TextEditingController _cidController;

  @override
  void initState() {
    super.initState();
    _uidController = TextEditingController(text: widget.uid);
    _cidController = TextEditingController(text: widget.cid);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Edit Cookies',
        style: Theme.of(context).textTheme.body2,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: _uidController,
            decoration: InputDecoration(
              labelText: 'ngaPassportUid',
            ),
          ),
          TextField(
            controller: _cidController,
            decoration: InputDecoration(
              labelText: 'ngaPassportCid',
            ),
          ),
        ],
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('CANCEL'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text('SUBMIT'),
          onPressed: () {
            widget.submitChanges(
              uid: _uidController.text,
              cid: _cidController.text,
            );
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
