import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'user_state.g.dart';

class UserStatus extends EnumClass {
  static Serializer<UserStatus> get serializer => _$userStatusSerializer;

  static const UserStatus unlogged = _$unlogged;
  static const UserStatus logged = _$logged;

  const UserStatus._(String name) : super(name);

  static BuiltSet<UserStatus> get values => _$stValues;
  static UserStatus valueOf(String name) => _$stValueOf(name);
}

abstract class UserState implements Built<UserState, UserStateBuilder> {
  static Serializer<UserState> get serializer => _$userStateSerializer;

  UserState._() {
    if (status == UserStatus.logged) assert(uid != null && cid != null);
  }

  factory UserState([Function(UserStateBuilder) updates]) = _$UserState;

  UserStatus get status;
  @nullable
  int get uid;
  @nullable
  String get cid;

  @memoized
  bool get isLogged => status != UserStatus.unlogged;

  @memoized
  String get cookie => 'ngaPassportUid=$uid;ngaPassportCid=$cid;';

  // TODO: guest login

  static void _initializeBuilder(UserStateBuilder b) =>
      b.status = UserStatus.unlogged;
}
