import 'package:flutter/material.dart';
import '../core/app_controller.dart';
import '../core/app_strings.dart';
import 'articles_screen.dart';
import 'dashboard_screen.dart';
import 'orders_screen.dart';
import 'settings_screen.dart';
import 'statistics_screen.dart';

class HomeShell extends StatefulWidget {
  final AppController app;
  const HomeShell({super.key, required this.app});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;
  String t(String k) => AppStrings.t(k, widget.app.language);

  List<Widget> get pages => [
    DashboardScreen(app: widget.app),
    ArticlesScreen(app: widget.app),
    OrdersScreen(app: widget.app),
    StatisticsScreen(app: widget.app),
    SettingsScreen(app: widget.app),
  ];

  List<NavigationDestination> get destinations => [
    NavigationDestination(icon: const Icon(Icons.dashboard_outlined), selectedIcon: const Icon(Icons.dashboard_rounded), label: t('dashboard')),
    NavigationDestination(icon: const Icon(Icons.inventory_2_outlined), selectedIcon: const Icon(Icons.inventory_2), label: t('articles')),
    NavigationDestination(icon: const Icon(Icons.receipt_long_outlined), selectedIcon: const Icon(Icons.receipt_long), label: t('orders')),
    NavigationDestination(icon: const Icon(Icons.bar_chart_outlined), selectedIcon: const Icon(Icons.bar_chart_rounded), label: t('statistics')),
    NavigationDestination(icon: const Icon(Icons.settings_outlined), selectedIcon: const Icon(Icons.settings), label: t('settings')),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final wide = constraints.maxWidth >= 900;
      if (!wide) {
        return Scaffold(
          body: IndexedStack(index: index, children: pages),
          bottomNavigationBar: NavigationBar(selectedIndex: index, onDestinationSelected: (v) => setState(() => index = v), destinations: destinations),
        );
      }
      return Scaffold(
        body: Row(children: [
          Container(
            width: 250,
            decoration: BoxDecoration(border: Border(right: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: .3)))),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
                child: Row(children: [
                  Container(width: 48, height: 48, padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)), child: Image.asset('assets/images/logo.png')),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t('appName'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)), Text(t('subtitle'), maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall)])),
                ]),
              ),
              const Divider(height: 1),
              const SizedBox(height: 12),
              ...List.generate(destinations.length, (i) {
                final d = destinations[i];
                final selected = index == i;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  child: ListTile(
                    selected: selected,
                    selectedTileColor: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: .65),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    leading: selected ? d.selectedIcon : d.icon,
                    title: Text(d.label),
                    onTap: () => setState(() => index = i),
                  ),
                );
              }),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(14),
                child: ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  leading: CircleAvatar(child: Text((widget.app.user?.username ?? 'U').substring(0, 1).toUpperCase())),
                  title: Text(widget.app.user?.username ?? ''),
                  subtitle: Text(widget.app.user?.isAdmin == true ? t('admin') : t('worker')),
                ),
              ),
            ]),
          ),
          Expanded(child: IndexedStack(index: index, children: pages)),
        ]),
      );
    });
  }
}
