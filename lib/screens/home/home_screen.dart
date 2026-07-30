import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:wooden_mill_app/core/constants/app_constants.dart';
import 'package:wooden_mill_app/core/theme/shadcn_tokens.dart';
import 'package:wooden_mill_app/core/utils/pdf_invoice_helper.dart';
import 'package:wooden_mill_app/core/utils/responsive_layout.dart';
import 'package:wooden_mill_app/core/utils/volume_calculator.dart';
import 'package:wooden_mill_app/models/order.dart';
import 'package:wooden_mill_app/screens/home/home_controller.dart';
import 'package:wooden_mill_app/widgets/shad_badge.dart';
import 'package:wooden_mill_app/widgets/shad_card.dart';
import 'package:wooden_mill_app/widgets/shad_stat_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HomeController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _removeLogWithConfirmation(int index) async {
    final log = _controller.logs[index];
    final hasData = log.lengthController.text.isNotEmpty || log.girthController.text.isNotEmpty;

    if (hasData) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ShadTokens.radiusLg),
            side: BorderSide(color: Theme.of(context).colorScheme.outline),
          ),
          title: const Text('Remove Log Entry?'),
          content: Text('Are you sure you want to remove Log #${index + 1}? Entered dimensions will be lost.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              child: const Text('Remove'),
            ),
          ],
        ),
      );

      if (confirm != true) return;
    }

    _controller.removeLogAt(index);
  }

  void _submitForm() async {
    FocusScope.of(context).unfocus();

    if (!_controller.validateForm()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_controller.errorMessage ?? 'Please verify your inputs'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ShadTokens.radiusSm)),
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ConfirmationDialog(
        customerName: _controller.customerNameController.text,
        phone: _controller.phoneController.text,
        woodType: _controller.selectedWoodType,
        numberOfLogs: _controller.logs.length,
        totalVolume: _controller.totalVolume,
        subtotal: _controller.subtotal,
        cuttingCharge: _controller.cuttingCharge,
        discount: _controller.discount,
        finalPrice: _controller.finalPrice,
      ),
    );

    if (confirm == true) {
      final savedOrder = await _controller.submitOrder();
      if (!mounted) return;

      if (savedOrder != null) {
        _controller.clearForm();
        
        // Popup confirmed order receipt dialog with print & details actions
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => _PostSaveReceiptDialog(savedOrder: savedOrder),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_controller.errorMessage ?? 'Failed to save order'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ShadTokens.radiusSm)),
          ),
        );
      }
    }
  }

  void _handleClearOrderConfirmation() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Order Data?'),
        content: const Text('Are you sure you want to clear all entered customer details and log measurements?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Clear Order'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _controller.clearForm();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Order'),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Order Options',
            icon: const Icon(Icons.more_vert),
            onSelected: (val) {
              if (val == 'clear') {
                _handleClearOrderConfirmation();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep_outlined, size: 18, color: Theme.of(context).colorScheme.error),
                    const SizedBox(width: 8),
                    Text('Clear Order', style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          return SafeArea(
            child: ResponsiveLayout(
              phone: _buildPhoneLayout(theme),
              tablet: _buildBalancedTabletLayout(theme),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPhoneLayout(ThemeData theme) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(ShadTokens.spaceLg),
            children: [
              _buildCustomerCard(theme),
              const SizedBox(height: ShadTokens.spaceLg),
              _buildWoodTypeCard(theme),
              const SizedBox(height: ShadTokens.spaceLg),
              _buildLogsHeader(theme),
              const SizedBox(height: ShadTokens.spaceSm),
              ...List.generate(
                _controller.logs.length,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: ShadTokens.spaceMd),
                  child: _buildLogItem(index, theme),
                ),
              ),
              const SizedBox(height: ShadTokens.spaceSm),
              _buildSummaryCard(theme),
            ],
          ),
        ),
        _buildStickyPhoneSummaryBar(theme),
      ],
    );
  }

  Widget _buildBalancedTabletLayout(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: ListView(
            padding: const EdgeInsets.all(ShadTokens.spaceLg),
            children: [
              _buildCustomerCard(theme),
              const SizedBox(height: ShadTokens.spaceLg),
              _buildWoodTypeCard(theme),
              const SizedBox(height: ShadTokens.spaceLg),
              _buildLogsHeader(theme),
              const SizedBox(height: ShadTokens.spaceSm),
              ...List.generate(
                _controller.logs.length,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: ShadTokens.spaceMd),
                  child: _buildLogItem(index, theme),
                ),
              ),
            ],
          ),
        ),
        VerticalDivider(width: 1, thickness: 1, color: theme.colorScheme.outline),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(ShadTokens.spaceLg),
                  children: [
                    _buildSummaryCard(theme),
                  ],
                ),
              ),
              _buildSubmitBar(theme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerCard(ThemeData theme) {
    return ShadCard(
      title: 'Customer Details',
      child: Column(
        children: [
          TextField(
            controller: _controller.customerNameController,
            decoration: const InputDecoration(
              labelText: 'Customer Name *',
              hintText: 'e.g. John Doe',
              prefixIcon: Icon(Icons.person_outline, size: 18),
            ),
            textCapitalization: TextCapitalization.words,
            keyboardType: TextInputType.name,
          ),
          const SizedBox(height: ShadTokens.spaceMd),
          TextField(
            controller: _controller.phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone Number (10 digits) *',
              hintText: '10 digit mobile number',
              prefixIcon: Icon(Icons.phone_outlined, size: 18),
              counterText: '',
            ),
            keyboardType: TextInputType.phone,
            maxLength: 10,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ],
      ),
    );
  }

  Widget _buildWoodTypeCard(ThemeData theme) {
    return ShadCard(
      title: 'Wood Category',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: ShadTokens.spaceMd, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ShadTokens.radiusMd),
          border: Border.all(color: theme.colorScheme.outline, width: 1),
          color: theme.cardTheme.color,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<WoodTypeConfig>(
            value: _controller.selectedWoodType,
            isExpanded: true,
            icon: const Icon(Icons.unfold_more, size: 20),
            items: AppConstants.woodTypes.map((wood) {
              return DropdownMenuItem<WoodTypeConfig>(
                value: wood,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      wood.displayName,
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                    ),
                    ShadBadge(
                      label: '${VolumeCalculator.formatCurrency(wood.ratePerCft)} / cft',
                      variant: ShadBadgeVariant.outline,
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                _controller.selectedWoodType = val;
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLogsHeader(ThemeData theme) {
    final canAdd = _controller.logs.length < AppConstants.maxLogs;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Text(
              'Log Measurements',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.2),
            ),
            const SizedBox(width: 8),
            ShadBadge(
              label: '${_controller.logs.length} / ${AppConstants.maxLogs}',
              variant: ShadBadgeVariant.secondary,
            ),
          ],
        ),
        OutlinedButton.icon(
          onPressed: canAdd ? _controller.addLog : null,
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Add Log'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            minimumSize: Size.zero,
          ),
        ),
      ],
    );
  }

  Widget _buildLogItem(int index, ThemeData theme) {
    final log = _controller.logs[index];
    final showRemove = _controller.logs.length > AppConstants.minLogs;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(ShadTokens.radiusMd),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(ShadTokens.radiusSm),
                ),
                child: Text(
                  'Log #${index + 1}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (log.volume > 0) ...[
                Text(
                  '${VolumeCalculator.formatVolume(log.volume)} cft',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Text(
                  VolumeCalculator.formatCurrency(log.price),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 8),
              ] else
                const Spacer(),
              if (showRemove)
                InkWell(
                  onTap: () => _removeLogWithConfirmation(index),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(Icons.close, size: 16, color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: log.lengthController,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Length (ft)',
                    hintText: '10.5',
                    errorText: log.lengthError,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    isDense: true,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: log.girthController,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Girth (in)',
                    hintText: '8.0',
                    errorText: log.girthError,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    isDense: true,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(ThemeData theme) {
    return ShadCard(
      title: 'Summary & Billing',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: ShadStatTile(
                  label: 'Total Volume',
                  value: '${VolumeCalculator.formatVolume(_controller.totalVolume)} cft',
                  icon: Icons.layers_outlined,
                ),
              ),
              const SizedBox(width: ShadTokens.spaceMd),
              Expanded(
                child: ShadStatTile(
                  label: 'Subtotal',
                  value: VolumeCalculator.formatCurrency(_controller.subtotal),
                  icon: Icons.payments_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: ShadTokens.spaceMd),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller.cuttingChargeController,
                  decoration: const InputDecoration(
                    labelText: 'Cutting Charge (₹)',
                    prefixText: '₹ ',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              const SizedBox(width: ShadTokens.spaceMd),
              Expanded(
                child: TextField(
                  controller: _controller.discountController,
                  decoration: const InputDecoration(
                    labelText: 'Discount (₹)',
                    prefixText: '₹ ',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
            ],
          ),
          const SizedBox(height: ShadTokens.spaceMd),
          ShadStatTile(
            label: 'Final Payable Amount',
            value: VolumeCalculator.formatCurrency(_controller.finalPrice),
            icon: Icons.account_balance_wallet_outlined,
            isHighlight: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStickyPhoneSummaryBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35), width: 1)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${VolumeCalculator.formatVolume(_controller.totalVolume)} cft',
                style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
              ),
              Text(
                VolumeCalculator.formatCurrency(_controller.finalPrice),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 42,
              child: ElevatedButton.icon(
                onPressed: _controller.isSaving ? null : _submitForm,
                icon: _controller.isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.check, size: 18),
                label: Text(
                  _controller.isSaving ? 'SAVING...' : 'SAVE ORDER',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35), width: 1)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 44,
        child: ElevatedButton.icon(
          onPressed: _controller.isSaving ? null : _submitForm,
          icon: _controller.isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Icon(Icons.check, size: 18),
          label: Text(
            _controller.isSaving ? 'SAVING ORDER...' : 'SAVE ORDER',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
      ),
    );
  }
}

class _ConfirmationDialog extends StatelessWidget {
  final String customerName;
  final String phone;
  final WoodTypeConfig woodType;
  final int numberOfLogs;
  final double totalVolume;
  final double subtotal;
  final double cuttingCharge;
  final double discount;
  final double finalPrice;

  const _ConfirmationDialog({
    required this.customerName,
    required this.phone,
    required this.woodType,
    required this.numberOfLogs,
    required this.totalVolume,
    required this.subtotal,
    required this.cuttingCharge,
    required this.discount,
    required this.finalPrice,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        padding: const EdgeInsets.all(ShadTokens.spaceXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(ShadTokens.radiusSm),
                  ),
                  child: Icon(Icons.receipt_long_outlined, size: 20, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Summary',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.3),
                    ),
                    Text(
                      'Verify order details before saving',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 32),
            _buildDetailRow('Customer Name', customerName, theme),
            _buildDetailRow('Phone Number', phone, theme),
            _buildDetailRow('Wood Type', woodType.displayName, theme),
            _buildDetailRow('Number of Logs', '$numberOfLogs', theme),
            _buildDetailRow('Total Volume', '${VolumeCalculator.formatVolume(totalVolume)} cft', theme),
            const Divider(height: 24),
            _buildDetailRow('Subtotal', VolumeCalculator.formatCurrency(subtotal), theme),
            _buildDetailRow('Cutting Charge', '+ ${VolumeCalculator.formatCurrency(cuttingCharge)}', theme),
            _buildDetailRow('Discount', '- ${VolumeCalculator.formatCurrency(discount)}', theme),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Final Price', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(
                  VolumeCalculator.formatCurrency(finalPrice),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: theme.colorScheme.primary),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Confirm & Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _PostSaveReceiptDialog extends StatelessWidget {
  final OrderModel savedOrder;

  const _PostSaveReceiptDialog({required this.savedOrder});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        padding: const EdgeInsets.all(ShadTokens.spaceXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_outline, size: 24, color: Color(0xFF059669)),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ORDER #${savedOrder.id ?? 1} CONFIRMED',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: -0.2),
                    ),
                    Text(
                      'Successfully saved to local database',
                      style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 28),
            _buildInfoRow('Customer:', savedOrder.customerName, theme),
            _buildInfoRow('Phone:', savedOrder.phone, theme),
            _buildInfoRow('Wood Species:', savedOrder.woodType, theme),
            _buildInfoRow('Total Logs:', '${savedOrder.numberOfLogs}', theme),
            _buildInfoRow('Total Volume:', '${VolumeCalculator.formatVolume(savedOrder.totalVolume)} cft', theme),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Final Price Paid:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(
                  VolumeCalculator.formatCurrency(savedOrder.finalPrice),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: theme.colorScheme.primary),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      PdfInvoiceHelper.printOrderInvoice(context, savedOrder);
                    },
                    icon: const Icon(Icons.print_outlined, size: 16),
                    label: const Text('PRINT RECEIPT'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.push('/history/${savedOrder.id}');
                    },
                    icon: const Icon(Icons.visibility_outlined, size: 16),
                    label: const Text('VIEW DETAILS'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('DONE / NEW ORDER'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
