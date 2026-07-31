import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:share_your_experience/features/model/templates_model.dart';
import 'package:share_your_experience/features/view/share_your_experience.dart';
import 'package:share_your_experience/share_experience_launcher.dart';

/// Widget tests for [ShareExperienceLauncher].
///
/// These verify the host-driven contract: templates passed by the host render,
/// and the "something went wrong" message shows when none are supplied.
///
/// Each launcher is wrapped in a [MaterialApp] so it has the [Directionality]
/// and media data its descendants require.
Widget _wrap(Widget child) => MaterialApp(home: child);

void main() {
  group('ShareExperienceLauncher', () {
    testWidgets('renders the templates supplied by the host', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ShareExperienceLauncher(
            isStandalone: true,
            templates: [
              TemplatesModel(
                gradient: '#ADDFDE',
                title: 'Sample template title',
                content: 'Sample content',
                bgImage: 'https://example.com/image.jpg',
                badgeContent: 'Sample badge',
                isCustom: false,
              ),
            ],
          ),
        ),
      );
      // A single frame is enough to build the list; network/SVG assets resolve
      // asynchronously and are intentionally not awaited here.
      await tester.pump();

      expect(find.byType(ShareYourExperience), findsOneWidget);
      expect(find.text('Choose a template'), findsOneWidget);
      expect(find.text('Sample template title'), findsOneWidget);
      expect(find.text('Something went wrong'), findsNothing);
    });

    testWidgets('shows the error message when no templates are supplied', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const ShareExperienceLauncher(isStandalone: true)),
      );
      await tester.pump();

      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('shows the error message when an empty list is supplied', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const ShareExperienceLauncher(isStandalone: true, templates: []),
        ),
      );
      await tester.pump();

      expect(find.text('Something went wrong'), findsOneWidget);
    });
  });
}
