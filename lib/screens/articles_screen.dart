import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/api_client.dart';
import '../core/app_controller.dart';
import '../core/app_strings.dart';
import '../models/app_models.dart';
import '../widgets/common_widgets.dart';

class ArticlesScreen extends StatefulWidget {
  final AppController app;
  const ArticlesScreen({super.key, required this.app});
  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  final searchCtrl = TextEditingController();
  List<Article> items = [];
  bool loading = true;
  String status = 'all';
  String? error;

  String t(String key) => AppStrings.t(key, widget.app.language);

  @override
  void initState() { super.initState(); load(); }
  @override
  void dispose() { searchCtrl.dispose(); super.dispose(); }

  Future<void> load() async {
    setState(() { loading = true; error = null; });
    try { items = await widget.app.api.articles(search: searchCtrl.text.trim(), status: status); }
    catch (e) { error = e.toString(); }
    if (mounted) setState(() => loading = false);
  }

  Color statusColor(Article a) {
    switch (a.status) {
      case 'expired': return Colors.red;
      case 'today': return Colors.deepOrange;
      case 'expiring': return Colors.amber.shade800;
      case 'active': return Colors.green;
      default: return Colors.grey;
    }
  }

  Future<void> editArticle([Article? article]) async {
    final changed = await showDialog<bool>(
      context: context,
      builder: (_) => ArticleDialog(app: widget.app, article: article),
    );
    if (changed == true) await load();
  }

  Future<void> deleteArticle(Article article) async {
    final yes = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
      title: Text(t('delete')),
      content: Text('${t('confirmDelete')}\n\n${article.name}'),
      actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: Text(t('cancel'))), FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(t('yesDelete')))],
    ));
    if (yes != true) return;
    try {
      await widget.app.api.deleteArticle(article.id);
      await load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: PageHeader(
          title: t('articles'),
          action: widget.app.user?.isAdmin == true ? FilledButton.icon(onPressed: () => editArticle(), icon: const Icon(Icons.add), label: Text(t('addArticle'))) : null,
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Wrap(spacing: 10, runSpacing: 10, children: [
          SizedBox(
            width: 430,
            child: TextField(
              controller: searchCtrl,
              onSubmitted: (_) => load(),
              decoration: InputDecoration(hintText: t('search'), prefixIcon: const Icon(Icons.search), suffixIcon: IconButton(onPressed: load, icon: const Icon(Icons.arrow_forward_rounded))),
            ),
          ),
          DropdownButton<String>(
            value: status,
            items: [
              DropdownMenuItem(value: 'all', child: Text(t('all'))),
              DropdownMenuItem(value: 'expired', child: Text(t('expired'))),
              DropdownMenuItem(value: 'today', child: Text(t('today'))),
              DropdownMenuItem(value: 'expiring', child: Text(t('expiring'))),
              DropdownMenuItem(value: 'active', child: Text(t('active'))),
            ],
            onChanged: (v) { if (v != null) { status = v; load(); } },
          ),
          IconButton.filledTonal(onPressed: load, icon: const Icon(Icons.refresh_rounded)),
        ]),
      ),
      const SizedBox(height: 10),
      Expanded(
        child: loading && items.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : error != null && items.isEmpty
                ? ErrorPane(message: error!, onRetry: load)
                : RefreshIndicator(
                    onRefresh: load,
                    child: items.isEmpty
                        ? ListView(children: [SizedBox(height: 220, child: Center(child: Text(t('noArticles'))))])
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
                            itemCount: items.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 9),
                            itemBuilder: (_, i) {
                              final a = items[i];
                              final color = statusColor(a);
                              return Card(
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(13)), child: Icon(Icons.inventory_2_outlined, color: color)),
                                  title: Text(a.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Text('${a.supplier ?? '—'}  •  ${t('quantity')}: ${a.quantity}  •  ${a.expiryDate == null ? '—' : DateFormat('dd.MM.yyyy').format(a.expiryDate!)}${a.barcode?.isNotEmpty == true ? '  •  ${a.barcode}' : ''}'),
                                  ),
                                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                                    if (a.daysRemaining != null) Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(20)), child: Text('${a.daysRemaining} ${t('days')}', style: TextStyle(color: color, fontWeight: FontWeight.w700))),
                                    if (widget.app.user?.isAdmin == true) ...[
                                      IconButton(onPressed: () => editArticle(a), icon: const Icon(Icons.edit_outlined)),
                                      IconButton(onPressed: () => deleteArticle(a), icon: const Icon(Icons.delete_outline_rounded)),
                                    ],
                                  ]),
                                ),
                              );
                            },
                          ),
                  ),
      ),
    ]);
  }
}

class ArticleDialog extends StatefulWidget {
  final AppController app;
  final Article? article;
  const ArticleDialog({super.key, required this.app, this.article});
  @override
  State<ArticleDialog> createState() => _ArticleDialogState();
}

class _ArticleDialogState extends State<ArticleDialog> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController nameCtrl;
  late final TextEditingController barcodeCtrl;
  late final TextEditingController supplierCtrl;
  late final TextEditingController qtyCtrl;
  late final TextEditingController dateCtrl;
  bool saving = false;

  String t(String k) => AppStrings.t(k, widget.app.language);

  @override
  void initState() {
    super.initState();
    final a = widget.article;
    nameCtrl = TextEditingController(text: a?.name ?? '');
    barcodeCtrl = TextEditingController(text: a?.barcode ?? '');
    supplierCtrl = TextEditingController(text: a?.supplier ?? '');
    qtyCtrl = TextEditingController(text: a?.quantity.toString() ?? '1');
    dateCtrl = TextEditingController(text: a?.expiryDate == null ? '' : DateFormat('yyyy-MM-dd').format(a!.expiryDate!));
  }

  @override
  void dispose() { nameCtrl.dispose(); barcodeCtrl.dispose(); supplierCtrl.dispose(); qtyCtrl.dispose(); dateCtrl.dispose(); super.dispose(); }

  Future<void> pickDate() async {
    final initial = DateTime.tryParse(dateCtrl.text) ?? DateTime.now().add(const Duration(days: 30));
    final picked = await showDatePicker(context: context, initialDate: initial, firstDate: DateTime(2020), lastDate: DateTime(2100));
    if (picked != null) dateCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
  }

  Future<void> save() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    setState(() => saving = true);
    final payload = {
      'emer': nameCtrl.text.trim(),
      'barcodi': barcodeCtrl.text.trim(),
      'furnitori': supplierCtrl.text.trim(),
      'sasia': int.parse(qtyCtrl.text.trim()),
      'data_skadimit': dateCtrl.text.trim(),
    };
    try {
      if (widget.article == null) { await widget.app.api.createArticle(payload); }
      else { await widget.app.api.updateArticle(widget.article!.id, payload); }
      if (mounted) Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.article == null ? t('addArticle') : t('editArticle')),
      content: SizedBox(
        width: 520,
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(children: [
              TextFormField(controller: nameCtrl, decoration: InputDecoration(labelText: t('name')), validator: (v) => (v ?? '').trim().isEmpty ? t('required') : null),
              const SizedBox(height: 12),
              TextFormField(controller: barcodeCtrl, decoration: InputDecoration(labelText: t('barcode'))),
              const SizedBox(height: 12),
              TextFormField(controller: supplierCtrl, decoration: InputDecoration(labelText: t('supplier'))),
              const SizedBox(height: 12),
              TextFormField(controller: qtyCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: t('quantity')), validator: (v) => (int.tryParse((v ?? '').trim()) ?? 0) <= 0 ? t('positiveNumber') : null),
              const SizedBox(height: 12),
              TextFormField(
                controller: dateCtrl,
                readOnly: true,
                onTap: pickDate,
                decoration: InputDecoration(labelText: t('expiryDate'), suffixIcon: const Icon(Icons.calendar_month_outlined)),
                validator: (v) => DateTime.tryParse((v ?? '').trim()) == null ? t('invalidDate') : null,
              ),
            ]),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: saving ? null : () => Navigator.pop(context, false), child: Text(t('cancel'))),
        FilledButton.icon(onPressed: saving ? null : save, icon: saving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save_outlined), label: Text(t('save'))),
      ],
    );
  }
}
