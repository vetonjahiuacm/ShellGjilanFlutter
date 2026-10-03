import 'package:flutter/material.dart';
import '../core/app_controller.dart';
import '../core/app_strings.dart';
import '../models/app_models.dart';
import '../widgets/common_widgets.dart';

class StatisticsScreen extends StatefulWidget {
  final AppController app;
  const StatisticsScreen({super.key, required this.app});
  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  List<SupplierStat> items = [];
  bool loading = true;
  String? error;
  String t(String k) => AppStrings.t(k, widget.app.language);
  @override
  void initState() { super.initState(); load(); }
  Future<void> load() async { setState(() { loading = true; error = null; }); try { items = await widget.app.api.supplierStats(); } catch (e) { error = e.toString(); } if (mounted) setState(() => loading = false); }

  @override
  Widget build(BuildContext context) {
    if (loading && items.isEmpty) return const Center(child: CircularProgressIndicator());
    if (error != null && items.isEmpty) return ErrorPane(message: error!, onRetry: load);
    return RefreshIndicator(
      onRefresh: load,
      child: ListView(padding: const EdgeInsets.all(20), children: [
        PageHeader(title: t('statistics'), subtitle: t('supplierStats'), action: IconButton.filledTonal(onPressed: load, icon: const Icon(Icons.refresh))),
        const SizedBox(height: 18),
        ...items.map((x) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Card(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(x.supplier, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: [
                _pill(context, t('total'), x.total, Colors.blue),
                _pill(context, t('expired'), x.expired, Colors.red),
                _pill(context, t('today'), x.today, Colors.deepOrange),
                _pill(context, t('expiring'), x.expiring, Colors.amber.shade800),
              ]),
            ]),
          )),
        )),
      ]),
    );
  }

  Widget _pill(BuildContext c, String label, int value, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
    decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(20)),
    child: Text('$label: $value', style: TextStyle(color: color, fontWeight: FontWeight.w700)),
  );
}
