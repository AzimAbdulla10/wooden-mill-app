import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wooden_mill_app/core/constants/app_constants.dart';

class WoodTypeRepository {
  static const String _storageKey = 'wood_types_config_v1';

  /// Fetch configured wood types from persistent storage
  Future<List<WoodTypeConfig>> getWoodTypes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString == null || jsonString.isEmpty) {
      // Save default configuration on first initialization
      await saveWoodTypes(AppConstants.defaultWoodTypes);
      return AppConstants.defaultWoodTypes;
    }

    try {
      final List<dynamic> list = jsonDecode(jsonString);
      return list.map((item) => WoodTypeConfig.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return AppConstants.defaultWoodTypes;
    }
  }

  /// Persist the list of wood types
  Future<void> saveWoodTypes(List<WoodTypeConfig> types) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(types.map((t) => t.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  /// Reset wood types back to system defaults
  Future<List<WoodTypeConfig>> resetToDefaults() async {
    await saveWoodTypes(AppConstants.defaultWoodTypes);
    return AppConstants.defaultWoodTypes;
  }
}
