import 'package:flutter/material.dart';

class UserDialog extends StatelessWidget {
  final int userId;

  UserDialog(this.userId) : assert(userId != null);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog();
  }
}
