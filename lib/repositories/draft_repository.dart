import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DraftOrderData {
  final String customerName;
  final String phone;
  final String woodType;
  final String cuttingCharge;
  final String discount;
  final List<Map<String, String>> logs;

  DraftOrderData({
    required this.customerName,
    required this.phone,
    required this.woodType,
    required this.cuttingCharge,
    required this.discount,
    required this.logs,
  });

  Map<String, dynamic> toJson() => {
        'customerName': customerName,
        'phone': phone,
        'woodType': woodType,
        'cuttingCharge': cuttingCharge,
        'discount': discount,
        'logs': logs,
      };

  factory DraftOrderData.fromJson(Map<String, dynamic> json) {
    return DraftOrderData(
      customerName: json['customerName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      woodType: json['woodType'] as String? ?? '',
      cuttingCharge: json['cuttingCharge'] as String? ?? '',
      discount: json['discount'] as String? ?? '',
      logs: (json['logs'] as List<dynamic>?)
              ?.map((e) => Map<String, String>.from(e as Map))
              .toList() ??
          [],
    );
  }
}

class DraftRepository {
  static const String _draftKey = 'unfinished_order_draft';

  Future<void> saveDraft(DraftOrderData draft) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_draftKey, jsonEncode(draft.toJson()));
  }

  Future<DraftOrderData?> loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_draftKey);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return DraftOrderData.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_draftKey);
  }
}
