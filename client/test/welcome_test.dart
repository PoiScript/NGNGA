import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ngnga/welcome/welcome_page.dart';

void main() {
  group('Welcome Page', () {
    final Finder uid = find.widgetWithText(TextFormField, 'ngaPassportUid');
    final Finder cid = find.widgetWithText(TextFormField, 'ngaPassportCid');
    final Finder login = find.widgetWithText(FlatButton, 'Login');
    final Finder checking = find.widgetWithText(FlatButton, 'Checking...');
    final Finder snackbar = find.widgetWithText(SnackBar, 'invalid');

    testWidgets('show error text when input is empty', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en', ''),
          home: WelcomePage(
            validate: (_, __) async => null,
            logged: (_, __) async {},
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Please enter some text'), findsNothing);

      await tester.tap(login);

      await tester.pump();

      expect(find.text('Please enter some text'), findsNWidgets(2));
    });

    testWidgets('show error text when input is invalid', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en', ''),
          home: WelcomePage(
            validate: (_, __) async => false,
            logged: (_, __) async {},
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Please input number only'), findsNothing);
      expect(find.text('Please input ASCII only'), findsNothing);

      await tester.enterText(uid, 'abc');
      await tester.enterText(cid, '一二三');
      await tester.tap(login);

      await tester.pump();

      expect(find.text('Please input number only'), findsOneWidget);
      expect(find.text('Please input ASCII only'), findsOneWidget);
    });

    testWidgets('show a checking message and disable input when validating',
        (tester) async {
      Completer<bool> completer = Completer<bool>();

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en', ''),
          home: WelcomePage(
            validate: (_, __) => completer.future,
            logged: (_, __) async {},
          ),
        ),
      );

      await tester.pump();

      expect(checking, findsNothing);

      await tester.enterText(uid, '123');
      await tester.enterText(cid, 'abc');
      await tester.tap(login);

      await tester.pump();

      expect(checking, findsOneWidget);

      completer.complete(false);

      await tester.pump();

      expect(checking, findsNothing);
    });

    testWidgets('show a snackbar when validation failed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en', ''),
          home: WelcomePage(
            validate: (_, __) => Future.value(false),
            logged: (_, __) async {},
          ),
        ),
      );

      await tester.pump();

      expect(snackbar, findsNothing);

      await tester.enterText(uid, '123');
      await tester.enterText(cid, 'abc');
      await tester.tap(login);

      await tester.pump();

      expect(snackbar, findsOneWidget);
    });
  });
}
