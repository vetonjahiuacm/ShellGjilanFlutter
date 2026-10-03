import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/app_models.dart';
import 'api_client.dart';

class AppController extends ChangeNotifier {
  final ApiClient api = ApiClient();
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  AppUser? user;
  bool booting = true;
  bool busy = false;
  String? error;
  String language = 'sq';
  ThemeMode themeMode = ThemeMode.system;

  bool get signedIn => user != null && api.token != null;

  Future<void> bootstrap() async {
    booting = true;
    notifyListeners();
    try {
      language = await storage.read(key: 'language') ?? 'sq';
      final theme = await storage.read(key: 'theme') ?? 'system';
      themeMode = theme == 'dark' ? ThemeMode.dark : theme == 'light' ? ThemeMode.light : ThemeMode.system;
      api.token = await storage.read(key: 'auth_token');
      if (api.token != null) {
        try {
          user = await api.me();
        } catch (_) {
          api.token = null;
          user = null;
          await storage.delete(key: 'auth_token');
        }
      }
    } finally {
      booting = false;
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password) async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      final result = await api.login(username, password);
      api.token = result.$1;
      user = result.$2;
      await storage.write(key: 'auth_token', value: api.token);
      return true;
    } on ApiException catch (e) {
      error = e.message;
      return false;
    } catch (_) {
      error = 'Nuk mund të lidhemi me serverin.';
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    api.token = null;
    user = null;
    await storage.delete(key: 'auth_token');
    notifyListeners();
  }

  Future<void> setLanguage(String value) async {
    language = value;
    await storage.write(key: 'language', value: value);
    notifyListeners();
  }

  Future<void> setTheme(ThemeMode value) async {
    themeMode = value;
    final raw = value == ThemeMode.dark ? 'dark' : value == ThemeMode.light ? 'light' : 'system';
    await storage.write(key: 'theme', value: raw);
    notifyListeners();
  }
}
