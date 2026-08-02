import 'package:flutter/material.dart';
import 'package:wooden_mill_app/core/constants/app_constants.dart';
import 'package:wooden_mill_app/repositories/wood_type_repository.dart';

class WoodTypeController extends ChangeNotifier {
  static final WoodTypeController instance = WoodTypeController._internal();
  factory WoodTypeController() => instance;
  WoodTypeController._internal();

  final WoodTypeRepository _repository = WoodTypeRepository();

  List<WoodTypeConfig> _woodTypes = AppConstants.defaultWoodTypes;

  List<WoodTypeConfig> get woodTypes => _woodTypes;

  /// Load wood types from persistent storage
  Future<void> loadWoodTypes() async {
    _woodTypes = await _repository.getWoodTypes();
    notifyListeners();
  }

  /// Add a new custom wood species
  Future<void> addWoodType({
    required String name,
    required String malayalamName,
    required double ratePerCft,
  }) async {
    final id = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    final newItem = WoodTypeConfig(
      id: id,
      name: name.trim(),
      malayalamName: malayalamName.trim(),
      ratePerCft: ratePerCft,
      isDefault: false,
    );

    final updated = List<WoodTypeConfig>.from(_woodTypes)..add(newItem);
    await _repository.saveWoodTypes(updated);
    _woodTypes = updated;
    notifyListeners();
  }

  /// Update existing wood type (rate or display names)
  Future<void> updateWoodType(WoodTypeConfig item) async {
    final index = _woodTypes.indexWhere((w) => w.id == item.id);
    if (index != -1) {
      final updated = List<WoodTypeConfig>.from(_woodTypes);
      updated[index] = item;
      await _repository.saveWoodTypes(updated);
      _woodTypes = updated;
      notifyListeners();
    }
  }

  /// Delete a wood species (only non-default custom types)
  Future<void> deleteWoodType(String id) async {
    final updated = _woodTypes.where((w) => w.id != id).toList();
    await _repository.saveWoodTypes(updated);
    _woodTypes = updated;
    notifyListeners();
  }

  /// Reset wood types & pricing to factory defaults
  Future<void> resetToDefaults() async {
    _woodTypes = await _repository.resetToDefaults();
    notifyListeners();
  }
}
