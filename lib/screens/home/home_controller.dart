import 'package:flutter/material.dart';
import 'package:wooden_mill_app/core/constants/app_constants.dart';
import 'package:wooden_mill_app/core/utils/volume_calculator.dart';
import 'package:wooden_mill_app/models/log_dimension.dart';
import 'package:wooden_mill_app/models/order.dart';
import 'package:wooden_mill_app/repositories/draft_repository.dart';
import 'package:wooden_mill_app/repositories/order_repository.dart';

import 'package:wooden_mill_app/core/controllers/wood_type_controller.dart';

class LogInput {
  final TextEditingController lengthController;
  final TextEditingController girthController;
  double volume = 0.0;
  double price = 0.0;
  String? lengthError;
  String? girthError;

  LogInput()
      : lengthController = TextEditingController(),
        girthController = TextEditingController();

  void dispose() {
    lengthController.dispose();
    girthController.dispose();
  }
}

class HomeController extends ChangeNotifier {
  final OrderRepository _repository;
  final DraftRepository _draftRepository;

  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cuttingChargeController = TextEditingController(text: '0');
  final TextEditingController discountController = TextEditingController(text: '0');

  WoodTypeConfig _selectedWoodType = WoodTypeController.instance.woodTypes.first;
  final List<LogInput> _logs = [];

  // Totals
  double _totalVolume = 0.0;
  double _subtotal = 0.0;
  double _cuttingCharge = 0.0;
  double _discount = 0.0;
  double _finalPrice = 0.0;

  bool _isSaving = false;
  String? _errorMessage;

  HomeController({
    OrderRepository? repository,
    DraftRepository? draftRepository,
  })  : _repository = repository ?? OrderRepository(),
        _draftRepository = draftRepository ?? DraftRepository() {
    // Add initial log
    addLog();
    
    // Add listeners to customer details & charges to update UI/calculations & auto-save draft
    customerNameController.addListener(_autoSaveDraft);
    phoneController.addListener(_autoSaveDraft);
    cuttingChargeController.addListener(_onChargeOrDiscountChanged);
    discountController.addListener(_onChargeOrDiscountChanged);

    // Listen to global WoodTypeController for live rate changes
    WoodTypeController.instance.addListener(_onWoodTypesUpdated);

    // Restore unfinished draft from disk if present
    _restoreDraft();
  }

  void _onWoodTypesUpdated() {
    final available = WoodTypeController.instance.woodTypes;
    if (available.isEmpty) return;

    final match = available.firstWhere(
      (w) => w.id == _selectedWoodType.id || w.name == _selectedWoodType.name,
      orElse: () => available.first,
    );
    _selectedWoodType = match;
    calculateTotals();
  }

  // Getters
  WoodTypeConfig get selectedWoodType => _selectedWoodType;
  List<LogInput> get logs => _logs;
  double get totalVolume => _totalVolume;
  double get subtotal => _subtotal;
  double get cuttingCharge => _cuttingCharge;
  double get discount => _discount;
  double get finalPrice => _finalPrice;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  set selectedWoodType(WoodTypeConfig value) {
    if (_selectedWoodType != value) {
      _selectedWoodType = value;
      calculateTotals();
      _autoSaveDraft();
    }
  }

  void _onChargeOrDiscountChanged() {
    _cuttingCharge = double.tryParse(cuttingChargeController.text) ?? 0.0;
    _discount = double.tryParse(discountController.text) ?? 0.0;
    _finalPrice = _subtotal + _cuttingCharge - _discount;
    _autoSaveDraft();
    notifyListeners();
  }

  /// Adds a new log row if the current count is under max limit
  void addLog({String length = '', String girth = ''}) {
    if (_logs.length >= AppConstants.maxLogs) return;

    final newLog = LogInput();
    if (length.isNotEmpty) newLog.lengthController.text = length;
    if (girth.isNotEmpty) newLog.girthController.text = girth;

    newLog.lengthController.addListener(() {
      _calculateLog(newLog);
      _autoSaveDraft();
    });
    newLog.girthController.addListener(() {
      _calculateLog(newLog);
      _autoSaveDraft();
    });

    _logs.add(newLog);
    calculateTotals();
    _autoSaveDraft();
  }

  /// Removes a log row if the current count is above min limit
  void removeLogAt(int index) {
    if (_logs.length <= AppConstants.minLogs) return;

    _logs[index].dispose();
    _logs.removeAt(index);
    
    calculateTotals();
    _autoSaveDraft();
  }

  /// Calculates volume and price for a single log row
  void _calculateLog(LogInput log) {
    final length = double.tryParse(log.lengthController.text) ?? 0.0;
    final girth = double.tryParse(log.girthController.text) ?? 0.0;

    log.lengthError = null;
    log.girthError = null;

    if (log.lengthController.text.isNotEmpty && length <= 0) {
      log.lengthError = 'Must be > 0';
    }
    if (log.girthController.text.isNotEmpty && girth <= 0) {
      log.girthError = 'Must be > 0';
    }

    if (length > 0 && girth > 0) {
      log.volume = VolumeCalculator.calculateVolume(length: length, girth: girth);
      log.price = VolumeCalculator.calculateLogPrice(volume: log.volume, rate: _selectedWoodType.ratePerCft);
    } else {
      log.volume = 0.0;
      log.price = 0.0;
    }

    calculateTotals();
  }

  /// Re-calculates total volume, subtotal, and final price across all log rows
  void calculateTotals() {
    _totalVolume = 0.0;
    _subtotal = 0.0;

    for (final log in _logs) {
      final length = double.tryParse(log.lengthController.text) ?? 0.0;
      final girth = double.tryParse(log.girthController.text) ?? 0.0;
      
      if (length > 0 && girth > 0) {
        log.volume = VolumeCalculator.calculateVolume(length: length, girth: girth);
        log.price = VolumeCalculator.calculateLogPrice(volume: log.volume, rate: _selectedWoodType.ratePerCft);
      } else {
        log.volume = 0.0;
        log.price = 0.0;
      }

      _totalVolume += log.volume;
      _subtotal += log.price;
    }

    _cuttingCharge = double.tryParse(cuttingChargeController.text) ?? 0.0;
    _discount = double.tryParse(discountController.text) ?? 0.0;
    _finalPrice = _subtotal + _cuttingCharge - _discount;

    notifyListeners();
  }

  /// Restores an unfinished draft from persistent local storage
  Future<void> _restoreDraft() async {
    final draft = await _draftRepository.loadDraft();
    if (draft == null) return;

    if (draft.customerName.isNotEmpty) {
      customerNameController.text = draft.customerName;
    }
    if (draft.phone.isNotEmpty) {
      phoneController.text = draft.phone;
    }
    if (draft.cuttingCharge.isNotEmpty) {
      cuttingChargeController.text = draft.cuttingCharge;
    }
    if (draft.discount.isNotEmpty) {
      discountController.text = draft.discount;
    }

    final available = WoodTypeController.instance.woodTypes;
    final wood = available.firstWhere(
      (w) => w.name == draft.woodType || w.displayName == draft.woodType || w.id == draft.woodType,
      orElse: () => available.isNotEmpty ? available.first : AppConstants.defaultWoodTypes.first,
    );
    _selectedWoodType = wood;

    if (draft.logs.isNotEmpty) {
      for (final log in _logs) {
        log.dispose();
      }
      _logs.clear();

      for (final logData in draft.logs) {
        addLog(
          length: logData['length'] ?? '',
          girth: logData['girth'] ?? '',
        );
      }
    }

    calculateTotals();
  }

  /// Auto-saves the active draft to disk
  void _autoSaveDraft() {
    final logMaps = _logs
        .map((l) => {
              'length': l.lengthController.text,
              'girth': l.girthController.text,
            })
        .toList();

    final draft = DraftOrderData(
      customerName: customerNameController.text,
      phone: phoneController.text,
      woodType: _selectedWoodType.name,
      cuttingCharge: cuttingChargeController.text,
      discount: discountController.text,
      logs: logMaps,
    );

    _draftRepository.saveDraft(draft);
  }

  /// Validates the form fields. Returns true if valid, false otherwise.
  bool validateForm() {
    _errorMessage = null;

    if (customerNameController.text.trim().isEmpty) {
      _errorMessage = 'Customer Name is required';
      notifyListeners();
      return false;
    }

    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      _errorMessage = 'Phone Number is required';
      notifyListeners();
      return false;
    }

    final phoneRegex = RegExp(r'^\d{10}$');
    if (!phoneRegex.hasMatch(phone)) {
      _errorMessage = 'Phone Number must be exactly 10 digits';
      notifyListeners();
      return false;
    }

    if (_logs.isEmpty) {
      _errorMessage = 'At least 1 log is required';
      notifyListeners();
      return false;
    }

    for (int i = 0; i < _logs.length; i++) {
      final log = _logs[i];
      final lengthText = log.lengthController.text.trim();
      final girthText = log.girthController.text.trim();

      if (lengthText.isEmpty || girthText.isEmpty) {
        _errorMessage = 'Log #${i + 1} has empty dimensions';
        notifyListeners();
        return false;
      }

      final length = double.tryParse(lengthText);
      final girth = double.tryParse(girthText);

      if (length == null || length <= 0) {
        _errorMessage = 'Log #${i + 1} length must be greater than zero';
        notifyListeners();
        return false;
      }

      if (girth == null || girth <= 0) {
        _errorMessage = 'Log #${i + 1} girth must be greater than zero';
        notifyListeners();
        return false;
      }
    }

    if (_cuttingCharge < 0) {
      _errorMessage = 'Cutting charge cannot be negative';
      notifyListeners();
      return false;
    }

    if (_discount < 0) {
      _errorMessage = 'Discount cannot be negative';
      notifyListeners();
      return false;
    }

    if (_finalPrice < 0) {
      _errorMessage = 'Final price cannot be negative';
      notifyListeners();
      return false;
    }

    return true;
  }

  /// Saves the current order to SQLite.
  Future<OrderModel?> submitOrder() async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final List<LogDimension> dbLogs = _logs.map((log) {
        final length = double.parse(log.lengthController.text);
        final girth = double.parse(log.girthController.text);
        return LogDimension(
          length: length,
          girth: girth,
          volume: log.volume,
          price: log.price,
        );
      }).toList();

      final order = OrderModel(
        customerName: customerNameController.text.trim(),
        phone: phoneController.text.trim(),
        woodType: _selectedWoodType.name,
        numberOfLogs: _logs.length,
        totalVolume: _totalVolume,
        subtotal: _subtotal,
        cuttingCharge: _cuttingCharge,
        discount: _discount,
        finalPrice: _finalPrice,
        dateTime: DateTime.now(),
        logs: dbLogs,
      );

      final orderId = await _repository.saveOrder(order);
      await _draftRepository.clearDraft();

      _isSaving = false;
      notifyListeners();
      return order.copyWith(id: orderId);
    } catch (e) {
      _isSaving = false;
      _errorMessage = 'Database Failure: Failed to save the order. Error: $e';
      notifyListeners();
      return null;
    }
  }

  /// Resets the form to its initial state and clears persistent draft
  void clearForm() {
    customerNameController.clear();
    phoneController.clear();
    cuttingChargeController.text = '0';
    discountController.text = '0';
    final available = WoodTypeController.instance.woodTypes;
    if (available.isNotEmpty) {
      _selectedWoodType = available.first;
    }
    
    for (final log in _logs) {
      log.dispose();
    }
    _logs.clear();
    addLog();

    _errorMessage = null;
    _draftRepository.clearDraft();
    calculateTotals();
  }

  @override
  void dispose() {
    WoodTypeController.instance.removeListener(_onWoodTypesUpdated);
    customerNameController.dispose();
    phoneController.dispose();
    cuttingChargeController.dispose();
    discountController.dispose();
    for (final log in _logs) {
      log.dispose();
    }
    super.dispose();
  }
}
