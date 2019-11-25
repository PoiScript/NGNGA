import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:async_redux/async_redux.dart';
import 'package:ngnga/models/category.dart';
import 'package:path_provider/path_provider.dart';

import 'package:ngnga/store/state.dart';

const enumToStringMap = const {
  NgaDomain.nga178com: "nga.178.com",
  NgaDomain.bbsngacn: "bbs.nga.cn",
  NgaDomain.nagbbscom: "ngabbs.com",
};

const stringToEnumMap = const {
  "nga.178.com": NgaDomain.nga178com,
  "bbs.nga.cn": NgaDomain.bbsngacn,
  "ngabbs.com": NgaDomain.nagbbscom,
};

class SaveState extends ReduxAction<AppState> {
  @override
  Future<AppState> reduce() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/state.json');

    String json = jsonEncode({
      "ngaUid": state.settings.uid,
      "ngaCid": state.settings.cid,
      "ngaDomain": enumToStringMap[state.settings.domain],
      "pinned": state.pinned.map((c) => c.toJson()).toList(),
    });

    await file.writeAsString(json);

    print("Saved state to ${file.path}");

    return null;
  }
}

class LoadState extends ReduxAction<AppState> {
  @override
  Future<AppState> reduce() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/state.json');

    if (!(await file.exists())) return null;

    try {
      String content = await file.readAsString();
      final json = jsonDecode(content);

      print("Loaded state from ${file.path}");

      return state.copy(
        settings: state.settings.copy(
          uid: json["ngaUid"],
          cid: json["ngaCid"],
          domain: stringToEnumMap[json["ngaDomain"]],
        ),
        pinned:
            List.from(json["pinned"]).map((x) => Category.fromJson(x)).toList(),
      );
    } catch (e) {
      print(e);
      // this file is corrupted or something, just delete it
      await file.delete();
      return null;
    }
  }
}
