import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wooden_mill_app/core/constants/app_constants.dart';
import 'package:wooden_mill_app/core/utils/volume_calculator.dart';
import 'package:wooden_mill_app/core/theme/theme_controller.dart';
import 'package:wooden_mill_app/screens/home/home_controller.dart';
import 'package:wooden_mill_app/repositories/order_repository.dart';
import 'package:wooden_mill_app/models/order.dart';

// Mock repository to test HomeController without actual SQLite DB
class MockOrderRepository extends OrderRepository {
  bool saveCalled = false;
  OrderModel? savedOrder;

  @override
  Future<int> saveOrder(OrderModel order) async {
    saveCalled = true;
    savedOrder = order;
    return 42; // Mocked ID
  }
}

void main() {
  group('VolumeCalculator Tests', () {
    test('calculateVolume performs business formula correctly', () {
      // Volume = (length * girth * girth) / 16
      // E.g., length = 12.0, girth = 8.0
      // Volume = (12 * 8 * 8) / 16 = 768 / 16 = 48.0
      final volume = VolumeCalculator.calculateVolume(length: 12.0, girth: 8.0);
      expect(volume, equals(48.0));
    });

    test('calculateVolume returns zero for negative or zero parameters', () {
      expect(VolumeCalculator.calculateVolume(length: -10.0, girth: 5.0), equals(0.0));
      expect(VolumeCalculator.calculateVolume(length: 10.0, girth: 0.0), equals(0.0));
    });

    test('calculateLogPrice computes price correctly', () {
      final price = VolumeCalculator.calculateLogPrice(volume: 5.0, rate: 4800.0);
      expect(price, equals(24000.0));
    });
  });

  group('HomeController State Tests', () {
    late HomeController controller;
    late MockOrderRepository mockRepository;

    setUp(() {
      mockRepository = MockOrderRepository();
      controller = HomeController(repository: mockRepository);
    });

    tearDown(() {
      controller.dispose();
    });

    test('initial state has one log row', () {
      expect(controller.logs.length, equals(1));
      expect(controller.totalVolume, equals(0.0));
      expect(controller.subtotal, equals(0.0));
      expect(controller.finalPrice, equals(0.0));
    });

    test('adding and removing log rows respects bounds', () {
      // Add logs up to max
      for (int i = 0; i < 25; i++) {
        controller.addLog();
      }
      expect(controller.logs.length, equals(AppConstants.maxLogs));

      // Remove logs down to min
      for (int i = 0; i < 25; i++) {
        controller.removeLogAt(0);
      }
      expect(controller.logs.length, equals(AppConstants.minLogs));
    });

    test('recalculates live values when log inputs change', () {
      final log = controller.logs.first;
      
      // Update length and girth
      log.lengthController.text = '10.0';
      log.girthController.text = '4.0';
      // Trigger listener manual callback simulation (or the listener attached handles it)
      // Volume = (10 * 4 * 4) / 16 = 10.0
      // Price for Teak = 10.0 * 4800 = 48000.0
      
      expect(controller.totalVolume, equals(10.0));
      expect(controller.subtotal, equals(48000.0));
      expect(controller.finalPrice, equals(48000.0));

      // Change wood type to Coconut (rate 4500)
      controller.selectedWoodType = AppConstants.woodTypes.firstWhere((w) => w.name == 'Coconut');
      expect(controller.subtotal, equals(45000.0));
      expect(controller.finalPrice, equals(45000.0));
    });

    test('validates form inputs correctly', () {
      // Invalid initially (empty customer name, phone, log dimensions)
      expect(controller.validateForm(), isFalse);
      expect(controller.errorMessage, contains('Customer Name is required'));

      controller.customerNameController.text = 'John Doe';
      expect(controller.validateForm(), isFalse);
      expect(controller.errorMessage, contains('Phone Number is required'));

      controller.phoneController.text = '12345'; // Invalid length
      expect(controller.validateForm(), isFalse);
      expect(controller.errorMessage, contains('Phone Number must be exactly 10 digits'));

      controller.phoneController.text = '9876543210';
      expect(controller.validateForm(), isFalse);
      expect(controller.errorMessage, contains('empty dimensions'));

      // Fill in log dimensions
      controller.logs[0].lengthController.text = '10';
      controller.logs[0].girthController.text = '4';
      
      expect(controller.validateForm(), isTrue);
      expect(controller.errorMessage, isNull);
    });

    test('submitting order calls repository save', () async {
      controller.customerNameController.text = 'Alice';
      controller.phoneController.text = '9876543210';
      controller.logs[0].lengthController.text = '10';
      controller.logs[0].girthController.text = '4';

      expect(controller.validateForm(), isTrue);

      final order = await controller.submitOrder();
      expect(order, isNotNull);
      expect(mockRepository.saveCalled, isTrue);
      expect(mockRepository.savedOrder?.customerName, equals('Alice'));
      expect(mockRepository.savedOrder?.finalPrice, equals(48000.0));
    });
  });

  group('ThemeController Tests', () {
    test('initial themeMode defaults to system', () {
      final themeController = ThemeController();
      expect(themeController.themeMode, equals(ThemeMode.system));
    });

    test('setThemeMode updates state correctly', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final themeController = ThemeController();
      await themeController.setThemeMode(ThemeMode.dark);
      expect(themeController.themeMode, equals(ThemeMode.dark));
      expect(themeController.isDarkMode, isTrue);

      await themeController.setThemeMode(ThemeMode.light);
      expect(themeController.themeMode, equals(ThemeMode.light));
      expect(themeController.isDarkMode, isFalse);
    });
  });
}
