import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:wooden_mill_app/core/constants/app_constants.dart';
import 'package:wooden_mill_app/core/utils/volume_calculator.dart';
import 'package:wooden_mill_app/models/order.dart';

class ExportHelper {
  ExportHelper._();

  /// Exports Order History as a CSV file and opens system share dialog
  static Future<void> exportOrdersToCsv(BuildContext context, List<OrderModel> orders) async {
    if (orders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No orders available to export.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final buffer = StringBuffer();
    // CSV Header
    buffer.writeln(
      'Order ID,Customer Name,Phone,Wood Type,Number of Logs,Total Volume (cft),Subtotal (INR),Cutting Charge (INR),Discount (INR),Final Price (INR),Date & Time',
    );

    // CSV Rows
    for (final order in orders) {
      final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(order.dateTime);
      final customerNameEscaped = '"${order.customerName.replaceAll('"', '""')}"';
      
      buffer.writeln(
        '${order.id ?? ""},$customerNameEscaped,"${order.phone}",${order.woodType},${order.numberOfLogs},${order.totalVolume.toStringAsFixed(2)},${order.subtotal.toStringAsFixed(2)},${order.cuttingCharge.toStringAsFixed(2)},${order.discount.toStringAsFixed(2)},${order.finalPrice.toStringAsFixed(2)},"$formattedDate"',
      );
    }

    final csvBytes = utf8.encode(buffer.toString());
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());

    await Printing.sharePdf(
      bytes: csvBytes,
      filename: 'Timbr_Order_History_$timestamp.csv',
    );
  }

  /// Exports Order History as a formatted PDF summary report and opens print/share dialog
  static Future<void> exportOrdersToPdfReport(BuildContext context, List<OrderModel> orders) async {
    if (orders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No orders available to export.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final pdf = pw.Document();

    double grandTotalVolume = 0;
    double grandTotalAmount = 0;
    for (final o in orders) {
      grandTotalVolume += o.totalVolume;
      grandTotalAmount += o.finalPrice;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('TIMBR WOOD MILL', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Order History Report', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Export Date: ${DateFormat("dd MMM yyyy").format(DateTime.now())}', style: const pw.TextStyle(fontSize: 10)),
                    pw.Text('Total Orders: ${orders.length}', style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 16),
            pw.Divider(thickness: 1, color: PdfColors.grey400),
            pw.SizedBox(height: 12),

            // Summary Stats Cards
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400),
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text('TOTAL ORDERS', style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                      pw.SizedBox(height: 4),
                      pw.Text('${orders.length}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400),
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text('TOTAL VOLUME', style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                      pw.SizedBox(height: 4),
                      pw.Text('${VolumeCalculator.formatVolume(grandTotalVolume)} cft', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400),
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text('TOTAL REVENUE', style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                      pw.SizedBox(height: 4),
                      pw.Text(VolumeCalculator.formatCurrency(grandTotalAmount), style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Table of Orders
            pw.TableHelper.fromTextArray(
              headers: ['#', 'Customer', 'Phone', 'Wood', 'Logs', 'Volume (cft)', 'Amount'],
              data: List<List<String>>.generate(orders.length, (index) {
                final o = orders[index];
                return [
                  '${index + 1}',
                  o.customerName,
                  o.phone,
                  o.woodType,
                  '${o.numberOfLogs}',
                  VolumeCalculator.formatVolume(o.totalVolume),
                  VolumeCalculator.formatCurrency(o.finalPrice),
                ];
              }),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellAlignment: pw.Alignment.centerLeft,
              columnWidths: {
                0: const pw.FixedColumnWidth(25),
                1: const pw.FlexColumnWidth(3),
                2: const pw.FlexColumnWidth(2.5),
                3: const pw.FlexColumnWidth(2),
                4: const pw.FixedColumnWidth(35),
                5: const pw.FlexColumnWidth(2),
                6: const pw.FlexColumnWidth(2.5),
              },
            ),
            pw.SizedBox(height: 20),

            // Footer
            pw.Divider(thickness: 0.5, color: PdfColors.grey400),
            pw.SizedBox(height: 6),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Generated by Timbr ${AppConstants.appVersionDisplay}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                pw.Text('Page 1 of 1', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
              ],
            ),
          ];
        },
      ),
    );

    final bytes = await pdf.save();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());

    await Printing.layoutPdf(
      onLayout: (format) async => bytes,
      name: 'Timbr_Order_History_$timestamp.pdf',
    );
  }

  /// Shows an export selection modal to choose CSV or PDF format
  static void showExportOptionsModal(BuildContext context, List<OrderModel> orders) {
    if (orders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No orders available to export.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Export Order History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose export format for ${orders.length} order records',
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.table_chart_outlined, color: Colors.green),
                  ),
                  title: const Text('Export as CSV Spreadsheet', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Compatible with Microsoft Excel & Google Sheets', style: TextStyle(fontSize: 11)),
                  onTap: () {
                    Navigator.of(context).pop();
                    exportOrdersToCsv(context, orders);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.picture_as_pdf_outlined, color: Colors.red),
                  ),
                  title: const Text('Export as PDF Summary Report', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Formatted report for printing or PDF document sharing', style: TextStyle(fontSize: 11)),
                  onTap: () {
                    Navigator.of(context).pop();
                    exportOrdersToPdfReport(context, orders);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
