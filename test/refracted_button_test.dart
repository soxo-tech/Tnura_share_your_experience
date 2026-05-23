import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:share_your_experience/features/widgets/refracted_button.dart';

void main() {
  group('RefractedButton Widget Tests', () {
    testWidgets('should display label and handle tap', (
      WidgetTester tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RefractedButton(label: 'Submit', onTap: () => tapped = true),
          ),
        ),
      );

      // Verify label is visible
      expect(find.text('Submit'), findsOneWidget);

      // Instead of checking if the indicator is 'nothing', we check the state of the CrossFade
      final crossFade = tester.widget<AnimatedCrossFade>(find.byType(AnimatedCrossFade));
      expect(crossFade.crossFadeState, CrossFadeState.showFirst);

      // Trigger tap
      await tester.tap(find.byType(RefractedButton));
      expect(tapped, isTrue);
    });

    testWidgets('should show loader and ignore taps when isLoading is true', (
      WidgetTester tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RefractedButton(
              label: 'Submit',
              isLoading: true,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      // Start animation
      await tester.pump();

      // Use pump with a specific duration instead of pumpAndSettle.
      // pumpAndSettle times out because the CircularProgressIndicator never stops animating.
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Loader is present (via the Loader class)
      expect(find.byType(Loader), findsOneWidget);
      final crossFade = tester.widget<AnimatedCrossFade>(find.byType(AnimatedCrossFade));
      expect(crossFade.crossFadeState, CrossFadeState.showSecond);

      // Attempt tap
      await tester.tap(find.byType(RefractedButton));

      // Ensure callback was NOT called
      expect(tapped, isFalse);
    });
  });
}
