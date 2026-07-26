import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wooden_mill_app/core/theme/shadcn_tokens.dart';
import 'package:wooden_mill_app/core/utils/responsive_layout.dart';
import 'package:wooden_mill_app/core/utils/volume_calculator.dart';
import 'package:wooden_mill_app/main.dart';
import 'package:wooden_mill_app/models/order.dart';
import 'package:wooden_mill_app/repositories/order_repository.dart';
import 'package:wooden_mill_app/screens/details/details_screen.dart';
import 'package:wooden_mill_app/widgets/shad_badge.dart';
import 'package:wooden_mill_app/widgets/shad_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final OrderRepository _repository = OrderRepository();
  late Future<List<OrderModel>> _ordersFuture;
  OrderModel? _selectedOrder;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    setState(() {
      _ordersFuture = _repository.getAllOrders();
    });
  }

  void _onOrderSelected(OrderModel order) {
    if (ResponsiveLayout.isPhone(context)) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DetailsScreen(orderId: order.id!),
        ),
      ).then((_) => _loadOrders());
    } else {
      setState(() {
        _selectedOrder = order;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        actions: [
          ListenableBuilder(
            listenable: themeController,
            builder: (context, _) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return IconButton(
                icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
                tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                onPressed: () => themeController.toggleTheme(context),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            tooltip: 'Refresh',
            onPressed: _loadOrders,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<List<OrderModel>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(ShadTokens.spaceXl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: theme.colorScheme.error, size: 48),
                    const SizedBox(height: 16),
                    const Text('Failed to load order history', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(snapshot.error.toString(), textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 16),
                    OutlinedButton(onPressed: _loadOrders, child: const Text('Retry')),
                  ],
                ),
              ),
            );
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 64, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  const Text('No past orders stored', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text('Submit orders from the calculator to view them here.', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            );
          }

          // Automatically select first order on tablet if none selected
          if (_selectedOrder == null && orders.isNotEmpty) {
            _selectedOrder = orders.first;
          }

          return ResponsiveLayout(
            phone: _buildOrderList(orders, theme),
            tablet: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Master List Pane
                SizedBox(
                  width: 360,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(right: BorderSide(color: theme.colorScheme.outline, width: 1)),
                    ),
                    child: _buildOrderList(orders, theme),
                  ),
                ),
                // Detail Preview Pane
                Expanded(
                  child: _selectedOrder != null
                      ? DetailsScreen(orderId: _selectedOrder!.id!, isEmbedded: true)
                      : Center(
                          child: Text(
                            'Select an order to view details',
                            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderList(List<OrderModel> orders, ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(ShadTokens.spaceLg),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final isSelected = _selectedOrder?.id == order.id && !ResponsiveLayout.isPhone(context);

        return Padding(
          padding: const EdgeInsets.only(bottom: ShadTokens.spaceMd),
          child: InkWell(
            onTap: () => _onOrderSelected(order),
            borderRadius: BorderRadius.circular(ShadTokens.radiusMd),
            child: ShadCard(
              backgroundColor: isSelected ? theme.colorScheme.primaryContainer.withValues(alpha: 0.15) : null,
              padding: const EdgeInsets.all(ShadTokens.spaceMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          order.customerName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        VolumeCalculator.formatCurrency(order.finalPrice),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.phone_outlined, size: 14, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        order.phone,
                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13),
                      ),
                      const Spacer(),
                      ShadBadge(
                        label: order.woodType,
                        variant: ShadBadgeVariant.secondary,
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.layers_outlined, size: 14, color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            '${order.numberOfLogs} ${order.numberOfLogs == 1 ? "log" : "logs"} • ${VolumeCalculator.formatVolume(order.totalVolume)} cft',
                            style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
                          ),
                        ],
                      ),
                      Text(
                        DateFormat('dd MMM, hh:mm a').format(order.dateTime),
                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8), fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
