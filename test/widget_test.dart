import 'package:flutter_test/flutter_test.dart';
import 'package:share_your_experience/main.dart';
import 'package:share_your_experience/share_experience_launcher.dart';

void main() {
  testWidgets('ShareYourExperienceApp builds successfully', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ShareYourExperienceApp());

    // Verify that the MaterialApp is present.
    expect(find.byType(ShareYourExperienceApp), findsOneWidget);

    // Verify that the home page (ShareExperienceLauncher) is present.
    // Note: This assumes ShareExperienceLauncher is a widget.
    expect(find.byType(ShareExperienceLauncher), findsOneWidget);
  });
}
