import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/services/user_profile_service.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/pressable_scale.dart';

/// Apple HIG Personalization Setup & Profile Edit Sheet.
class PersonalizationSetupDialog extends StatefulWidget {
  const PersonalizationSetupDialog({
    super.key,
    required this.p,
    this.isFirstTime = false,
    this.onSaved,
  });

  final Palette p;
  final bool isFirstTime;
  final VoidCallback? onSaved;

  static Future<void> show(
    BuildContext context, {
    required Palette p,
    bool isFirstTime = false,
    VoidCallback? onSaved,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => PersonalizationSetupDialog(
        p: p,
        isFirstTime: isFirstTime,
        onSaved: onSaved,
      ),
    );
  }

  @override
  State<PersonalizationSetupDialog> createState() =>
      _PersonalizationSetupDialogState();
}

class _PersonalizationSetupDialogState
    extends State<PersonalizationSetupDialog> {
  final UserProfileService _service = UserProfileService();
  late TextEditingController _nameController;

  DateTime? _dob;
  Uint8List? _customAvatarBytes;
  int? _presetIndex;
  late int _mementoMoriYears;
  bool _showDatePicker = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _service.name);
    _dob = _service.dob;
    _customAvatarBytes = _service.avatarBytes;
    _presetIndex = _service.presetAvatarIndex;
    _mementoMoriYears = _service.mementoMoriYears;
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
        maxWidth: 256,
        maxHeight: 256,
        imageQuality: 85,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _customAvatarBytes = bytes;
          _presetIndex = null;
        });
      }
    } catch (_) {}
  }

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    await _service.saveProfile(
      name: _nameController.text.trim(),
      dob: _dob,
      customAvatarBytes: _customAvatarBytes,
      presetIndex: _presetIndex,
      mementoMoriYears: _mementoMoriYears,
      completeOnboarding: true,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.of(context).pop();
      widget.onSaved?.call();
    }
  }

  String _formatDob(DateTime dt) {
    return DateFormat('MMMM d, yyyy').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final now = DateTime.now();

    // Calculate age preview
    double? ageYears;
    int? weeksLived;
    int? weeksRemaining;
    double livedRatio = 0.0;
    if (_dob != null) {
      final daysLived = now.difference(_dob!).inDays.clamp(0, 36500);
      ageYears = daysLived / 365.2425;
      weeksLived = daysLived ~/ 7;
      final totalDays = (_mementoMoriYears * 365.2425).round();
      final remainingDays = math.max(0, totalDays - daysLived);
      weeksRemaining = remainingDays ~/ 7;
      livedRatio = totalDays > 0
          ? (daysLived / totalDays).clamp(0.0, 1.0)
          : 0.0;
    }

    return AppSheet(
      p: p,
      title: widget.isFirstTime
          ? 'Personalize NoteKar'.localized(context)
          : 'Personal Profile'.localized(context),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Avatar Selector Hero
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 86,
                      height: 86,
                      decoration: BoxDecoration(
                        color: p.accent.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: p.accent.withValues(alpha: 0.4),
                          width: 2,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _customAvatarBytes != null
                          ? Image.memory(_customAvatarBytes!, fit: BoxFit.cover)
                          : (_presetIndex != null &&
                                    _presetIndex! >= 0 &&
                                    _presetIndex! <
                                        UserProfileService.presetAvatars.length
                                ? Center(
                                    child: Text(
                                      UserProfileService
                                          .presetAvatars[_presetIndex!],
                                      style: const TextStyle(fontSize: 42),
                                    ),
                                  )
                                : Center(
                                    child:
                                        _nameController.text.trim().isNotEmpty
                                        ? Text(
                                            _nameController.text
                                                .trim()[0]
                                                .toUpperCase(),
                                            style: TextStyle(
                                              color: p.accent,
                                              fontSize: 36,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          )
                                        : Icon(
                                            CupertinoIcons.person_fill,
                                            size: 40,
                                            color: p.accent,
                                          ),
                                  )),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: p.accent,
                          shape: BoxShape.circle,
                          border: Border.all(color: p.surface, width: 2),
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
            ),
            const SizedBox(height: 12),

            // Preset Avatars Row
            Center(
              child: SingleChildScrollView(
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
                          width: 34,
                          height: 34,
                          margin: const EdgeInsets.symmetric(horizontal: 2.5),
                          decoration: BoxDecoration(
                            color: _presetIndex == i
                                ? p.accent.withValues(alpha: 0.22)
                                : p.surface2,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _presetIndex == i
                                  ? p.accent
                                  : Colors.transparent,
                              width: 1.5,
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
            ),
            const SizedBox(height: 20),

            // Name Field
            Text(
              'YOUR NAME'.localized(context),
              style: TextStyle(
                color: p.text3,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: p.surface2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: p.border.withValues(alpha: 0.6)),
              ),
              child: CupertinoTextField(
                controller: _nameController,
                placeholder: 'e.g. Dheeraj',
                placeholderStyle: TextStyle(color: p.text3),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                style: TextStyle(color: p.text, fontSize: 15),
                textCapitalization: TextCapitalization.words,
                decoration: const BoxDecoration(color: Colors.transparent),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 18),

            // Date of Birth Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'DATE OF BIRTH'.localized(context),
                  style: TextStyle(
                    color: p.text3,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                if (ageYears != null)
                  Text(
                    '${ageYears.toStringAsFixed(1)} years old',
                    style: TextStyle(
                      color: p.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            PressableScale(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _showDatePicker = !_showDatePicker);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: p.surface2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: p.border.withValues(alpha: 0.6)),
                ),
                child: Row(
                  children: [
                    Icon(CupertinoIcons.calendar, size: 18, color: p.accent),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _dob != null
                            ? _formatDob(_dob!)
                            : 'Select Date of Birth',
                        style: TextStyle(
                          color: _dob != null ? p.text : p.text3,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      _showDatePicker
                          ? CupertinoIcons.chevron_up
                          : CupertinoIcons.chevron_down,
                      size: 14,
                      color: p.text3,
                    ),
                  ],
                ),
              ),
            ),

            if (_showDatePicker) ...[
              const SizedBox(height: 8),
              Container(
                height: 190,
                decoration: BoxDecoration(
                  color: p.surface2,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: p.border.withValues(alpha: 0.5)),
                ),
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: _dob ?? DateTime(2000, 1, 1),
                  minimumDate: DateTime(1910, 1, 1),
                  maximumDate: DateTime.now(),
                  onDateTimeChanged: (picked) {
                    setState(() => _dob = picked);
                  },
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Memento Mori Life Expectancy Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: p.surface2,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: p.border.withValues(alpha: 0.6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.hourglass,
                              size: 15,
                              color: p.orange,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'MEMENTO MORI HORIZON',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: p.text3,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$_mementoMoriYears yrs (Max 100)',
                        style: TextStyle(
                          color: p.accent,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Set your life expectancy to ground daily minutes in life perspective. Strictly capped at 100 years.'
                        .localized(context),
                    style: TextStyle(
                      color: p.text2,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: p.accent,
                      inactiveTrackColor: p.surface3,
                      thumbColor: p.accent,
                      overlayColor: p.accent.withValues(alpha: 0.15),
                      trackHeight: 4,
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
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: livedRatio,
                        minHeight: 6,
                        backgroundColor: p.surface3,
                        valueColor: AlwaysStoppedAnimation<Color>(p.orange),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'Lived: ${ageYears!.toStringAsFixed(1)} yrs ($weeksLived wks)',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: p.orange,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Remaining: $weeksRemaining wks',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              color: p.green,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Submit Button
            PressableScale(
              onTap: _save,
              child: Container(
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: p.accent,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: p.accent.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: _isSaving
                    ? const CupertinoActivityIndicator(color: Colors.white)
                    : Text(
                        widget.isFirstTime ? 'Get Started' : 'Save Changes',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
