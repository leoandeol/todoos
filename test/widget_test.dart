import 'package:flutter_test/flutter_test.dart';

import 'package:todoos/main.dart';
import 'package:todoos/app_state.dart';

void main() {
  testWidgets('App renders without errors', (WidgetTester tester) async {
    final appState = await AppState.init();
    await tester.pumpWidget(TodoosApp(appState: appState));
    await tester.pumpAndSettle();
    expect(find.text('Todoos'), findsOneWidget);
  });
}
