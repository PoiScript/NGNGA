import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'l10n/messages_all.dart';

class AppLocalizations {
  AppLocalizations(this.localeName);

  static Future<AppLocalizations> load(Locale locale) {
    final String name =
        locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName)
        .then((_) => AppLocalizations(localeName));
  }

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations);

  final String localeName;

  String get favorites => Intl.message('Favorites', locale: localeName);
  String get explore => Intl.message('Explore', locale: localeName);
  String get inbox => Intl.message('Inbox', locale: localeName);
  String get pinned => Intl.message('Pinned', locale: localeName);
  String get settings => Intl.message('Settings', locale: localeName);

  String get addToFavorites =>
      Intl.message('Add to Favorites', locale: localeName);
  String get addedToFavorites =>
      Intl.message('Added to Favorites', locale: localeName);

  String get removeFromFavorites =>
      Intl.message('Remove from Favorites', locale: localeName);
  String get removedFromFavorites =>
      Intl.message('Removed from Favorites', locale: localeName);

  String get addToPinned => Intl.message('Add to pinned', locale: localeName);
  String get addedToPinned =>
      Intl.message('Added to pinned', locale: localeName);

  String get removeFromPinned =>
      Intl.message('Remove from pinned', locale: localeName);
  String get removedFromPinned =>
      Intl.message('Removed from pinned', locale: localeName);

  String get copyLinkToClipboard =>
      Intl.message('Copy Link To Clipboard', locale: localeName);
  String get copiedLinkToClipboard =>
      Intl.message('Copied Link To Clipboard', locale: localeName);

  String get comment => Intl.message('comment', locale: localeName);
  String get edit => Intl.message('edit', locale: localeName);
  String get reply => Intl.message('reply', locale: localeName);
  String get quote => Intl.message('quote', locale: localeName);
  String get displayInBBCode =>
      Intl.message('Display In BBCode', locale: localeName);
  String get dispalyInRichText =>
      Intl.message('Display In RichText', locale: localeName);
  String get editedAt => Intl.message('Edited At', locale: localeName);
  String get postedAt => Intl.message('Posted At', locale: localeName);
  String get sentFromAndroid =>
      Intl.message('Sent from Android', locale: localeName);
  String get sentFromApple =>
      Intl.message('Sent from Apple', locale: localeName);
  String get sentFromWindows =>
      Intl.message('Sent from Windows', locale: localeName);

  String get theme => Intl.message('Theme', locale: localeName);
  String get language => Intl.message('Language', locale: localeName);
  String get about => Intl.message('About', locale: localeName);
  String get changeDomain => Intl.message('Change Domain', locale: localeName);
  String get editCookies => Intl.message('Edit Cookies', locale: localeName);

  String get autoUpdateEnabled =>
      Intl.message('Auto-update Enabled', locale: localeName);
  String get autoUpdateDisabled =>
      Intl.message('Auto-update Disabled', locale: localeName);
  String get loading => Intl.message('Loading...', locale: localeName);
  String lastUpdated(String dateTime, int seconds) =>
      Intl.message('Last Updated: $dateTime (${seconds}s ago)',
          name: 'lastUpdated', args: [dateTime, seconds], locale: localeName);
  String updateInterval(int interval) =>
      Intl.message('Update Interval: ${interval}s',
          name: 'updateInterval', args: [interval], locale: localeName);

  String get subject => Intl.message('Subject', locale: localeName);
  String get content => Intl.message('Content', locale: localeName);

  String get signature => Intl.message('Signature', locale: localeName);
  String get postsCount => Intl.message('Posts Count', locale: localeName);
  String get lastVisited => Intl.message('Last Visited', locale: localeName);
  String get createdAt => Intl.message('Created At', locale: localeName);
  String get user => Intl.message('User', locale: localeName);
  String get noSignature => Intl.message('No Signature', locale: localeName);
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'zh'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}