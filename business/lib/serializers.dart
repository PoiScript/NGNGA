import 'package:built_value/serializer.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/standard_json_plugin.dart';

import 'package:business/models/category.dart';
import 'package:business/settings/models/settings_state.dart';
import 'package:business/user/models/user_state.dart';

import 'app_state.dart';

part 'serializers.g.dart';

@SerializersFor([
  AppLocale,
  AppState,
  AppTheme,
  Category,
  SettingsState,
  UserState,
  UserStatus,
])
final Serializers serializers =
    (_$serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
