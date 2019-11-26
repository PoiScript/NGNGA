import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ngnga/main.dart';
import 'package:ngnga/store/state.dart';

void main() {
  testWidgets('Route to WelcomePage if given state id empty', (tester) async {
    final store = Store<AppState>(
      initialState: AppState.empty(),
      // actionObservers: [Log<AppState>.printer()],
      // modelObserver: DefaultModelObserver(),
    );

    await tester.pumpWidget(MyApp(store: store));

    expect(find.text('Welcome to NGNGA'), findsOneWidget);
  });
}
