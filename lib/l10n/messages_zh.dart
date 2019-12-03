// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names
// ignore_for_file:type_annotate_public_apis

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'zh';

  static m0(username) => "${username} 评论了你的帖子";

  static m1(username) => "${username} 评论了你的主题";

  static m2(dateTime, seconds) => "上次更新：${dateTime}（${seconds} 秒前）";

  static m3(username) => "${username} 在回复中 @ le你";

  static m4(username) => "${username} 在主题中 @ 了你";

  static m5(username) => "${username} 回复了你的回复";

  static m6(username) => "${username} 回复了你的帖子";

  static m7(interval) => "更新间隔：${interval} 秒";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function>{
        "About": MessageLookupByLibrary.simpleMessage("关于"),
        "Add to Favorites": MessageLookupByLibrary.simpleMessage("添加进收藏"),
        "Add to pinned": MessageLookupByLibrary.simpleMessage("添加进顶置"),
        "Added to Favorites": MessageLookupByLibrary.simpleMessage("已添加进收藏"),
        "Added to pinned": MessageLookupByLibrary.simpleMessage("已添加进顶置"),
        "Auto-update Disabled": MessageLookupByLibrary.simpleMessage("自动更新已关闭"),
        "Auto-update Enabled": MessageLookupByLibrary.simpleMessage("自动更新已启用"),
        "Change Domain": MessageLookupByLibrary.simpleMessage("更换域名"),
        "Comment Not Found": MessageLookupByLibrary.simpleMessage("未找到评论"),
        "Content": MessageLookupByLibrary.simpleMessage("内容"),
        "Copied Link To Clipboard":
            MessageLookupByLibrary.simpleMessage("已复制链接"),
        "Copy Link To Clipboard": MessageLookupByLibrary.simpleMessage("复制链接"),
        "Created At": MessageLookupByLibrary.simpleMessage("创建时间"),
        "Display In BBCode": MessageLookupByLibrary.simpleMessage("显示源码"),
        "Display In RichText": MessageLookupByLibrary.simpleMessage("隐藏源码"),
        "Edit Cookies": MessageLookupByLibrary.simpleMessage("编辑 Cookies"),
        "Edited At": MessageLookupByLibrary.simpleMessage("编辑时间"),
        "Explore": MessageLookupByLibrary.simpleMessage("探索"),
        "Favorites": MessageLookupByLibrary.simpleMessage("收藏"),
        "Inbox": MessageLookupByLibrary.simpleMessage("信息"),
        "Language": MessageLookupByLibrary.simpleMessage("语言"),
        "Last Visited": MessageLookupByLibrary.simpleMessage("上次访问"),
        "Loading...": MessageLookupByLibrary.simpleMessage("加载中..."),
        "No Signature": MessageLookupByLibrary.simpleMessage("无签名"),
        "Pinned": MessageLookupByLibrary.simpleMessage("顶置"),
        "Post Not Found": MessageLookupByLibrary.simpleMessage("未找到回复"),
        "Posted At": MessageLookupByLibrary.simpleMessage("发送时间"),
        "Posts Count": MessageLookupByLibrary.simpleMessage("发帖数目"),
        "Remove from Favorites": MessageLookupByLibrary.simpleMessage("移出收藏"),
        "Remove from pinned": MessageLookupByLibrary.simpleMessage("移出顶置"),
        "Removed from Favorites": MessageLookupByLibrary.simpleMessage("已移出收藏"),
        "Removed from pinned": MessageLookupByLibrary.simpleMessage("已移出顶置"),
        "Sent from Android":
            MessageLookupByLibrary.simpleMessage("发送自 Android 客户端"),
        "Sent from Apple": MessageLookupByLibrary.simpleMessage("发送自 iOS 客户端"),
        "Sent from Windows":
            MessageLookupByLibrary.simpleMessage("发送自 Windows 客户端"),
        "Settings": MessageLookupByLibrary.simpleMessage("设置"),
        "Signature": MessageLookupByLibrary.simpleMessage("签名"),
        "Subject": MessageLookupByLibrary.simpleMessage("主题"),
        "Theme": MessageLookupByLibrary.simpleMessage("主题"),
        "User": MessageLookupByLibrary.simpleMessage("用户"),
        "comment": MessageLookupByLibrary.simpleMessage("评论"),
        "commentYourPost": m0,
        "commentYourTopic": m1,
        "edit": MessageLookupByLibrary.simpleMessage("编辑"),
        "lastUpdated": m2,
        "metionYouOnReply": m3,
        "metionYouOnTopic": m4,
        "quote": MessageLookupByLibrary.simpleMessage("引用"),
        "reply": MessageLookupByLibrary.simpleMessage("回复"),
        "replyYourPost": m5,
        "replyYourTopic": m6,
        "updateInterval": m7
      };
}
