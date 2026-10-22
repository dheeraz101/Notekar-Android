import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/category_service.dart';
import 'package:notekar/widgets/apple_hig_action_sheet.dart';
import 'package:notekar/widgets/pressable_scale.dart';

/// Modal sheet to confirm and customize merging 2 independent single logs
/// into a unified Two-Way Session with calculated duration.
class MergeEntriesSheet extends StatefulWidget {
  const MergeEntriesSheet({
    super.key,
    required this.p,
    required this.momentA,
    required this.momentB,
    required this.onConfirmMerge,
  });

  final Palette p;
  final Moment momentA;
  final Moment momentB;
  final Future<void> Function({
    required Moment startMoment,
    required Moment endMoment,
    required String? category,
    required String? combinedNote,
    required bool unifyNotes,
  })
  onConfirmMerge;

  static Future<void> show(
    BuildContext context, {
    required Palette p,
    required Moment momentA,
    required Moment momentB,
    required Future<void> Function({
      required Moment startMoment,
      required Moment endMoment,
      required String? category,
      required String? combinedNote,
      required bool unifyNotes,
    })
    onConfirmMerge,
  }) {
    HapticFeedback.selectionClick();
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      isScrollControlled: true,
      useSafeArea: true,
      sheetAnimationStyle: kTelegramSpringSheetAnimation,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: MergeEntriesSheet(
          p: p,
          momentA: momentA,
          momentB: momentB,
          onConfirmMerge: onConfirmMerge,
        ),
      ),
    );
  }

  @override
  State<MergeEntriesSheet> createState() => _MergeEntriesSheetState();
}

class _MergeEntriesSheetState extends State<MergeEntriesSheet> {
  late Moment _startMoment;
  late Moment _endMoment;
  late Duration _duration;
  late String _selectedCategory;
  late TextEditingController _noteController;
  List<String> _categories = List<String>.from(
    CategoryService.defaultCategories,
  );
  bool _unifyNotes = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.momentA.timestamp <= widget.momentB.timestamp) {
      _startMoment = widget.momentA;
      _endMoment = widget.momentB;
    } else {
      _startMoment = widget.momentB;
      _endMoment = widget.momentA;
    }

    final diff = _endMoment.timestamp - _startMoment.timestamp;
    _duration = Duration(milliseconds: diff > 0 ? diff : 0);

    _selectedCategory = _startMoment.category ?? _endMoment.category ?? 'Work';

    CategoryService().getCategories().then((cats) {
      if (mounted) {
        setState(() {
          _categories = cats;
        });
      }
    });

    final startNote = _startMoment.note.trim();
    final endNote = _endMoment.note.trim();
    final initialCombined = (startNote.isNotEmpty && endNote.isNotEmpty)
        ? '$startNote • $endNote'
        : (startNote.isNotEmpty ? startNote : endNote);

    _noteController = TextEditingController(text: initialCombined);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String _formatDurationPrecise(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) {
      return '${h}h ${m}m';
    } else if (m > 0) {
      return '${m}m ${s}s';
    } else {
      return '${s}s';
    }
  }

  Future<void> _handleMerge() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    try {
      final combinedNote = _noteController.text.trim();
      final updatedStart = _startMoment.copyWith(
        type: 'in',
        category: _selectedCategory,
        note: _unifyNotes
            ? combinedNote
            : (_startMoment.note.trim().isNotEmpty
                  ? _startMoment.note
                  : combinedNote),
      );
      final updatedEnd = _endMoment.copyWith(
        type: 'out',
        category: _selectedCategory,
        note: _unifyNotes ? '' : _endMoment.note,
      );

      await widget.onConfirmMerge(
        startMoment: updatedStart,
        endMoment: updatedEnd,
        category: _selectedCategory,
        combinedNote: combinedNote,
        unifyNotes: _unifyNotes,
      );
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final categories = _categories;

    return AppSheet(
      p: p,
      title: 'Merge into Session',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subtitle description
          Text(
            'Convert 2 independent logs into a connected Two-Way Session with tracked duration.',
            style: TextStyle(
              color: p.text2,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),

          // Visual Session Timeline Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: p.surface2,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: p.border.withValues(alpha: 0.6)),
            ),
            child: Column(
              children: [
                // Start Node (IN)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: p.green.withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: p.green.withValues(alpha: 0.5),
                          width: 1.2,
                        ),
                      ),
                      child: Text(
                        'IN',
                        style: TextStyle(
                          color: p.green,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                timeOnly(_startMoment.timestamp),
                                style: TextStyle(
                                  color: p.text,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                datePretty(_startMoment.timestamp),
                                style: TextStyle(color: p.text3, fontSize: 11),
                              ),
                            ],
                          ),
                          if (_startMoment.note.trim().isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              _startMoment.note.trim(),
                              style: TextStyle(color: p.text2, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),

                // Connecting Duration Bar
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 11),
                        width: 2,
                        height: 24,
                        color: p.border.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: 18),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: p.accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: p.accent.withValues(alpha: 0.3),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 13,
                              color: p.accent,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${_formatDurationPrecise(_duration)} Elapsed',
                              style: TextStyle(
                                color: p.accent,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // End Node (OUT)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: p.red.withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: p.red.withValues(alpha: 0.5),
                          width: 1.2,
                        ),
                      ),
                      child: Text(
                        'OUT',
                        style: TextStyle(
                          color: p.red,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                timeOnly(_endMoment.timestamp),
                                style: TextStyle(
                                  color: p.text,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                datePretty(_endMoment.timestamp),
                                style: TextStyle(color: p.text3, fontSize: 11),
                              ),
                            ],
                          ),
                          if (_endMoment.note.trim().isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              _endMoment.note.trim(),
                              style: TextStyle(color: p.text2, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Category Picker
          Text(
            'Session Category',
            style: TextStyle(
              color: p.text,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((cat) {
                final isSelected = cat == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: PressableScale(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedCategory = cat);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? p.accent : p.surface2,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? p.accent
                              : p.border.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? Colors.white : p.text2,
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w800
                              : FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Unify Notes Toggle
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unify Note Content',
                      style: TextStyle(
                        color: p.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Combine both entries into a single shared session title',
                      style: TextStyle(color: p.text3, fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: _unifyNotes,
                activeTrackColor: p.accent,
                onChanged: (val) {
                  HapticFeedback.selectionClick();
                  setState(() => _unifyNotes = val);
                },
              ),
            ],
          ),

          if (_unifyNotes) ...[
            const SizedBox(height: 10),
            TextField(
              controller: _noteController,
              style: TextStyle(color: p.text, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'e.g. Gym Workout, Focus Block',
                hintStyle: TextStyle(color: p.text3),
                filled: true,
                fillColor: p.surface2,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: p.border.withValues(alpha: 0.6),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: p.accent, width: 1.5),
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: p.text2,
                    side: BorderSide(color: p.border),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: p.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isSaving ? null : _handleMerge,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.merge_type_rounded, size: 18),
                  label: Text(
                    _isSaving ? 'Merging...' : 'Merge into Session',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
