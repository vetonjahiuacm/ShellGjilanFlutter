class AppUser {
  final int id;
  final String username;
  final String role;
  const AppUser({required this.id, required this.username, required this.role});
  bool get isAdmin => role == 'admin';

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: (json['id'] as num).toInt(),
        username: json['username']?.toString() ?? '',
        role: json['roli']?.toString() ?? 'puntor',
      );
}

class DashboardData {
  final int total, expired, expiringSoon, expiringToday, active, suppliers;
  const DashboardData({required this.total, required this.expired, required this.expiringSoon, required this.expiringToday, required this.active, required this.suppliers});

  factory DashboardData.fromJson(Map<String, dynamic> j) => DashboardData(
        total: (j['total'] as num?)?.toInt() ?? 0,
        expired: (j['expired'] as num?)?.toInt() ?? 0,
        expiringSoon: (j['expiring_soon'] as num?)?.toInt() ?? 0,
        expiringToday: (j['expiring_today'] as num?)?.toInt() ?? 0,
        active: (j['active'] as num?)?.toInt() ?? 0,
        suppliers: (j['suppliers'] as num?)?.toInt() ?? 0,
      );
}

class Article {
  final int id;
  final String name;
  final String? barcode;
  final String? supplier;
  final int quantity;
  final DateTime? expiryDate;
  final int? daysRemaining;
  final String status;

  const Article({required this.id, required this.name, required this.barcode, required this.supplier, required this.quantity, required this.expiryDate, required this.daysRemaining, required this.status});

  factory Article.fromJson(Map<String, dynamic> j) => Article(
        id: (j['id'] as num).toInt(),
        name: j['emer']?.toString() ?? '',
        barcode: j['barcodi']?.toString(),
        supplier: j['furnitori']?.toString(),
        quantity: (j['sasia'] as num?)?.toInt() ?? 0,
        expiryDate: j['data_skadimit'] == null ? null : DateTime.tryParse(j['data_skadimit'].toString()),
        daysRemaining: (j['dite_mbetura'] as num?)?.toInt(),
        status: j['status']?.toString() ?? 'unknown',
      );

  Map<String, dynamic> toApiJson() => {
        'emer': name,
        'barcodi': barcode ?? '',
        'furnitori': supplier ?? '',
        'sasia': quantity,
        'data_skadimit': expiryDate == null ? '' : '${expiryDate!.year.toString().padLeft(4, '0')}-${expiryDate!.month.toString().padLeft(2, '0')}-${expiryDate!.day.toString().padLeft(2, '0')}',
      };
}

class OrderLine {
  final int? id;
  final String barcode;
  final String name;
  final String unit;
  final int quantity;
  const OrderLine({this.id, required this.barcode, required this.name, required this.unit, required this.quantity});

  factory OrderLine.fromJson(Map<String, dynamic> j) => OrderLine(
        id: (j['id'] as num?)?.toInt(),
        barcode: j['barcode']?.toString() ?? '',
        name: j['emer']?.toString() ?? '',
        unit: j['njesia']?.toString() ?? '',
        quantity: (j['sasia'] as num?)?.toInt() ?? 1,
      );

  Map<String, dynamic> toJson() => {'barcode': barcode, 'emer': name, 'njesia': unit, 'sasia': quantity};
}

class OrderModel {
  final int id;
  final String client;
  final DateTime? date;
  final List<OrderLine> items;
  const OrderModel({required this.id, required this.client, required this.date, required this.items});

  factory OrderModel.fromJson(Map<String, dynamic> j) => OrderModel(
        id: (j['id'] as num).toInt(),
        client: j['klienti']?.toString() ?? '',
        date: j['data'] == null ? null : DateTime.tryParse(j['data'].toString()),
        items: ((j['artikuj'] as List?) ?? []).map((e) => OrderLine.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
      );
}

class SupplierStat {
  final String supplier;
  final int total, expired, today, expiring;
  const SupplierStat({required this.supplier, required this.total, required this.expired, required this.today, required this.expiring});

  factory SupplierStat.fromJson(Map<String, dynamic> j) => SupplierStat(
        supplier: j['furnitori']?.toString() ?? '',
        total: (j['total'] as num?)?.toInt() ?? 0,
        expired: (j['expired'] as num?)?.toInt() ?? 0,
        today: (j['today'] as num?)?.toInt() ?? 0,
        expiring: (j['expiring'] as num?)?.toInt() ?? 0,
      );
}
