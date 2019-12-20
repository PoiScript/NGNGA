import 'package:async_redux/async_redux.dart';
import 'package:built_value/built_value.dart';
import 'package:flutter/widgets.dart' hide Builder;

import 'package:business/app_state.dart';
import 'package:business/models/user.dart';

import 'user_page.dart';

part 'user_page_connector.g.dart';

class UserPageConnector extends StatelessWidget {
  final int userId;

  UserPageConnector({
    @required this.userId,
  }) : assert(userId != null);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      converter: (store) => _ViewModel.fromStore(store, userId: userId),
      builder: (context, vm) => UserPage(user: vm.user),
    );
  }
}

abstract class _ViewModel implements Built<_ViewModel, _ViewModelBuilder> {
  _ViewModel._();

  factory _ViewModel([Function(_ViewModelBuilder) updates]) = _$ViewModel;

  User get user;

  factory _ViewModel.fromStore(Store<AppState> store, {int userId}) =>
      _ViewModel((b) => b.user = store.state.users[userId]);
}
