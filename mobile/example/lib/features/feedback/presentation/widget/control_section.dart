import 'package:camera_app/features/theme/presenation/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ControlSection extends StatelessWidget {
  const ControlSection({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final systemBrightness = MediaQuery.platformBrightnessOf(context);
    final isUsingSystem = themeProvider.themeMode == ThemeMode.system;

    // Determine if the switch should be ON (dark) or OFF (light)
    final isDark = isUsingSystem
        ? systemBrightness == Brightness.dark
        : themeProvider.themeMode == ThemeMode.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('CONTROLS', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ListTile(
          leading: const Icon(Icons.brightness_2),
          title: const Text('Change Theme'),
          trailing: Switch(
            value: isDark,
            onChanged: (value) {
              themeProvider.toggle(value);
            },
          ),
        ),
        Row(
          children: [
            const Icon(Icons.text_fields),
            const SizedBox(width: 16),
            const Text('Adjust font size'),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                themeProvider.setFontSize(
                    (themeProvider.fontSize - 1).clamp(12.0, 24.0));
              },
            ),
            Text(themeProvider.fontSize.toInt().toString()),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                themeProvider.setFontSize(
                    (themeProvider.fontSize + 1).clamp(12.0, 24.0));
              },
            ),
          ],
        ),
        ListTile(
          leading: const Icon(Icons.admin_panel_settings),
          title: const Text('Admin login'),
          onTap: () {},
        ),
      ],
    );
  }
}
