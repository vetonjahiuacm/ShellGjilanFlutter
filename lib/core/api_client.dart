import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/app_models.dart';

class ApiException implements Exception {
  final String message;
  final int statusCode;
  const ApiException(this.message, this.statusCode);
  @override
  String toString() => message;
}

class ApiClient {
  static const String baseUrl = 'https://shellgjilan2.pythonanywhere.com/api/v1';
  String? token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null && token!.isNotEmpty) 'Authorization': 'Bearer $token',
      };

  dynamic _decode(http.Response r) {
    dynamic data;
    try {
      data = jsonDecode(utf8.decode(r.bodyBytes));
    } catch (_) {
      data = <String, dynamic>{};
    }
    if (r.statusCode < 200 || r.statusCode >= 300) {
      final message = data is Map && data['error'] != null ? data['error'].toString() : 'HTTP ${r.statusCode}';
      throw ApiException(message, r.statusCode);
    }
    return data;
  }

  Future<(String, AppUser)> login(String username, String password) async {
    final r = await http.post(Uri.parse('$baseUrl/auth/login'), headers: _headers, body: jsonEncode({'username': username, 'password': password})).timeout(const Duration(seconds: 20));
    final d = Map<String, dynamic>.from(_decode(r) as Map);
    return (d['token'].toString(), AppUser.fromJson(Map<String, dynamic>.from(d['user'] as Map)));
  }

  Future<AppUser> me() async {
    final r = await http.get(Uri.parse('$baseUrl/auth/me'), headers: _headers).timeout(const Duration(seconds: 20));
    final d = Map<String, dynamic>.from(_decode(r) as Map);
    return AppUser.fromJson(Map<String, dynamic>.from(d['user'] as Map));
  }

  Future<DashboardData> dashboard() async {
    final r = await http.get(Uri.parse('$baseUrl/dashboard'), headers: _headers).timeout(const Duration(seconds: 20));
    return DashboardData.fromJson(Map<String, dynamic>.from(_decode(r) as Map));
  }

  Future<List<Article>> articles({String search = '', String status = 'all', int page = 1, int perPage = 100}) async {
    final uri = Uri.parse('$baseUrl/artikuj').replace(queryParameters: {'search': search, 'status': status, 'page': '$page', 'per_page': '$perPage'});
    final r = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 20));
    final d = Map<String, dynamic>.from(_decode(r) as Map);
    return ((d['items'] as List?) ?? []).map((e) => Article.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<Article> createArticle(Map<String, dynamic> payload) async {
    final r = await http.post(Uri.parse('$baseUrl/artikuj'), headers: _headers, body: jsonEncode(payload)).timeout(const Duration(seconds: 20));
    final d = Map<String, dynamic>.from(_decode(r) as Map);
    return Article.fromJson(Map<String, dynamic>.from(d['item'] as Map));
  }

  Future<Article> updateArticle(int id, Map<String, dynamic> payload) async {
    final r = await http.put(Uri.parse('$baseUrl/artikuj/$id'), headers: _headers, body: jsonEncode(payload)).timeout(const Duration(seconds: 20));
    final d = Map<String, dynamic>.from(_decode(r) as Map);
    return Article.fromJson(Map<String, dynamic>.from(d['item'] as Map));
  }

  Future<void> deleteArticle(int id) async {
    final r = await http.delete(Uri.parse('$baseUrl/artikuj/$id'), headers: _headers).timeout(const Duration(seconds: 20));
    _decode(r);
  }

  Future<List<OrderModel>> orders() async {
    final r = await http.get(Uri.parse('$baseUrl/porosi'), headers: _headers).timeout(const Duration(seconds: 20));
    final d = Map<String, dynamic>.from(_decode(r) as Map);
    return ((d['items'] as List?) ?? []).map((e) => OrderModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<OrderModel> createOrder({required String client, required DateTime date, required List<OrderLine> items}) async {
    final payload = {
      'klienti': client,
      'data': '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      'artikuj': items.map((e) => e.toJson()).toList(),
    };
    final r = await http.post(Uri.parse('$baseUrl/porosi'), headers: _headers, body: jsonEncode(payload)).timeout(const Duration(seconds: 20));
    final d = Map<String, dynamic>.from(_decode(r) as Map);
    return OrderModel.fromJson(Map<String, dynamic>.from(d['item'] as Map));
  }

  Future<void> deleteOrder(int id) async {
    final r = await http.delete(Uri.parse('$baseUrl/porosi/$id'), headers: _headers).timeout(const Duration(seconds: 20));
    _decode(r);
  }

  Future<List<SupplierStat>> supplierStats() async {
    final r = await http.get(Uri.parse('$baseUrl/statistikat/furnitore'), headers: _headers).timeout(const Duration(seconds: 20));
    final d = Map<String, dynamic>.from(_decode(r) as Map);
    return ((d['items'] as List?) ?? []).map((e) => SupplierStat.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }
}
