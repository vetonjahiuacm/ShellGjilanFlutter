import 'package:flutter/material.dart';
import '../core/app_controller.dart';
import '../core/app_strings.dart';
import '../widgets/common_widgets.dart';

class SettingsScreen extends StatelessWidget {
  final AppController app;
  const SettingsScreen({super.key, required this.app});
  String t(String k) => AppStrings.t(k, app.language);

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(20), children: [
      PageHeader(title: t('settings')),
      const SizedBox(height: 18),
      Card(child: Column(children: [
        ListTile(leading: const Icon(Icons.person_outline), title: Text(app.user?.username ?? ''), subtitle: Text('${t('role')}: ${app.user?.isAdmin == true ? t('admin') : t('worker')}')),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.language_rounded),
          title: Text(t('language')),
          trailing: DropdownButton<String>(value: app.language, underline: const SizedBox.shrink(), items: const [DropdownMenuItem(value: 'sq', child: Text('Shqip')), DropdownMenuItem(value: 'en', child: Text('English'))], onChanged: (v) { if (v != null) app.setLanguage(v); }),
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.brightness_6_outlined),
          title: Text(t('appearance')),
          trailing: DropdownButton<ThemeMode>(
            value: app.themeMode,
            underline: const SizedBox.shrink(),
            items: [DropdownMenuItem(value: ThemeMode.system, child: Text(t('system'))), DropdownMenuItem(value: ThemeMode.light, child: Text(t('light'))), DropdownMenuItem(value: ThemeMode.dark, child: Text(t('dark')))],
            onChanged: (v) { if (v != null) app.setTheme(v); },
          ),
        ),
      ])),
      const SizedBox(height: 16),
      OutlinedButton.icon(onPressed: app.logout, icon: const Icon(Icons.logout_rounded), label: Text(t('logout'))),
    ]);
  }
}
