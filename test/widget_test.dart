// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fixora/providers/app_state.dart';
import 'package:fixora/main.dart';

void main() {
  testWidgets('App loads splash screen test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const FixoraApp(),
      ),
    );

    // Allow fallback navigation timer to fire (navigates to Language Selection Screen)
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    // Verify that Language Selection screen loads
    expect(find.text('Select Language'), findsOneWidget);

    // Tap the Confirm button to navigate to Auth Selection
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    // Verify that Auth Selection screen loads with the roles
    expect(find.text('Select ID'), findsOneWidget);
    expect(find.text('Customer'), findsOneWidget);
    expect(find.text('Shop keeper'), findsOneWidget);
    expect(find.text('Technician'), findsOneWidget);
  });
}
