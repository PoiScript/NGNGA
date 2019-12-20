import 'dart:convert';

import 'package:async_redux/async_redux.dart';
import 'package:built_value/built_value.dart';
import 'package:flutter/widgets.dart' hide Builder;
import 'package:http/http.dart';

import 'package:business/app_state.dart';
import 'package:business/user/actions/login_action.dart';

import 'welcome_page.dart';

part 'welcome_page_connector.g.dart';

class WelcomePageConnector extends StatelessWidget {
  WelcomePageConnector();

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      converter: (store) => _ViewModel.fromStore(store),
      builder: (context, vm) => WelcomePage(
        logged: vm.login,
        validate: vm.validate,
      ),
    );
  }
}

abstract class _ViewModel implements Built<_ViewModel, _ViewModelBuilder> {
  _ViewModel._();

  factory _ViewModel([Function(_ViewModelBuilder) updates]) = _$ViewModel;

  Future<void> Function(int, String) get login;
  Future<bool> Function(int, String) get validate;

  factory _ViewModel.fromStore(Store<AppState> store) {
    return _ViewModel(
      (b) => b
        ..login = ((int uid, String cid) =>
            store.dispatchFuture(LoginAction(uid: uid, cid: cid)))
        ..validate = (int uid, String cid) async {
          final res = await get(
            'https://ngabbs.com/nuke.php?__lib=noti&__act=if&__output=11',
            headers: {'cookie': 'ngaPassportUid=$uid;ngaPassportCid=$cid;'},
          );

          final json = jsonDecode(res.body);

          return json['data'] != null;
        },
    );
  }
}
