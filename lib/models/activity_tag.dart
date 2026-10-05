import 'package:flutter/material.dart';
// ignore_for_file: non_const_argument_for_const_parameter

/// Represents a research-backed or user-created daily activity quick tag.
class ActivityTag {
  const ActivityTag({
    required this.id,
    required this.label,
    required this.iconCodePoint,
    this.iconFontFamily = 'CupertinoIcons',
    this.iconFontPackage = 'cupertino_icons',
    this.colorValue = 0xFF0A84FF,
    this.isCustom = false,
  });

  final String id;
  final String label;
  final int iconCodePoint;
  final String iconFontFamily;
  final String? iconFontPackage;
  final int colorValue;
  final bool isCustom;

  IconData get icon => iconForCodePoint(iconCodePoint);

  /// Map of compile-time constant CupertinoIcons to prevent dynamic IconData tree-shaking failures
  static IconData iconForCodePoint(int codePoint) {
    return _iconLookup[codePoint] ?? Icons.label_rounded;
  }

  static final Map<int, IconData> _iconLookup = {
    Icons.label_rounded.codePoint: Icons.label_rounded,
    Icons.explore_rounded.codePoint: Icons.explore_rounded,
    Icons.local_fire_department_rounded.codePoint:
        Icons.local_fire_department_rounded,
    Icons.menu_book_rounded.codePoint: Icons.menu_book_rounded,
    Icons.laptop_mac_rounded.codePoint: Icons.laptop_mac_rounded,
    Icons.water_drop_rounded.codePoint: Icons.water_drop_rounded,
    Icons.auto_awesome_rounded.codePoint: Icons.auto_awesome_rounded,
    Icons.description_rounded.codePoint: Icons.description_rounded,
    Icons.favorite_rounded.codePoint: Icons.favorite_rounded,
    Icons.directions_car_rounded.codePoint: Icons.directions_car_rounded,
    Icons.local_fire_department_rounded.codePoint:
        Icons.local_fire_department_rounded,
    Icons.delete_rounded.codePoint: Icons.delete_rounded,
    Icons.sports_esports_rounded.codePoint: Icons.sports_esports_rounded,
    Icons.people_rounded.codePoint: Icons.people_rounded,
    Icons.park_rounded.codePoint: Icons.park_rounded,
    Icons.dark_mode_rounded.codePoint: Icons.dark_mode_rounded,
    0xf56b: Icons.label_rounded,
    0xf657: Icons.explore_rounded,
    0xf54f: Icons.local_fire_department_rounded,
    0xf524: Icons.menu_book_rounded,
    0xf598: Icons.laptop_mac_rounded,
    0xf772: Icons.water_drop_rounded,
    0xf6e5: Icons.auto_awesome_rounded,
    0xf70e: Icons.description_rounded,
    0xf6e9: Icons.favorite_rounded,
    0xf555: Icons.directions_car_rounded,
    0xf626: Icons.local_fire_department_rounded,
    0xf708: Icons.delete_rounded,
    0xf666: Icons.sports_esports_rounded,
    0xf6fb: Icons.people_rounded,
    0xf64f: Icons.park_rounded,
    0xf72a: Icons.dark_mode_rounded,
  };

  Color get color => Color(colorValue);

  /// Normalized hashtag representation, e.g. '#gym' or '#walking'
  String get hashtag {
    if (label.startsWith('#')) return label;
    final clean = label.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '');
    return '#$clean';
  }

  ActivityTag copyWith({
    String? id,
    String? label,
    int? iconCodePoint,
    String? iconFontFamily,
    String? iconFontPackage,
    int? colorValue,
    bool? isCustom,
  }) {
    return ActivityTag(
      id: id ?? this.id,
      label: label ?? this.label,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      iconFontFamily: iconFontFamily ?? this.iconFontFamily,
      iconFontPackage: iconFontPackage ?? this.iconFontPackage,
      colorValue: colorValue ?? this.colorValue,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'iconCodePoint': iconCodePoint,
    'iconFontFamily': iconFontFamily,
    'iconFontPackage': iconFontPackage,
    'colorValue': colorValue,
    'isCustom': isCustom,
  };

  factory ActivityTag.fromJson(Map<String, dynamic> json) {
    return ActivityTag(
      id:
          json['id'] as String? ??
          'tag_${DateTime.now().millisecondsSinceEpoch}',
      label: json['label'] as String? ?? 'Tag',
      iconCodePoint:
          (json['iconCodePoint'] as num?)?.toInt() ??
          Icons.label_rounded.codePoint,
      iconFontFamily: json['iconFontFamily'] as String? ?? 'CupertinoIcons',
      iconFontPackage: json['iconFontPackage'] as String? ?? 'cupertino_icons',
      colorValue: (json['colorValue'] as num?)?.toInt() ?? 0xFF0A84FF,
      isCustom: json['isCustom'] as bool? ?? true,
    );
  }

  /// Top 15 research-backed daily human activities
  static List<ActivityTag> get default15Tags => [
    ActivityTag(
      id: 'tag_walking',
      label: 'Walking',
      iconCodePoint: Icons.explore_rounded.codePoint,
      colorValue: 0xFF30D158, // Green
      isCustom: false,
    ),
    ActivityTag(
      id: 'tag_gym',
      label: 'Gym',
      iconCodePoint: Icons.local_fire_department_rounded.codePoint,
      colorValue: 0xFFFF453A, // Red
      isCustom: false,
    ),
    ActivityTag(
      id: 'tag_studying',
      label: 'Studying',
      iconCodePoint: Icons.menu_book_rounded.codePoint,
      colorValue: 0xFF0A84FF, // Blue
      isCustom: false,
    ),
    ActivityTag(
      id: 'tag_deep_work',
      label: 'Deep Work',
      iconCodePoint: Icons.laptop_mac_rounded.codePoint,
      colorValue: 0xFF5E5CE6, // Indigo
      isCustom: false,
    ),
    ActivityTag(
      id: 'tag_bathing',
      label: 'Bathing',
      iconCodePoint: Icons.water_drop_rounded.codePoint,
      colorValue: 0xFF64D2FF, // Teal/Sky
      isCustom: false,
    ),
    ActivityTag(
      id: 'tag_washroom',
      label: 'Washroom',
      iconCodePoint: Icons.auto_awesome_rounded.codePoint,
      colorValue: 0xFF64D2FF,
      isCustom: false,
    ),
    ActivityTag(
      id: 'tag_reading',
      label: 'Reading',
      iconCodePoint: Icons.description_rounded.codePoint,
      colorValue: 0xFFFF9F0A, // Orange
      isCustom: false,
    ),
    ActivityTag(
      id: 'tag_meditation',
      label: 'Meditation',
      iconCodePoint: Icons.favorite_rounded.codePoint,
      colorValue: 0xFFBF5AF2, // Purple
      isCustom: false,
    ),
    ActivityTag(
      id: 'tag_commute',
      label: 'Commute',
      iconCodePoint: Icons.directions_car_rounded.codePoint,
      colorValue: 0xFFFFD60A, // Yellow
      isCustom: false,
    ),
    ActivityTag(
      id: 'tag_cooking',
      label: 'Cooking',
      iconCodePoint: Icons.local_fire_department_rounded.codePoint,
      colorValue: 0xFFFF9F0A,
      isCustom: false,
    ),
    ActivityTag(
      id: 'tag_chores',
      label: 'Chores',
      iconCodePoint: Icons.delete_rounded.codePoint,
      colorValue: 0xFF8E8E93, // Gray
      isCustom: false,
    ),
    ActivityTag(
      id: 'tag_gaming',
      label: 'Gaming',
      iconCodePoint: Icons.sports_esports_rounded.codePoint,
      colorValue: 0xFFFF375F, // Pink
      isCustom: false,
    ),
    ActivityTag(
      id: 'tag_family',
      label: 'Family',
      iconCodePoint: Icons.people_rounded.codePoint,
      colorValue: 0xFF30D158,
      isCustom: false,
    ),
    ActivityTag(
      id: 'tag_dining',
      label: 'Dining',
      iconCodePoint: Icons.park_rounded.codePoint,
      colorValue: 0xFFFF9F0A,
      isCustom: false,
    ),
    ActivityTag(
      id: 'tag_sleep',
      label: 'Sleep',
      iconCodePoint: Icons.dark_mode_rounded.codePoint,
      colorValue: 0xFF5E5CE6,
      isCustom: false,
    ),
  ];
}
