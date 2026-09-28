// ignore_for_file: non_const_argument_for_const_parameter
import 'package:flutter/cupertino.dart';

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
    return _iconLookup[codePoint] ?? CupertinoIcons.tag_fill;
  }

  static final Map<int, IconData> _iconLookup = {
    CupertinoIcons.tag_fill.codePoint: CupertinoIcons.tag_fill,
    CupertinoIcons.compass_fill.codePoint: CupertinoIcons.compass_fill,
    CupertinoIcons.flame_fill.codePoint: CupertinoIcons.flame_fill,
    CupertinoIcons.book_fill.codePoint: CupertinoIcons.book_fill,
    CupertinoIcons.device_laptop.codePoint: CupertinoIcons.device_laptop,
    CupertinoIcons.drop_fill.codePoint: CupertinoIcons.drop_fill,
    CupertinoIcons.sparkles.codePoint: CupertinoIcons.sparkles,
    CupertinoIcons.doc_text_fill.codePoint: CupertinoIcons.doc_text_fill,
    CupertinoIcons.heart_circle_fill.codePoint:
        CupertinoIcons.heart_circle_fill,
    CupertinoIcons.car_fill.codePoint: CupertinoIcons.car_fill,
    CupertinoIcons.flame.codePoint: CupertinoIcons.flame,
    CupertinoIcons.trash.codePoint: CupertinoIcons.trash,
    CupertinoIcons.gamecontroller_fill.codePoint:
        CupertinoIcons.gamecontroller_fill,
    CupertinoIcons.person_2_fill.codePoint: CupertinoIcons.person_2_fill,
    CupertinoIcons.suit_club_fill.codePoint: CupertinoIcons.suit_club_fill,
    CupertinoIcons.moon_fill.codePoint: CupertinoIcons.moon_fill,
    0xf56b: CupertinoIcons.tag_fill,
    0xf657: CupertinoIcons.compass_fill,
    0xf54f: CupertinoIcons.flame_fill,
    0xf524: CupertinoIcons.book_fill,
    0xf598: CupertinoIcons.device_laptop,
    0xf772: CupertinoIcons.drop_fill,
    0xf6e5: CupertinoIcons.sparkles,
    0xf70e: CupertinoIcons.doc_text_fill,
    0xf6e9: CupertinoIcons.heart_circle_fill,
    0xf555: CupertinoIcons.car_fill,
    0xf626: CupertinoIcons.flame,
    0xf708: CupertinoIcons.trash,
    0xf666: CupertinoIcons.gamecontroller_fill,
    0xf6fb: CupertinoIcons.person_2_fill,
    0xf64f: CupertinoIcons.suit_club_fill,
    0xf72a: CupertinoIcons.moon_fill,
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
          CupertinoIcons.tag_fill.codePoint,
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
      iconCodePoint: CupertinoIcons.compass_fill.codePoint,
      colorValue: 0xFF30D158, // Green
      isCustom: false,
    ),
    ActivityTag(
      id: 'tag_gym',
      label: 'Gym',
      iconCodePoint: CupertinoIcons.flame_fill.codePoint,
      colorValue: 0xFFFF453A, // Red
      isCustom: false,
    ),
    ActivityTag(
      id: 'tag_studying',
      label: 'Studying',
      iconCodePoint: CupertinoIcons.book_fill.codePoint,
      colorValue: 0xFF0A84FF, // Blue
      isCustom: false,
    ),
    ActivityTag(
      id: 'tag_deep_work',
      label: 'Deep Work',
      iconCodePoint: CupertinoIcons.device_laptop.codePoint,
      colorValue: 0xFF5E5CE6, // Indigo
      isCustom: false,
    ),
    ActivityTag(
      id: 'tag_bathing',
      label: 'Bathing',
      iconCodePoint: CupertinoIcons.drop_fill.codePoint,
      colorValue: 0xFF64D2FF, // Teal/Sky
      isCustom: false,
    ),
    ActivityTag(
      id: 'tag_washroom',
      label: 'Washroom',
      iconCodePoint: CupertinoIcons.sparkles.codePoint,
      colorValue: 0xFF64D2FF,
      isCustom: false,
    ),
    ActivityTag(
      id: 'tag_reading',
      label: 'Reading',
      iconCodePoint: CupertinoIcons.doc_text_fill.codePoint,
      colorValue: 0xFFFF9F0A, // Orange
      isCustom: false,
    ),
    ActivityTag(
      id: 'tag_meditation',
      label: 'Meditation',
      iconCodePoint: CupertinoIcons.heart_circle_fill.codePoint,
      colorValue: 0xFFBF5AF2, // Purple
      isCustom: false,
    ),
    ActivityTag(
      id: 'tag_commute',
      label: 'Commute',
      iconCodePoint: CupertinoIcons.car_fill.codePoint,
      colorValue: 0xFFFFD60A, // Yellow
      isCustom: false,
    ),
    ActivityTag(
      id: 'tag_cooking',
      label: 'Cooking',
      iconCodePoint: CupertinoIcons.flame.codePoint,
      colorValue: 0xFFFF9F0A,
      isCustom: false,
    ),
    ActivityTag(
      id: 'tag_chores',
      label: 'Chores',
      iconCodePoint: CupertinoIcons.trash.codePoint,
      colorValue: 0xFF8E8E93, // Gray
      isCustom: false,
    ),
    ActivityTag(
      id: 'tag_gaming',
      label: 'Gaming',
      iconCodePoint: CupertinoIcons.gamecontroller_fill.codePoint,
      colorValue: 0xFFFF375F, // Pink
      isCustom: false,
    ),
    ActivityTag(
      id: 'tag_family',
      label: 'Family',
      iconCodePoint: CupertinoIcons.person_2_fill.codePoint,
      colorValue: 0xFF30D158,
      isCustom: false,
    ),
    ActivityTag(
      id: 'tag_dining',
      label: 'Dining',
      iconCodePoint: CupertinoIcons.suit_club_fill.codePoint,
      colorValue: 0xFFFF9F0A,
      isCustom: false,
    ),
    ActivityTag(
      id: 'tag_sleep',
      label: 'Sleep',
      iconCodePoint: CupertinoIcons.moon_fill.codePoint,
      colorValue: 0xFF5E5CE6,
      isCustom: false,
    ),
  ];
}
