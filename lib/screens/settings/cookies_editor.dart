import 'package:flutter/material.dart';

import 'package:ngnga/store/state.dart';

class CookiesEditor extends StatefulWidget {
  final Logged user;

  final Function({int uid, String cid}) submitChanges;

  CookiesEditor({
    @required this.user,
    @required this.submitChanges,
  })  : assert(user != null),
        assert(submitChanges != null);

  @override
  _CookiesEditorState createState() => _CookiesEditorState();
}

class _CookiesEditorState extends State<CookiesEditor> {
  TextEditingController _uidController;
  TextEditingController _cidController;

  @override
  void initState() {
    super.initState();
    _uidController = TextEditingController(text: widget.user.uid.toString());
    _cidController = TextEditingController(text: widget.user.cid);
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
            keyboardType: TextInputType.number,
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
              uid: int.tryParse(_uidController.text),
              cid: _cidController.text,
            );
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
