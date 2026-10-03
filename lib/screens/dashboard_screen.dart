import 'package:flutter/material.dart';
import '../core/app_controller.dart';
import '../core/app_strings.dart';
import '../models/app_models.dart';
import '../widgets/common_widgets.dart';

class DashboardScreen extends StatefulWidget {
  final AppController app;
  const DashboardScreen({super.key, required this.app});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DashboardData? data;
  String? error;
  bool loading = true;

  String t(String key) => AppStrings.t(key, widget.app.language);

  @override
  void initState() { super.initState(); load(); }

  Future<void> load() async {
    setState(() { loading = true; error = null; });
    try { data = await widget.app.api.dashboard(); }
    catch (e) { error = e.toString(); }
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading && data == null) return const Center(child: CircularProgressIndicator());
    if (error != null && data == null) return ErrorPane(message: error!, onRetry: load);
    final d = data!;
    return RefreshIndicator(
      onRefresh: load,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          PageHeader(
            title: '${t('welcome')}, ${widget.app.user?.username ?? ''}',
            subtitle: t('overview'),
            action: IconButton.filledTonal(onPressed: load, tooltip: t('refresh'), icon: const Icon(Icons.refresh_rounded)),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(builder: (context, c) {
            final cols = c.maxWidth >= 1100 ? 3 : c.maxWidth >= 650 ? 2 : 2;
            final ratio = c.maxWidth < 420 ? 1.15 : 1.65;
            return GridView.count(
              crossAxisCount: cols,
              childAspectRatio: ratio,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                KpiCard(title: t('total'), value: d.total, icon: Icons.inventory_2_outlined, color: Colors.blue),
                KpiCard(title: t('expired'), value: d.expired, icon: Icons.error_outline_rounded, color: Colors.red),
                KpiCard(title: t('today'), value: d.expiringToday, icon: Icons.today_outlined, color: Colors.deepOrange),
                KpiCard(title: t('expiring'), value: d.expiringSoon, icon: Icons.schedule_rounded, color: Colors.amber.shade800),
                KpiCard(title: t('active'), value: d.active, icon: Icons.check_circle_outline_rounded, color: Colors.green),
                KpiCard(title: t('suppliers'), value: d.suppliers, icon: Icons.local_shipping_outlined, color: Colors.purple),
              ],
            );
          }),
          const SizedBox(height: 18),
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              leading: const CircleAvatar(child: Icon(Icons.cloud_done_outlined)),
              title: Text(t('server')),
              subtitle: const Text('shellgjilan2.pythonanywhere.com'),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 9, height: 9, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text(t('online')),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
