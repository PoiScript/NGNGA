import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:business/app_state.dart';
import 'package:ngnga/main.dart';
import 'package:ngnga/welcome/welcome_page.dart';

void main() {
  testWidgets('Route to WelcomePage if given user is null', (tester) async {
    final store = Store(initialState: AppState());

    await tester.pumpWidget(MyApp(store: store));

    await tester.pumpAndSettle();

    expect(find.byType(WelcomePage), findsOneWidget);
  });
}
