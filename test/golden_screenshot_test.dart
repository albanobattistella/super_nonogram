/// This file contains the tests that take screenshots of the app.
///
/// Run it with `flutter test --update-goldens` to generate the screenshots
/// or `flutter test` to compare the screenshots to the golden files.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_screenshot/golden_screenshot.dart';
import 'package:super_nonogram/pages/search_page.dart';
import 'package:super_nonogram/pages/title_page.dart';
import 'package:super_nonogram/theme/theme.dart';

import 'util/mock_channel_handlers.dart';

void main() {
  group('Screenshot:', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    setupMockPathProvider();

    _screenshot('1-title', home: TitlePage());

    _screenshot(
      '2-search',
      home: SearchPage(),
      beforeScreenshot: (tester) async {
        final context = tester.element(find.byType(SearchPage));
        if (Theme.of(context).platform == TargetPlatform.linux) {
          // We haven't automated all the screenshots yet, so match the existing
          // screenshots on Linux with a frog search.
          await tester.enterText(find.byType(TextField), 'frog');
        } else {
          await tester.enterText(find.byType(TextField), 'prismatic heart');
        }
        await tester.pump();
      },
    );
  });
}

void _screenshot(
  String description, {
  required Widget home,
  Future<void> Function(WidgetTester tester)? beforeScreenshot,
}) {
  group(description, () {
    for (final goldenDevice in GoldenScreenshotDevices.values) {
      testGoldens('for ${goldenDevice.name}', (tester) async {
        final device = goldenDevice.device;

        await tester.pumpWidget(
          ScreenshotApp.withConditionalTitlebar(
            device: device,
            title: 'Super Nonogram',
            theme: SuperNonogramTheme.createTheme(
              brightness: Brightness.light,
              colorScheme: null,
            ),
            home: home,
          ),
        );

        // One of our tests needs to interact with the UI before taking the screenshot.
        await beforeScreenshot?.call(tester);

        // Precache the images and fonts so they're ready for the screenshot.
        await tester.loadAssets();

        // Pump the widget for a second to ensure animations are complete.
        await tester.pumpFrames(
          tester.widget(find.byType(ScreenshotApp)),
          const Duration(seconds: 1),
        );

        // Take the screenshot and compare it to the golden file.
        await tester.expectScreenshot(device, description);
      });
    }
  });
}
