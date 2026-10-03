import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/app_controller.dart';
import '../core/app_strings.dart';
import '../models/app_models.dart';
import '../widgets/common_widgets.dart';

class OrdersScreen extends StatefulWidget {
  final AppController app;
  const OrdersScreen({super.key, required this.app});
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<OrderModel> orders = [];
  bool loading = true;
  String? error;
  String t(String k) => AppStrings.t(k, widget.app.language);

  @override
  void initState() { super.initState(); load(); }

  Future<void> load() async {
    setState(() { loading = true; error = null; });
    try { orders = await widget.app.api.orders(); } catch (e) { error = e.toString(); }
    if (mounted) setState(() => loading = false);
  }

  Future<void> add() async {
    final ok = await showDialog<bool>(context: context, builder: (_) => OrderDialog(app: widget.app));
    if (ok == true) await load();
  }

  Future<void> remove(OrderModel o) async {
    try { await widget.app.api.deleteOrder(o.id); await load(); }
    catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 12), child: PageHeader(title: t('orders'), action: FilledButton.icon(onPressed: add, icon: const Icon(Icons.add), label: Text(t('addOrder'))))),
      Expanded(
        child: loading && orders.isEmpty ? const Center(child: CircularProgressIndicator()) : error != null && orders.isEmpty ? ErrorPane(message: error!, onRetry: load) : RefreshIndicator(
          onRefresh: load,
          child: orders.isEmpty ? ListView(children: [SizedBox(height: 220, child: Center(child: Text(t('noOrders'))))]) : ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final o = orders[i];
              return Card(child: ExpansionTile(
                leading: const CircleAvatar(child: Icon(Icons.receipt_long_outlined)),
                title: Text(o.client, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text('${o.date == null ? '—' : DateFormat('dd.MM.yyyy').format(o.date!)} • ${o.items.length} ${t('items')}'),
                trailing: widget.app.user?.isAdmin == true ? IconButton(onPressed: () => remove(o), icon: const Icon(Icons.delete_outline)) : null,
                children: o.items.map((x) => ListTile(dense: true, title: Text(x.name), subtitle: Text('${x.barcode} • ${x.unit}'), trailing: Text('× ${x.quantity}', style: const TextStyle(fontWeight: FontWeight.w700)))).toList(),
              ));
            },
          ),
        ),
      ),
    ]);
  }
}

class OrderDialog extends StatefulWidget {
  final AppController app;
  const OrderDialog({super.key, required this.app});
  @override
  State<OrderDialog> createState() => _OrderDialogState();
}

class _OrderDialogState extends State<OrderDialog> {
  final clientCtrl = TextEditingController();
  DateTime date = DateTime.now();
  final List<_OrderLineDraft> lines = [_OrderLineDraft()];
  bool saving = false;
  String t(String k) => AppStrings.t(k, widget.app.language);

  @override
  void dispose() { clientCtrl.dispose(); for (final l in lines) { l.dispose(); } super.dispose(); }

  Future<void> save() async {
    if (clientCtrl.text.trim().isEmpty) return;
    final parsed = <OrderLine>[];
    for (final l in lines) {
      final qty = int.tryParse(l.qty.text.trim()) ?? 0;
      if (l.name.text.trim().isEmpty || qty <= 0) continue;
      parsed.add(OrderLine(barcode: l.barcode.text.trim(), name: l.name.text.trim(), unit: l.unit.text.trim(), quantity: qty));
    }
    if (parsed.isEmpty) return;
    setState(() => saving = true);
    try {
      await widget.app.api.createOrder(client: clientCtrl.text.trim(), date: date, items: parsed);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally { if (mounted) setState(() => saving = false); }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(t('addOrder')),
      content: SizedBox(width: 700, child: SingleChildScrollView(child: Column(children: [
        TextField(controller: clientCtrl, decoration: InputDecoration(labelText: t('client'))),
        const SizedBox(height: 12),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('${t('date')}: ${DateFormat('dd.MM.yyyy').format(date)}'),
          trailing: const Icon(Icons.calendar_month_outlined),
          onTap: () async { final p = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(2020), lastDate: DateTime(2100)); if (p != null) setState(() => date = p); },
        ),
        const Divider(),
        ...List.generate(lines.length, (i) {
          final l = lines[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 2, child: TextField(controller: l.name, decoration: InputDecoration(labelText: t('name')))),
              const SizedBox(width: 8),
              Expanded(child: TextField(controller: l.barcode, decoration: InputDecoration(labelText: t('barcode')))),
              const SizedBox(width: 8),
              Expanded(child: TextField(controller: l.unit, decoration: InputDecoration(labelText: t('unit')))),
              const SizedBox(width: 8),
              SizedBox(width: 90, child: TextField(controller: l.qty, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: t('quantity')))),
              IconButton(onPressed: lines.length == 1 ? null : () { final x = lines.removeAt(i); x.dispose(); setState(() {}); }, icon: const Icon(Icons.close)),
            ]),
          );
        }),
        Align(alignment: Alignment.centerLeft, child: TextButton.icon(onPressed: () => setState(() => lines.add(_OrderLineDraft())), icon: const Icon(Icons.add), label: Text(t('addLine')))),
      ]))),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: Text(t('cancel'))), FilledButton.icon(onPressed: saving ? null : save, icon: const Icon(Icons.save_outlined), label: Text(t('save')))],
    );
  }
}

class _OrderLineDraft {
  final barcode = TextEditingController();
  final name = TextEditingController();
  final unit = TextEditingController(text: 'copë');
  final qty = TextEditingController(text: '1');
  void dispose() { barcode.dispose(); name.dispose(); unit.dispose(); qty.dispose(); }
}
