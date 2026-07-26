import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:wooden_mill_app/core/utils/volume_calculator.dart';
import 'package:wooden_mill_app/models/order.dart';

class PdfInvoiceHelper {
  PdfInvoiceHelper._();

  /// Generates PDF document bytes for a given Order
  static Future<Uint8List> generateInvoicePdf(OrderModel order) async {
    final pdf = pw.Document();
    final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(order.dateTime);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header Banner
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'WOODEN MILL RECEIPT',
                        style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.brown900,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Commercial Timber Volume & Pricing Report',
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'ORDER #${order.id ?? 1}',
                        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        formattedDate,
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                ],
              ),
              pw.Divider(thickness: 1, color: PdfColors.grey400),
              pw.SizedBox(height: 12),

              // Customer & Order Info Table
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300, width: 1),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Customer Details', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                        pw.SizedBox(height: 4),
                        pw.Text('Name: ${order.customerName}', style: const pw.TextStyle(fontSize: 10)),
                        pw.Text('Phone: ${order.phone}', style: const pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Wood Specification', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                        pw.SizedBox(height: 4),
                        pw.Text('Species: ${order.woodType}', style: const pw.TextStyle(fontSize: 10)),
                        pw.Text('Total Logs: ${order.numberOfLogs}', style: const pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // Table of Logs
              pw.Text('Log Measurements', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.TableHelper.fromTextArray(
                headers: ['#', 'Length (ft)', 'Girth (in)', 'Volume (cft)', 'Price (INR)'],
                data: List.generate(order.logs.length, (index) {
                  final log = order.logs[index];
                  return [
                    '${index + 1}',
                    log.length.toStringAsFixed(1),
                    log.girth.toStringAsFixed(1),
                    VolumeCalculator.formatVolume(log.volume),
                    VolumeCalculator.formatCurrency(log.price),
                  ];
                }),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                cellStyle: const pw.TextStyle(fontSize: 9),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
                cellAlignment: pw.Alignment.centerLeft,
                cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              ),
              pw.SizedBox(height: 16),

              // Billing Summary Table
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 240,
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey400, width: 1),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                    ),
                    child: pw.Column(
                      children: [
                        _buildPdfSummaryRow('Total Volume:', '${VolumeCalculator.formatVolume(order.totalVolume)} cft'),
                        _buildPdfSummaryRow('Subtotal:', VolumeCalculator.formatCurrency(order.subtotal)),
                        _buildPdfSummaryRow('Cutting Charge:', '+ ${VolumeCalculator.formatCurrency(order.cuttingCharge)}'),
                        _buildPdfSummaryRow('Discount:', '- ${VolumeCalculator.formatCurrency(order.discount)}'),
                        pw.Divider(thickness: 1, color: PdfColors.grey400),
                        _buildPdfSummaryRow(
                          'FINAL PRICE:',
                          VolumeCalculator.formatCurrency(order.finalPrice),
                          isBold: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.Spacer(),

              // Footer
              pw.Divider(thickness: 1, color: PdfColors.grey300),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Wooden Mill Calculator - Commercial Report', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                  pw.Text('Thank you for your business!', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800)),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Triggers OS native print dialog or PDF generator
  static Future<void> printOrderInvoice(BuildContext context, OrderModel order) async {
    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => generateInvoicePdf(order),
        name: 'Order_${order.id ?? 1}_Receipt',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to print receipt: $e')),
        );
      }
    }
  }

  static pw.Widget _buildPdfSummaryRow(String label, String value, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(fontSize: isBold ? 11 : 9, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: isBold ? 11 : 9, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal),
          ),
        ],
      ),
    );
  }
}
