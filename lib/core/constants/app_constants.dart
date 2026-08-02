class AppConstants {
  AppConstants._();

  static const String appVersionName = '1.0.6';
  static const String appBuildNumber = '7';
  static const String appVersionDisplay = 'v1.0.6 (Build 7)';

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

  // Wood Type configuration default list
  static const List<WoodTypeConfig> defaultWoodTypes = [
    WoodTypeConfig(
      id: 'teak',
      name: teakName,
      malayalamName: teakMalayalam,
      ratePerCft: teakRate,
      isDefault: true,
    ),
    WoodTypeConfig(
      id: 'coconut',
      name: coconutName,
      malayalamName: coconutMalayalam,
      ratePerCft: coconutRate,
      isDefault: true,
    ),
    WoodTypeConfig(
      id: 'others',
      name: othersName,
      malayalamName: othersMalayalam,
      ratePerCft: othersRate,
      isDefault: true,
    ),
  ];

  // Backward compatibility getter
  static List<WoodTypeConfig> get woodTypes => defaultWoodTypes;

  // Validation Limits
  static const int minLogs = 1;
  static const int maxLogs = 20;
}

class WoodTypeConfig {
  final String id;
  final String name;
  final String malayalamName;
  final double ratePerCft;
  final bool isDefault;

  const WoodTypeConfig({
    required this.id,
    required this.name,
    required this.malayalamName,
    required this.ratePerCft,
    this.isDefault = false,
  });

  String get displayName => malayalamName.isNotEmpty ? '$name ($malayalamName)' : name;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'malayalamName': malayalamName,
        'ratePerCft': ratePerCft,
        'isDefault': isDefault,
      };

  factory WoodTypeConfig.fromJson(Map<String, dynamic> json) => WoodTypeConfig(
        id: json['id'] as String? ?? json['name'] as String,
        name: json['name'] as String,
        malayalamName: json['malayalamName'] as String? ?? '',
        ratePerCft: (json['ratePerCft'] as num).toDouble(),
        isDefault: json['isDefault'] as bool? ?? false,
      );

  WoodTypeConfig copyWith({
    String? id,
    String? name,
    String? malayalamName,
    double? ratePerCft,
    bool? isDefault,
  }) {
    return WoodTypeConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      malayalamName: malayalamName ?? this.malayalamName,
      ratePerCft: ratePerCft ?? this.ratePerCft,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WoodTypeConfig && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
