import 'dart:math';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:games_services/games_services.dart';
import 'package:go_router/go_router.dart';
import 'package:super_nonogram/data/stows.dart';
import 'package:super_nonogram/games_services/games_services_helper.dart';
import 'package:super_nonogram/i18n/strings.g.dart';
import 'package:super_nonogram/pages/search_page.dart';
import 'package:super_nonogram/pages/settings_page.dart';

class TitlePage extends StatelessWidget {
  const TitlePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final screenSize = MediaQuery.sizeOf(context);

    final double buttonFontSize = switch (screenSize.width) {
      < 400 => 16,
      < 600 => 24,
      _ => 32,
    };

    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(buttonFontSize * 2),
    );
    final elevatedButtonStyle = ElevatedButtonTheme.of(context).style!.copyWith(
      shape: WidgetStatePropertyAll(buttonShape),
      textStyle: WidgetStatePropertyAll(textTheme.titleLarge!),
    );

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            vertical: 32,
            horizontal: max((screenSize.width - 600) / 2, 16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(t.title.appName, style: textTheme.displayMedium),
              const SizedBox(height: 64),
              ElevatedButton(
                style: elevatedButtonStyle,
                onPressed: () {
                  context.push('/play?level=${stows.currentLevel.value}');
                },
                child: Padding(
                  padding: EdgeInsets.all(buttonFontSize / 2),
                  child: Text(t.title.playLevels),
                ),
              ),
              const SizedBox(height: 16),
              OpenContainer(
                tappable: false,
                closedShape: buttonShape,
                closedColor: Colors.transparent,
                closedElevation: 0,
                openColor: Colors.transparent,
                openElevation: 0,
                closedBuilder: (context, action) {
                  return ElevatedButton(
                    style: elevatedButtonStyle,
                    onPressed: action,
                    child: Padding(
                      padding: EdgeInsets.all(buttonFontSize / 2),
                      child: Text(t.title.playImages),
                    ),
                  );
                },
                openBuilder: (context, action) {
                  return const SearchPage();
                },
              ),
              if (GamesServicesHelper.osSupported) ...[
                const SizedBox(height: 16),
                ElevatedButton(
                  style: elevatedButtonStyle,
                  onPressed: () => runAfterGamesSignIn(
                    () => GamesServices.showAchievements(),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(buttonFontSize / 2),
                    child: Text(t.title.achievements),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              OpenContainer(
                tappable: false,
                closedShape: buttonShape,
                closedColor: Colors.transparent,
                closedElevation: 0,
                openColor: Colors.transparent,
                openElevation: 0,
                closedBuilder: (context, action) {
                  return ElevatedButton(
                    style: elevatedButtonStyle,
                    onPressed: action,
                    child: Padding(
                      padding: EdgeInsets.all(buttonFontSize / 2),
                      child: Text(t.settings.settings),
                    ),
                  );
                },
                openBuilder: (context, action) {
                  return const SettingsPage();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
