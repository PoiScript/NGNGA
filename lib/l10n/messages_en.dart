// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
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
  String get localeName => 'en';

  static m0(username) => "${username} commented your post at";

  static m1(username) => "${username} commented on your topic at";

  static m2(dateTime, seconds) => "Last Updated: ${dateTime} (${seconds}s ago)";

  static m3(username) => "${username} metioned you at";

  static m4(username) => "${username} metioned you at";

  static m5(username) => "${username} replied your post at";

  static m6(username) => "${username} replied your topic at";

  static m7(interval) => "Update Interval: ${interval}s";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function>{
        "About": MessageLookupByLibrary.simpleMessage("About"),
        "Add to Favorites":
            MessageLookupByLibrary.simpleMessage("Add to Favorites"),
        "Add to pinned": MessageLookupByLibrary.simpleMessage("Add to pinned"),
        "Added to Favorites":
            MessageLookupByLibrary.simpleMessage("Added to Favorites"),
        "Added to pinned":
            MessageLookupByLibrary.simpleMessage("Added to pinned"),
        "Auto-update Disabled":
            MessageLookupByLibrary.simpleMessage("Auto-update Disabled"),
        "Auto-update Enabled":
            MessageLookupByLibrary.simpleMessage("Auto-update Enabled"),
        "Change Domain": MessageLookupByLibrary.simpleMessage("Change Domain"),
        "Comment Not Found":
            MessageLookupByLibrary.simpleMessage("Comment Not Found"),
        "Content": MessageLookupByLibrary.simpleMessage("Content"),
        "Copied Link To Clipboard":
            MessageLookupByLibrary.simpleMessage("Copied Link To Clipboard"),
        "Copy Link To Clipboard":
            MessageLookupByLibrary.simpleMessage("Copy Link To Clipboard"),
        "Created At": MessageLookupByLibrary.simpleMessage("Created At"),
        "Display In BBCode":
            MessageLookupByLibrary.simpleMessage("Display In BBCode"),
        "Display In RichText":
            MessageLookupByLibrary.simpleMessage("Display In RichText"),
        "Edit Cookies": MessageLookupByLibrary.simpleMessage("Edit Cookies"),
        "Edited At": MessageLookupByLibrary.simpleMessage("Edited At"),
        "Explore": MessageLookupByLibrary.simpleMessage("Explore"),
        "Favorites": MessageLookupByLibrary.simpleMessage("Favorites"),
        "Inbox": MessageLookupByLibrary.simpleMessage("Inbox"),
        "Language": MessageLookupByLibrary.simpleMessage("Language"),
        "Last Visited": MessageLookupByLibrary.simpleMessage("Last Visited"),
        "Loading...": MessageLookupByLibrary.simpleMessage("Loading..."),
        "No Signature": MessageLookupByLibrary.simpleMessage("No Signature"),
        "Pinned": MessageLookupByLibrary.simpleMessage("Pinned"),
        "Post Not Found":
            MessageLookupByLibrary.simpleMessage("Post Not Found"),
        "Posted At": MessageLookupByLibrary.simpleMessage("Posted At"),
        "Posts Count": MessageLookupByLibrary.simpleMessage("Posts Count"),
        "Remove from Favorites":
            MessageLookupByLibrary.simpleMessage("Remove from Favorites"),
        "Remove from pinned":
            MessageLookupByLibrary.simpleMessage("Remove from pinned"),
        "Removed from Favorites":
            MessageLookupByLibrary.simpleMessage("Removed from Favorites"),
        "Removed from pinned":
            MessageLookupByLibrary.simpleMessage("Removed from pinned"),
        "Sent from Android":
            MessageLookupByLibrary.simpleMessage("Sent from Android"),
        "Sent from Apple":
            MessageLookupByLibrary.simpleMessage("Sent from Apple"),
        "Sent from Windows":
            MessageLookupByLibrary.simpleMessage("Sent from Windows"),
        "Settings": MessageLookupByLibrary.simpleMessage("Settings"),
        "Signature": MessageLookupByLibrary.simpleMessage("Signature"),
        "Subject": MessageLookupByLibrary.simpleMessage("Subject"),
        "Theme": MessageLookupByLibrary.simpleMessage("Theme"),
        "User": MessageLookupByLibrary.simpleMessage("User"),
        "comment": MessageLookupByLibrary.simpleMessage("comment"),
        "commentYourPost": m0,
        "commentYourTopic": m1,
        "edit": MessageLookupByLibrary.simpleMessage("edit"),
        "lastUpdated": m2,
        "metionYouOnReply": m3,
        "metionYouOnTopic": m4,
        "quote": MessageLookupByLibrary.simpleMessage("quote"),
        "reply": MessageLookupByLibrary.simpleMessage("reply"),
        "replyYourPost": m5,
        "replyYourTopic": m6,
        "updateInterval": m7
      };
}
