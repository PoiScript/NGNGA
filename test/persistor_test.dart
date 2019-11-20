import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ngnga/main.dart';
import 'package:ngnga/store/state.dart';

class TestPersistor extends Persistor {
  Future<void> deleteState() => null;
  Future<void> persistDifference({lastPersistedState, newState}) => null;
  Future readState() => null;
}

void main() {
  testWidgets('Route to NewPage if given state is empty', (tester) async {
    await tester.pumpWidget(MyApp(
      state: AppState.empty(),
      persistor: TestPersistor(),
    ));
  });
}
