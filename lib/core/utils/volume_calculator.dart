import 'package:intl/intl.dart';

class VolumeCalculator {
  VolumeCalculator._();

  /// Calculates timber volume in cubic feet (CFT)
  /// Formula: Volume = (length * girth * girth) / 16
  static double calculateVolume({
    required double length,
    required double girth,
  }) {
    if (length <= 0 || girth <= 0) return 0.0;
    return (length * girth * girth) / 16.0;
  }

  /// Calculates the price of a single log based on its volume and selected rate
  static double calculateLogPrice({
    required double volume,
    required double rate,
  }) {
    return volume * rate;
  }

  /// Formats volume to a readable string (3 decimal places)
  static String formatVolume(double volume) {
    return volume.toStringAsFixed(3);
  }

  /// Formats currency (Rupee) to a readable string (2 decimal places with separators)
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }
}
