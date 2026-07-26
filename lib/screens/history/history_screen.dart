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
  final TextEditingController _searchController = TextEditingController();

  late Future<List<OrderModel>> _ordersFuture;
  OrderModel? _selectedOrder;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  List<OrderModel> _filterOrders(List<OrderModel> orders) {
    if (_searchQuery.isEmpty) return orders;
    return orders.where((order) {
      final name = order.customerName.toLowerCase();
      final phone = order.phone.toLowerCase();
      final wood = order.woodType.toLowerCase();
      return name.contains(_searchQuery) || phone.contains(_searchQuery) || wood.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPhone = ResponsiveLayout.isPhone(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        actions: [
          if (isPhone)
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
            tooltip: 'Refresh Orders',
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

          final allOrders = snapshot.data ?? [];
          final filteredOrders = _filterOrders(allOrders);

          if (allOrders.isEmpty) {
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
          if (_selectedOrder == null && filteredOrders.isNotEmpty) {
            _selectedOrder = filteredOrders.first;
          }

          return ResponsiveLayout(
            phone: Column(
              children: [
                _buildSearchBar(theme),
                Expanded(child: _buildOrderList(filteredOrders, theme)),
              ],
            ),
            tablet: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Master List Pane (45% Flex Width)
                Expanded(
                  flex: 45,
                  child: Column(
                    children: [
                      _buildSearchBar(theme),
                      Expanded(child: _buildOrderList(filteredOrders, theme)),
                    ],
                  ),
                ),
                VerticalDivider(width: 1, thickness: 1, color: theme.colorScheme.outline),
                // Right Detail Preview Pane (55% Flex Width)
                Expanded(
                  flex: 55,
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

  Widget _buildSearchBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(ShadTokens.spaceLg, ShadTokens.spaceLg, ShadTokens.spaceLg, ShadTokens.spaceSm),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by customer, phone, or wood type...',
          prefixIcon: const Icon(Icons.search, size: 18),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        ),
      ),
    );
  }

  Widget _buildOrderList(List<OrderModel> orders, ThemeData theme) {
    if (orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(ShadTokens.spaceLg),
          child: Text(
            'No matching orders found',
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
      );
    }

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
