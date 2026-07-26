import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wooden_mill_app/core/theme/shadcn_tokens.dart';
import 'package:wooden_mill_app/core/utils/pdf_invoice_helper.dart';
import 'package:wooden_mill_app/core/utils/volume_calculator.dart';
import 'package:wooden_mill_app/main.dart';
import 'package:wooden_mill_app/models/order.dart';
import 'package:wooden_mill_app/repositories/order_repository.dart';
import 'package:wooden_mill_app/widgets/shad_badge.dart';
import 'package:wooden_mill_app/widgets/shad_card.dart';
import 'package:wooden_mill_app/widgets/shad_stat_tile.dart';

class DetailsScreen extends StatefulWidget {
  final int orderId;
  final bool isEmbedded;

  const DetailsScreen({
    super.key,
    required this.orderId,
    this.isEmbedded = false,
  });

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

  @override
  void didUpdateWidget(covariant DetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.orderId != widget.orderId) {
      _loadOrder();
    }
  }

  void _loadOrder() {
    setState(() {
      _orderFuture = _repository.getOrderById(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<OrderModel?>(
      future: _orderFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: theme.colorScheme.error, size: 48),
                const SizedBox(height: 16),
                const Text('Error loading order details'),
                const SizedBox(height: 12),
                OutlinedButton(onPressed: _loadOrder, child: const Text('Retry')),
              ],
            ),
          );
        }

        final order = snapshot.data;
        if (order == null) {
          return const Center(child: Text('Order not found'));
        }

        final formattedDate = DateFormat('dd MMMM yyyy, hh:mm a').format(order.dateTime);

        final bodyContent = ListView(
          padding: const EdgeInsets.all(ShadTokens.spaceLg),
          children: [
            ShadCard(
              title: 'Customer Details',
              description: 'Customer contact and wood classification',
              action: ShadBadge(
                label: order.woodType,
                variant: ShadBadgeVariant.defaultVariant,
              ),
              child: Column(
                children: [
                  _buildDetailRow(Icons.person_outline, 'Customer Name', order.customerName, theme),
                  const SizedBox(height: 10),
                  _buildDetailRow(Icons.phone_outlined, 'Phone Number', order.phone, theme),
                  const SizedBox(height: 10),
                  _buildDetailRow(Icons.calendar_today_outlined, 'Date & Time', formattedDate, theme),
                ],
              ),
            ),
            const SizedBox(height: ShadTokens.spaceLg),

            // Logs Table Card
            ShadCard(
              title: 'Log Dimensions Breakdown',
              description: '${order.logs.length} ${order.logs.length == 1 ? "log entry" : "log entries"} recorded',
              action: OutlinedButton.icon(
                onPressed: () => PdfInvoiceHelper.printOrderInvoice(context, order),
                icon: const Icon(Icons.print_outlined, size: 16),
                label: const Text('Print Receipt'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero,
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 28,
                  horizontalMargin: 8,
                  headingRowHeight: 40,
                  dataRowMinHeight: 44,
                  columns: const [
                    DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Length (ft)', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Girth (in)', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Volume (cft)', style: TextStyle(fontWeight: FontWeight.bold))),
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
            const SizedBox(height: ShadTokens.spaceLg),

            // Financial Summary Card
            ShadCard(
              title: 'Financial Breakdown',
              description: 'Subtotals, charges, and final payable total',
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ShadStatTile(
                          label: 'Total Volume',
                          value: '${VolumeCalculator.formatVolume(order.totalVolume)} cft',
                          icon: Icons.layers_outlined,
                        ),
                      ),
                      const SizedBox(width: ShadTokens.spaceMd),
                      Expanded(
                        child: ShadStatTile(
                          label: 'Subtotal',
                          value: VolumeCalculator.formatCurrency(order.subtotal),
                          icon: Icons.payments_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: ShadTokens.spaceMd),
                  Row(
                    children: [
                      Expanded(
                        child: ShadStatTile(
                          label: 'Cutting Charge',
                          value: '+ ${VolumeCalculator.formatCurrency(order.cuttingCharge)}',
                        ),
                      ),
                      const SizedBox(width: ShadTokens.spaceMd),
                      Expanded(
                        child: ShadStatTile(
                          label: 'Discount',
                          value: '- ${VolumeCalculator.formatCurrency(order.discount)}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: ShadTokens.spaceMd),
                  ShadStatTile(
                    label: 'Final Payable Amount',
                    value: VolumeCalculator.formatCurrency(order.finalPrice),
                    icon: Icons.account_balance_wallet_outlined,
                    isHighlight: true,
                  ),
                ],
              ),
            ),
          ],
        );

        if (widget.isEmbedded) {
          return bodyContent;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Order Details'),
            actions: [
              IconButton(
                icon: const Icon(Icons.print_outlined),
                tooltip: 'Print Receipt (PDF)',
                onPressed: () => PdfInvoiceHelper.printOrderInvoice(context, order),
              ),
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
              const SizedBox(width: 8),
            ],
          ),
          body: bodyContent,
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}
