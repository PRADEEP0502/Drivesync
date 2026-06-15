import 'package:flutter_test/flutter_test.dart';
import 'package:drivesync_mobile/main.dart';

void main() {
  testWidgets('Welcome screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DriveSyncApp());

    // Verify that the app title "DriveSync" is displayed.
    expect(find.text('DriveSync'), findsOneWidget);
    expect(find.text('Book. Drive. Repeat.'), findsOneWidget);
  });
}
