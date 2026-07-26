import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wooden_mill_app/database/db_helper.dart';
import 'package:wooden_mill_app/models/order.dart';
import 'package:wooden_mill_app/repositories/order_repository.dart';

class BackupRepository {
  static const String _lastBackupKey = 'last_backup_timestamp';
  final OrderRepository _orderRepository = OrderRepository();

  /// Creates a structured JSON backup file of all Orders & Logs
  Future<File?> createBackup() async {
    try {
      final orders = await _orderRepository.getAllOrders();
      final backupData = {
        'version': 1,
        'app': 'Timbr',
        'createdAt': DateTime.now().toIso8601String(),
        'orders': orders.map((o) => o.toMap()).toList(),
      };

      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final backupFile = File('${dir.path}/Timbr_Backup_$timestamp.json');

      await backupFile.writeAsString(jsonEncode(backupData));

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastBackupKey, DateTime.now().toIso8601String());

      return backupFile;
    } catch (_) {
      return null;
    }
  }

  /// Restores Orders & Logs from a JSON backup file content inside a single transaction
  Future<bool> restoreBackupFromFile(File backupFile) async {
    try {
      final jsonStr = await backupFile.readAsString();
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;

      if (data['app'] != 'Timbr' || data['orders'] == null) {
        return false;
      }

      final rawOrders = data['orders'] as List<dynamic>;
      final orders = rawOrders.map((map) {
        final orderMap = Map<String, dynamic>.from(map as Map);
        return OrderModel.fromMap(orderMap);
      }).toList();

      final db = await DbHelper.instance.database;
      await db.transaction((txn) async {
        await txn.delete('LogDimensions');
        await txn.delete('Orders');

        for (final order in orders) {
          final orderId = await txn.insert('Orders', {
            'customerName': order.customerName,
            'phone': order.phone,
            'woodType': order.woodType,
            'numberOfLogs': order.numberOfLogs,
            'totalVolume': order.totalVolume,
            'subtotal': order.subtotal,
            'cuttingCharge': order.cuttingCharge,
            'discount': order.discount,
            'finalPrice': order.finalPrice,
            'dateTime': order.dateTime.toIso8601String(),
          });

          for (final log in order.logs) {
            await txn.insert('LogDimensions', {
              'orderId': orderId,
              'length': log.length,
              'girth': log.girth,
              'volume': log.volume,
              'price': log.price,
            });
          }
        }
      });

      return true;
    } catch (_) {
      return false;
    }
  }

  /// Retrieves timestamp of last successful backup
  Future<DateTime?> getLastBackupTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_lastBackupKey);
      if (str != null) {
        return DateTime.tryParse(str);
      }
    } catch (_) {}
    return null;
  }
}
