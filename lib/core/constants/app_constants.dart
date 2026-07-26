class AppConstants {
  AppConstants._();

  static const String appVersionName = '1.0.1';
  static const String appBuildNumber = '2';
  static const String appVersionDisplay = 'v1.0.1 (Build 2)';

  // Wood Types config
  static const String teakName = 'Teak';
  static const String teakMalayalam = 'തേക്ക്';
  static const double teakRate = 4800.0;

  static const String coconutName = 'Coconut';
  static const String coconutMalayalam = 'തെങ്ങ്';
  static const double coconutRate = 4500.0;

  static const String othersName = 'Others';
  static const String othersMalayalam = 'മറ്റുള്ളവ';
  static const double othersRate = 4000.0;

  // Wood Type configuration list
  static const List<WoodTypeConfig> woodTypes = [
    WoodTypeConfig(
      name: teakName,
      malayalamName: teakMalayalam,
      ratePerCft: teakRate,
    ),
    WoodTypeConfig(
      name: coconutName,
      malayalamName: coconutMalayalam,
      ratePerCft: coconutRate,
    ),
    WoodTypeConfig(
      name: othersName,
      malayalamName: othersMalayalam,
      ratePerCft: othersRate,
    ),
  ];

  // Validation Limits
  static const int minLogs = 1;
  static const int maxLogs = 20;
}

class WoodTypeConfig {
  final String name;
  final String malayalamName;
  final double ratePerCft;

  const WoodTypeConfig({
    required this.name,
    required this.malayalamName,
    required this.ratePerCft,
  });

  String get displayName => '$name ($malayalamName)';
}
