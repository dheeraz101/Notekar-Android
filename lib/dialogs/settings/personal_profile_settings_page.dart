import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notekar/dialogs/app_date_picker_sheet.dart';
import 'package:notekar/dialogs/shareable_profile_card_sheet.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/services/user_profile_service.dart';
import 'package:notekar/utils/app_logger.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/common_elements.dart';
import 'package:notekar/widgets/pressable_scale.dart';
import 'package:notekar/widgets/settings_widgets.dart';

class PersonalProfileSettingsPage extends StatefulWidget {
  const PersonalProfileSettingsPage({
    super.key,
    required this.p,
    this.onSaved,
    this.onLearnMoreBeta,
  });

  final Palette p;
  final VoidCallback? onSaved;
  final VoidCallback? onLearnMoreBeta;

  @override
  State<PersonalProfileSettingsPage> createState() =>
      _PersonalProfileSettingsPageState();
}

class _PersonalProfileSettingsPageState
    extends State<PersonalProfileSettingsPage> {
  final TextEditingController _nameController = TextEditingController();
  DateTime? _dob;
  Uint8List? _customAvatarBytes;
  int? _presetIndex;
  int _mementoMoriYears = UserProfileService.defaultMementoMoriYears;
  bool _isSaving = false;

  Palette get p => widget.p;

  @override
  void initState() {
    super.initState();
    final profile = UserProfileService();
    _nameController.text = profile.name;
    _dob = profile.dob;
    _customAvatarBytes = profile.avatarBytes;
    _presetIndex = profile.presetAvatarIndex;
    _mementoMoriYears = profile.mementoMoriYears;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    HapticFeedback.lightImpact();
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _customAvatarBytes = bytes;
          _presetIndex = null;
        });
      }
    } catch (e, stack) {
      AppLogger().error('Failed to pick profile image', e, stack);
      if (mounted) {
        showIosPillToast(
          context: context,
          p: p,
          message: 'Could not access photo'.localized(context),
          icon: Icons.photo_camera_outlined,
        );
      }
    }
  }

  Future<void> _selectDob() async {
    HapticFeedback.selectionClick();
    final now = DateTime.now();
    final initialDate = _dob ?? DateTime(now.year - 24, now.month, now.day);

    final picked = await AppDatePickerSheet.show(
      context,
      p: p,
      title: 'Date of Birth',
      mode: CupertinoDatePickerMode.date,
      initialDateTime: initialDate,
      minimumDate: DateTime(1900, 1, 1),
      maximumDate: now,
    );

    if (picked != null && mounted) {
      setState(() {
        _dob = picked;
        // Dynamically ensure memento mori years >= current age
        final currentAgeYears = now.difference(picked).inDays / 365.2425;
        if (_mementoMoriYears < currentAgeYears.ceil()) {
          _mementoMoriYears = currentAgeYears.ceil().clamp(
            1,
            UserProfileService.maxMementoMoriYears,
          );
        }
      });
    }
  }

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    try {
      await UserProfileService().saveProfile(
        name: _nameController.text.trim(),
        dob: _dob,
        customAvatarBytes: _customAvatarBytes,
        presetIndex: _presetIndex,
        mementoMoriYears: _mementoMoriYears,
      );

      if (mounted) {
        setState(() => _isSaving = false);
        widget.onSaved?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Personal identity updated.'.localized(context),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            backgroundColor: p.surface2,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e, stack) {
      AppLogger().error('Failed to save profile', e, stack);
      if (mounted) {
        setState(() => _isSaving = false);
        showIosPillToast(
          context: context,
          p: p,
          message: 'Failed to save profile'.localized(context),
          icon: Icons.error_outline_rounded,
        );
      }
    }
  }

  String _formatDob(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    double? ageYears;
    int? weeksLived;
    int? weeksRemaining;
    double livedRatio = 0.0;

    if (_dob != null) {
      final daysLived = now.difference(_dob!).inDays.clamp(0, 36500);
      ageYears = daysLived / 365.2425;
      final totalDays = (_mementoMoriYears * 365.2425).round();
      final remainingDays = math.max(0, totalDays - daysLived);
      weeksLived = daysLived ~/ 7;
      weeksRemaining = remainingDays ~/ 7;
      livedRatio = totalDays > 0
          ? (daysLived / totalDays).clamp(0.0, 1.0)
          : 0.0;
    }

    // 24-Hour Life Clock & Leverage
    final lifeFraction = (ageYears != null && _mementoMoriYears > 0)
        ? (ageYears / _mementoMoriYears).clamp(0.0, 1.0)
        : 0.0;
    final totalClockMinutes = (lifeFraction * 24 * 60).round();
    final clockHours24 = (totalClockMinutes ~/ 60) % 24;
    final clockMinutes = totalClockMinutes % 60;
    final isPm = clockHours24 >= 12;
    final clockHours12 = clockHours24 == 0
        ? 12
        : (clockHours24 > 12 ? clockHours24 - 12 : clockHours24);
    final lifeClockFormatted =
        '${clockHours12.toString().padLeft(2, '0')}:${clockMinutes.toString().padLeft(2, '0')} ${isPm ? 'PM' : 'AM'}';
    final lifeClockTimeOfDay = clockHours24 < 6
        ? 'Dawn'
        : (clockHours24 < 12
              ? 'Morning'
              : (clockHours24 < 17
                    ? 'Afternoon'
                    : (clockHours24 < 21 ? 'Evening' : 'Night')));

    final remainingYears = (ageYears != null)
        ? math.max(0.0, _mementoMoriYears - ageYears)
        : _mementoMoriYears.toDouble();
    final remainingConsciousWeeks =
        ((weeksRemaining ?? (_mementoMoriYears * 52)) * (14.0 / 24.0)).round();
    final leverageYears = remainingYears / 14.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: spacing8),
        SettingsPageDescription(
          p: p,
          text:
              'Configure your personal identity, age, and Memento Mori horizon. Tailors conscious analytics and life perspective throughout NoteKar.'
                  .localized(context),
        ),
        const SizedBox(height: 12),

        // 1. Avatar Selector Hero with Perfect Edge-to-Edge Circular Clip
        Center(
          child: Column(
            children: [
              Stack(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: SizedBox(
                      width: 96,
                      height: 96,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: p.accent.withValues(alpha: 0.15),
                            ),
                          ),
                          ClipOval(
                            child: SizedBox.expand(
                              child: _customAvatarBytes != null
                                  ? Image.memory(
                                      _customAvatarBytes!,
                                      fit: BoxFit.cover,
                                      alignment: Alignment.center,
                                    )
                                  : (_presetIndex != null &&
                                            _presetIndex! >= 0 &&
                                            _presetIndex! <
                                                UserProfileService
                                                    .presetAvatars
                                                    .length
                                        ? Center(
                                            child: Text(
                                              UserProfileService
                                                  .presetAvatars[_presetIndex!],
                                              style: const TextStyle(
                                                fontSize: 46,
                                              ),
                                            ),
                                          )
                                        : Center(
                                            child:
                                                _nameController.text
                                                    .trim()
                                                    .isNotEmpty
                                                ? Text(
                                                    _nameController.text
                                                        .trim()[0]
                                                        .toUpperCase(),
                                                    style: TextStyle(
                                                      color: p.accent,
                                                      fontSize: 40,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                    ),
                                                  )
                                                : Icon(
                                                    CupertinoIcons.person_fill,
                                                    size: 46,
                                                    color: p.accent,
                                                  ),
                                          )),
                            ),
                          ),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: p.accent.withValues(alpha: 0.45),
                                width: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: p.accent,
                          shape: BoxShape.circle,
                          border: Border.all(color: p.surface, width: 2.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(
                          CupertinoIcons.camera_fill,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Preset Avatars Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (
                      int i = 0;
                      i < UserProfileService.presetAvatars.length;
                      i++
                    ) ...[
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _presetIndex = i;
                            _customAvatarBytes = null;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: _presetIndex == i
                                ? p.accent.withValues(alpha: 0.22)
                                : p.surface2,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _presetIndex == i
                                  ? p.accent
                                  : Colors.transparent,
                              width: 1.8,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              UserProfileService.presetAvatars[i],
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 2. Identity Inputs (Apple HIG Card)
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: p.surface2,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: p.border.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'YOUR NAME'.localized(context),
                style: TextStyle(
                  color: p.text3,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: p.surface3.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: p.border.withValues(alpha: 0.4)),
                ),
                child: CupertinoTextField(
                  controller: _nameController,
                  placeholder: 'e.g. Steve Jobs',
                  placeholderStyle: TextStyle(color: p.text3),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 13,
                  ),
                  style: TextStyle(
                    color: p.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textCapitalization: TextCapitalization.words,
                  decoration: const BoxDecoration(color: Colors.transparent),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(height: 18),

              // Date of Birth Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'DATE OF BIRTH'.localized(context),
                    style: TextStyle(
                      color: p.text3,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  if (ageYears != null)
                    Text(
                      '${ageYears.toStringAsFixed(1)} yrs old',
                      style: TextStyle(
                        color: p.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              PressableScale(
                onTap: _selectDob,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: p.surface3.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: p.border.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      Icon(CupertinoIcons.calendar, size: 18, color: p.accent),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _dob != null
                              ? _formatDob(_dob!)
                              : 'Tap to select Date of Birth',
                          style: TextStyle(
                            color: _dob != null ? p.text : p.text3,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        CupertinoIcons.chevron_down,
                        size: 14,
                        color: p.text3,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 3. Redesigned Memento Mori Horizon Card (Point 3: No truncation, Big Numbers, Rich Visuals)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: p.surface2,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: p.border.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(CupertinoIcons.hourglass, size: 16, color: p.orange),
                      const SizedBox(width: 8),
                      Text(
                        'MEMENTO MORI HORIZON',
                        style: TextStyle(
                          color: p.orange,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Max 100 Years',
                    style: TextStyle(
                      color: p.text3,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Big Bold Target Years Display
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$_mementoMoriYears',
                    style: TextStyle(
                      color: p.text,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Years Life Expectancy',
                    style: TextStyle(
                      color: p.text2,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Grounded life perspective strictly capped at 100 years.'
                    .localized(context),
                style: TextStyle(color: p.text3, fontSize: 12, height: 1.3),
              ),
              const SizedBox(height: 14),

              // Apple Slider
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: p.accent,
                  inactiveTrackColor: p.surface3,
                  thumbColor: p.accent,
                  overlayColor: p.accent.withValues(alpha: 0.15),
                  trackHeight: 5,
                ),
                child: Slider(
                  value: _mementoMoriYears.toDouble(),
                  min: math.max(20, (ageYears?.ceil() ?? 20)).toDouble(),
                  max: UserProfileService.maxMementoMoriYears.toDouble(),
                  divisions: 80,
                  onChanged: (val) {
                    setState(() {
                      _mementoMoriYears = val.round().clamp(
                        1,
                        UserProfileService.maxMementoMoriYears,
                      );
                    });
                  },
                ),
              ),

              if (_dob != null) ...[
                const SizedBox(height: 8),
                // Lived vs Remaining Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    height: 8,
                    color: p.surface3,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Row(
                          children: [
                            Container(
                              width: constraints.maxWidth * livedRatio,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [p.accent, p.orange],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Dual Hero Stats Grid (Big Numbers, No Truncation)
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: p.surface3.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'LIVED (${(livedRatio * 100).toStringAsFixed(0)}%)',
                              style: TextStyle(
                                color: p.text3,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$weeksLived wks',
                              style: TextStyle(
                                color: p.orange,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                            Text(
                              '${ageYears!.toStringAsFixed(1)} years lived',
                              style: TextStyle(
                                color: p.text3,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: p.surface3.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AHEAD (${((1 - livedRatio) * 100).toStringAsFixed(0)}%)',
                              style: TextStyle(
                                color: p.text3,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$weeksRemaining wks',
                              style: TextStyle(
                                color: p.green,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                            Text(
                              '${remainingYears.toStringAsFixed(1)} years left',
                              style: TextStyle(
                                color: p.text3,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 4. The Magician Predictive Insights Card (Point 10)
        if (_dob != null)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [p.surface2, p.surface3.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: p.accent.withValues(alpha: 0.35)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: p.accent.withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        size: 14,
                        color: p.accent,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'PREDICTIVE LIFE INTELLIGENCE'.localized(context),
                      style: TextStyle(
                        color: p.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 24-Hour Life Clock Insight
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: p.accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        CupertinoIcons.clock,
                        size: 18,
                        color: p.accent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'The 24-Hour Life Clock',
                            style: TextStyle(
                              color: p.text,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'If your entire life were a 24-hour day, it is currently $lifeClockFormatted ($lifeClockTimeOfDay). You have $remainingConsciousWeeks conscious waking weeks remaining.',
                            style: TextStyle(
                              color: p.text2,
                              fontSize: 12.5,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: p.border.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 14),

                // 1-Hour Daily Leverage Formula
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: p.green.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        CupertinoIcons.bolt_fill,
                        size: 18,
                        color: p.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '1-Hour Daily Leverage Formula',
                            style: TextStyle(
                              color: p.text,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Reclaiming just 1 hour of untracked drift per day expands your active lifetime by +${leverageYears.toStringAsFixed(1)} conscious years.',
                            style: TextStyle(
                              color: p.text2,
                              fontSize: 12.5,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        const SizedBox(height: 20),

        // 5. Actions (Save & Share Card)
        Row(
          children: [
            Expanded(
              child: PressableScale(
                onTap: _save,
                child: Container(
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: p.accent,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: p.accent.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _isSaving
                      ? const CupertinoActivityIndicator(color: Colors.white)
                      : Text(
                          'Save Profile'.localized(context),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            PressableScale(
              onTap: () {
                HapticFeedback.selectionClick();
                ShareableProfileCardSheet.show(context, p: p);
              },
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: p.surface2,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: p.border.withValues(alpha: 0.6)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.share, size: 18, color: p.accent),
                    const SizedBox(width: 8),
                    Text(
                      'Share Card'.localized(context),
                      style: TextStyle(
                        color: p.accent,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        if (widget.onLearnMoreBeta != null) ...[
          const SizedBox(height: 16),
          SettingsBetaNote(p: p, onLearnMore: widget.onLearnMoreBeta!),
        ],
        const SizedBox(height: spacing48),
      ],
    );
  }
}
