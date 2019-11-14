import 'package:flutter_test/flutter_test.dart';

import 'package:ngnga/main.dart';
import 'package:ngnga/store/state.dart';

void main() {
  testWidgets('Route to NewPage if given state is empty', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(AppState.empty()));
  });
}
