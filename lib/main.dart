import 'package:flutter/material.dart';
import 'core/app_controller.dart';
import 'core/app_theme.dart';
import 'screens/home_shell.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final app = AppController();
  await app.bootstrap();
  runApp(ShellGjilanApp(app: app));
}

class ShellGjilanApp extends StatefulWidget {
  final AppController app;
  const ShellGjilanApp({super.key, required this.app});
  @override
  State<ShellGjilanApp> createState() => _ShellGjilanAppState();
}

class _ShellGjilanAppState extends State<ShellGjilanApp> {
  @override
  void initState() {
    super.initState();
    widget.app.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.app.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shell Gjilan',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: widget.app.themeMode,
      home: widget.app.booting
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : widget.app.signedIn
              ? HomeShell(app: widget.app)
              : LoginScreen(app: widget.app),
    );
  }
}
