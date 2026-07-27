import 'package:sqflite/sqflite.dart';
import 'package:wooden_mill_app/database/db_helper.dart';
import 'package:wooden_mill_app/models/log_dimension.dart';
import 'package:wooden_mill_app/models/order.dart';

class OrderRepository {
  final DbHelper _dbHelper;

  OrderRepository({DbHelper? dbHelper}) : _dbHelper = dbHelper ?? DbHelper.instance;

  /// Saves the Order and all its Log Dimensions in a single database transaction.
  /// Returns the inserted Order ID.
  Future<int> saveOrder(OrderModel order) async {
    final db = await _dbHelper.database;
    
    return await db.transaction<int>((txn) async {
      // 1. Insert Order
      final orderId = await txn.insert(
        'Orders',
        order.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 2. Insert each log dimension linked to orderId
      for (final log in order.logs) {
        final logWithOrderId = log.copyWith(orderId: orderId);
        await txn.insert(
          'LogDimensions',
          logWithOrderId.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      return orderId;
    });
  }

  /// Retrieves all orders with their respective logs from SQLite.
  /// Ordered by dateTime DESC (newest first).
  Future<List<OrderModel>> getAllOrders() async {
    final db = await _dbHelper.database;
    
    // Fetch all orders
    final orderMaps = await db.query(
      'Orders',
      orderBy: 'dateTime DESC',
    );

    if (orderMaps.isEmpty) return [];

    final List<OrderModel> orders = [];
    
    for (final orderMap in orderMaps) {
      final orderId = orderMap['id'] as int;
      
      // Fetch logs for this order
      final logMaps = await db.query(
        'LogDimensions',
        where: 'orderId = ?',
        whereArgs: [orderId],
      );

      final logs = logMaps.map((m) => LogDimension.fromMap(m)).toList();
      orders.add(OrderModel.fromMap(orderMap, logs: logs));
    }

    return orders;
  }

  /// Retrieves a specific order by its ID, with its log list.
  Future<OrderModel?> getOrderById(int orderId) async {
    final db = await _dbHelper.database;

    final orderMaps = await db.query(
      'Orders',
      where: 'id = ?',
      whereArgs: [orderId],
      limit: 1,
    );

    if (orderMaps.isEmpty) return null;

    final logMaps = await db.query(
      'LogDimensions',
      where: 'orderId = ?',
      whereArgs: [orderId],
    );

    final logs = logMaps.map((m) => LogDimension.fromMap(m)).toList();
    return OrderModel.fromMap(orderMaps.first, logs: logs);
  }

  /// Deletes all orders and their associated log dimensions in a single transaction.
  Future<void> deleteAllOrders() async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      await txn.delete('LogDimensions');
      await txn.delete('Orders');
    });
  }
}
