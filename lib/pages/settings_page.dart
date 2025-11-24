import 'package:flutter/material.dart';
import 'package:super_nonogram/data/stows.dart';
import 'package:super_nonogram/i18n/strings.g.dart';
import 'package:super_nonogram/settings/animated_app_icon.dart';
import 'package:super_nonogram/settings/settings_item.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final iconTheme = IconTheme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(t.settings.settings)),
      body: DefaultTextStyle.merge(
        style: TextStyle(color: colorScheme.onSurface),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              children: [
                // hyperlegible font
                SettingsItem(
                  onTap: () => setState(() {
                    stows.hyperlegibleFont.value =
                        !stows.hyperlegibleFont.value;
                  }),
                  children: [
                    Text(
                      'Aa',
                      style: textTheme.displaySmall?.copyWith(
                        fontSize: (iconTheme.size ?? 24) * 0.8,
                      ),
                    ),
                    Text(t.settings.hyperlegibleFont),
                    Switch(
                      value: stows.hyperlegibleFont.value,
                      onChanged: (_) => setState(() {
                        stows.hyperlegibleFont.value =
                            !stows.hyperlegibleFont.value;
                      }),
                    ),
                  ],
                ),
                const Divider(),

                SettingsItem(
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: t.title.appName,
                      applicationLegalese: t.settings.legalese,
                    );
                  },
                  children: [
                    const Icon(Icons.info),
                    Text(t.title.appName),
                    Text(t.settings.about, style: textTheme.labelMedium),
                  ],
                ),
                const Divider(),

                // something to put at the bottom after the last divider
                const AnimatedAppIcon(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
