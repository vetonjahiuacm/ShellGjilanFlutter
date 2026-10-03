import 'package:flutter/material.dart';
import '../core/app_controller.dart';
import '../core/app_strings.dart';

class LoginScreen extends StatefulWidget {
  final AppController app;
  const LoginScreen({super.key, required this.app});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool obscure = true;

  @override
  void dispose() {
    userCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  String t(String key) => AppStrings.t(key, widget.app.language);

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    final ok = await widget.app.login(userCtrl.text.trim(), passCtrl.text);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.app.error ?? t('connectionError'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Form(
                    key: formKey,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      Align(
                        child: Container(
                          width: 92,
                          height: 92,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                          child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(t('appName'), textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 6),
                      Text(t('subtitle'), textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 28),
                      TextFormField(
                        controller: userCtrl,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(labelText: t('username'), prefixIcon: const Icon(Icons.person_outline_rounded)),
                        validator: (v) => (v ?? '').trim().isEmpty ? t('required') : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: passCtrl,
                        obscureText: obscure,
                        onFieldSubmitted: (_) => submit(),
                        decoration: InputDecoration(
                          labelText: t('password'),
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(onPressed: () => setState(() => obscure = !obscure), icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined)),
                        ),
                        validator: (v) => (v ?? '').isEmpty ? t('required') : null,
                      ),
                      const SizedBox(height: 10),
                      Text(t('loginHint'), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 22),
                      SizedBox(
                        height: 50,
                        child: FilledButton.icon(
                          onPressed: widget.app.busy ? null : submit,
                          icon: widget.app.busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.login_rounded),
                          label: Text(t('login')),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
