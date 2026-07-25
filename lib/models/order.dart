import 'package:wooden_mill_app/models/log_dimension.dart';

class OrderModel {
  final int? id;
  final String customerName;
  final String phone;
  final String woodType;
  final int numberOfLogs;
  final double totalVolume;
  final double subtotal;
  final double cuttingCharge;
  final double discount;
  final double finalPrice;
  final DateTime dateTime;
  final List<LogDimension> logs;

  const OrderModel({
    this.id,
    required this.customerName,
    required this.phone,
    required this.woodType,
    required this.numberOfLogs,
    required this.totalVolume,
    required this.subtotal,
    required this.cuttingCharge,
    required this.discount,
    required this.finalPrice,
    required this.dateTime,
    this.logs = const [],
  });

  OrderModel copyWith({
    int? id,
    String? customerName,
    String? phone,
    String? woodType,
    int? numberOfLogs,
    double? totalVolume,
    double? subtotal,
    double? cuttingCharge,
    double? discount,
    double? finalPrice,
    DateTime? dateTime,
    List<LogDimension>? logs,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      phone: phone ?? this.phone,
      woodType: woodType ?? this.woodType,
      numberOfLogs: numberOfLogs ?? this.numberOfLogs,
      totalVolume: totalVolume ?? this.totalVolume,
      subtotal: subtotal ?? this.subtotal,
      cuttingCharge: cuttingCharge ?? this.cuttingCharge,
      discount: discount ?? this.discount,
      finalPrice: finalPrice ?? this.finalPrice,
      dateTime: dateTime ?? this.dateTime,
      logs: logs ?? this.logs,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'customerName': customerName,
      'phone': phone,
      'woodType': woodType,
      'numberOfLogs': numberOfLogs,
      'totalVolume': totalVolume,
      'subtotal': subtotal,
      'cuttingCharge': cuttingCharge,
      'discount': discount,
      'finalPrice': finalPrice,
      'dateTime': dateTime.toIso8601String(),
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, {List<LogDimension> logs = const []}) {
    return OrderModel(
      id: map['id'] as int?,
      customerName: map['customerName'] as String,
      phone: map['phone'] as String,
      woodType: map['woodType'] as String,
      numberOfLogs: map['numberOfLogs'] as int,
      totalVolume: (map['totalVolume'] as num).toDouble(),
      subtotal: (map['subtotal'] as num).toDouble(),
      cuttingCharge: (map['cuttingCharge'] as num).toDouble(),
      discount: (map['discount'] as num).toDouble(),
      finalPrice: (map['finalPrice'] as num).toDouble(),
      dateTime: DateTime.parse(map['dateTime'] as String),
      logs: logs,
    );
  }
}
