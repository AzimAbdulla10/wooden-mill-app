import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wooden_mill_app/core/utils/volume_calculator.dart';
import 'package:wooden_mill_app/models/order.dart';
import 'package:wooden_mill_app/repositories/order_repository.dart';

class DetailsScreen extends StatefulWidget {
  final int orderId;

  const DetailsScreen({super.key, required this.orderId});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final OrderRepository _repository = OrderRepository();
  late Future<OrderModel?> _orderFuture;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  void _loadOrder() {
    setState(() {
      _orderFuture = _repository.getOrderById(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Order Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<OrderModel?>(
        future: _orderFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: theme.colorScheme.error, size: 48),
                  const SizedBox(height: 16),
                  const Text('Error loading order details'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadOrder,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final order = snapshot.data;
          if (order == null) {
            return const Center(
              child: Text('Order not found'),
            );
          }

          final formattedDate = DateFormat('dd MMMM yyyy, hh:mm a').format(order.dateTime);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Customer details card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Customer Information',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                order.woodType,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(Icons.person_outline, 'Customer Name', order.customerName),
                        const SizedBox(height: 10),
                        _buildInfoRow(Icons.phone_outlined, 'Phone Number', order.phone),
                        const SizedBox(height: 10),
                        _buildInfoRow(Icons.calendar_today_outlined, 'Order Date', formattedDate),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Logs list header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(
                    'Logs Dimensions (${order.logs.length})',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),

                // Table of logs
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 20,
                        horizontalMargin: 8,
                        columns: const [
                          DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Length\n(ft)', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Girth\n(in/ft)', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Volume\n(cft)', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Price', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: List<DataRow>.generate(order.logs.length, (index) {
                          final log = order.logs[index];
                          return DataRow(
                            cells: [
                              DataCell(Text('${index + 1}')),
                              DataCell(Text(log.length.toStringAsFixed(1))),
                              DataCell(Text(log.girth.toStringAsFixed(1))),
                              DataCell(Text(VolumeCalculator.formatVolume(log.volume))),
                              DataCell(Text(VolumeCalculator.formatCurrency(log.price))),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Financial Breakdown
                Card(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.15),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Payment Details',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const Divider(height: 20),
                        _buildTotalRow('Total Volume', '${VolumeCalculator.formatVolume(order.totalVolume)} cft', false, theme),
                        const SizedBox(height: 8),
                        _buildTotalRow('Subtotal', VolumeCalculator.formatCurrency(order.subtotal), false, theme),
                        const SizedBox(height: 8),
                        _buildTotalRow('Cutting Charge', '+ ${VolumeCalculator.formatCurrency(order.cuttingCharge)}', false, theme),
                        const SizedBox(height: 8),
                        _buildTotalRow('Discount', '- ${VolumeCalculator.formatCurrency(order.discount)}', false, theme),
                        const Divider(height: 24),
                        _buildTotalRow('Final Price', VolumeCalculator.formatCurrency(order.finalPrice), true, theme),
                      ],
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTotalRow(String label, String value, bool isTotal, ThemeData theme) {
    final style = isTotal
        ? theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          )
        : const TextStyle(fontSize: 15, fontWeight: FontWeight.w500);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    );
  }
}
