import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/models/goal.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/models/project.dart';
import 'package:notekar/services/goals_service.dart';
import 'package:notekar/services/project_service.dart';
import 'package:notekar/widgets/hashtag_suggestion_overlay.dart';
import 'package:notekar/widgets/pressable_scale.dart';

class _ReflectionMilestoneItem {
  final String id;
  final String title;
  final bool isCompleted;

  const _ReflectionMilestoneItem({
    required this.id,
    required this.title,
    required this.isCompleted,
  });
}

/// Result returned from the Project Reflection dialog.
class ProjectReflectionResult {
  const ProjectReflectionResult({
    required this.note,
    this.completedMilestoneIds = const [],
  });

  final String note;
  final List<String> completedMilestoneIds;
}

/// Apple HIG modal sheet presented when closing/pausing a project or target session.
/// Prompts the user for reflections, key learnings, and milestone completions.
class ProjectReflectionDialog extends StatefulWidget {
  const ProjectReflectionDialog({
    super.key,
    required this.p,
    this.project,
    this.goal,
    this.sessionDuration,
  }) : assert(
         project != null || goal != null,
         'Either project or goal must be provided',
       );

  final Palette p;
  final Project? project;
  final Goal? goal;
  final Duration? sessionDuration;

  static Future<ProjectReflectionResult?> show(
    BuildContext context, {
    required Palette p,
    Project? project,
    Goal? goal,
    Duration? sessionDuration,
  }) {
    return showModalBottomSheet<ProjectReflectionResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProjectReflectionDialog(
        p: p,
        project: project,
        goal: goal,
        sessionDuration: sessionDuration,
      ),
    );
  }

  @override
  State<ProjectReflectionDialog> createState() =>
      _ProjectReflectionDialogState();
}

class _ProjectReflectionDialogState extends State<ProjectReflectionDialog> {
  final TextEditingController _textCtrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final Set<String> _checkedMilestones = <String>{};

  List<_ReflectionMilestoneItem> get _milestonesList {
    if (widget.project != null) {
      return widget.project!.milestones
          .map(
            (m) => _ReflectionMilestoneItem(
              id: m.id,
              title: m.title,
              isCompleted: m.isCompleted,
            ),
          )
          .toList();
    }
    if (widget.goal != null) {
      return widget.goal!.milestones
          .map(
            (m) => _ReflectionMilestoneItem(
              id: m.id,
              title: m.title,
              isCompleted: m.isCompleted,
            ),
          )
          .toList();
    }
    return [];
  }

  @override
  void initState() {
    super.initState();
    // Default checked milestones to any currently completed in the project/goal
    for (final m in _milestonesList) {
      if (m.isCompleted) {
        _checkedMilestones.add(m.id);
      }
    }
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final mins = d.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${mins}m';
    }
    return '${mins}m';
  }

  Future<void> _handleSave() async {
    HapticFeedback.mediumImpact();
    // Persist any milestone toggles that changed
    final originalCompleted = _milestonesList
        .where((m) => m.isCompleted)
        .map((m) => m.id)
        .toSet();

    final newlyCompleted = _checkedMilestones.difference(originalCompleted);
    for (final msId in newlyCompleted) {
      if (widget.project != null) {
        await ProjectService.instance.toggleMilestone(widget.project!.id, msId);
      } else if (widget.goal != null) {
        await GoalsService.instance.toggleMilestone(widget.goal!.id, msId);
      }
    }

    if (mounted) {
      Navigator.pop(
        context,
        ProjectReflectionResult(
          note: _textCtrl.text.trim(),
          completedMilestoneIds: newlyCompleted.toList(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final uncompletedMilestones = _milestonesList;

    return AppSheet(
      p: p,
      title: 'Session Reflection',
      trailingAction: PressableScale(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
        },
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: p.surface2, shape: BoxShape.circle),
          child: Icon(Icons.close_rounded, size: 18, color: p.subtext),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Project summary card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: p.surface2,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: p.surface3.withAlpha(120)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: p.accent.withAlpha(35),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.flag_rounded, size: 24, color: p.accent),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.project?.title ??
                              widget.goal?.title ??
                              'Target',
                          style: TextStyle(
                            color: p.text,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (widget.sessionDuration != null) ...[
                              Icon(
                                Icons.timer_outlined,
                                size: 14,
                                color: p.subtext,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_formatDuration(widget.sessionDuration!)} session',
                                style: TextStyle(
                                  color: p.subtext,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text('•', style: TextStyle(color: p.subtext)),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              widget.project?.category ??
                                  widget.goal?.category ??
                                  'Target',
                              style: TextStyle(
                                color: p.accent,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Milestones section if available
            if (uncompletedMilestones.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'DID YOU REACH A MILESTONE?',
                  style: TextStyle(
                    color: p.subtext,
                    fontSize: 11,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: p.surface2,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: p.surface3.withAlpha(120)),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: uncompletedMilestones.length,
                  separatorBuilder: (_, index) => Divider(
                    height: 1,
                    indent: 48,
                    endIndent: 16,
                    color: p.surface3.withAlpha(80),
                  ),
                  itemBuilder: (context, index) {
                    final ms = uncompletedMilestones[index];
                    final isChecked = _checkedMilestones.contains(ms.id);
                    return PressableScale(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          if (isChecked) {
                            _checkedMilestones.remove(ms.id);
                          } else {
                            _checkedMilestones.add(ms.id);
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: isChecked
                                    ? p.accent
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isChecked
                                      ? p.accent
                                      : p.subtext.withAlpha(140),
                                  width: 2,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: isChecked
                                  ? const Icon(
                                      Icons.check_rounded,
                                      size: 14,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                ms.title,
                                style: TextStyle(
                                  color: isChecked ? p.subtext : p.text,
                                  fontSize: 14,
                                  fontWeight: isChecked
                                      ? FontWeight.w500
                                      : FontWeight.w600,
                                  decoration: isChecked
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Reflection notes input with Hashtag Suggestion Overlay
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'KEY LEARNINGS & INSIGHTS',
                style: TextStyle(
                  color: p.subtext,
                  fontSize: 11,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            HashtagSuggestionOverlay(controller: _textCtrl, p: p),
            Container(
              decoration: BoxDecoration(
                color: p.surface2,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: p.surface3.withAlpha(120)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: TextField(
                controller: _textCtrl,
                focusNode: _focusNode,
                maxLines: 3,
                minLines: 2,
                style: TextStyle(color: p.text, fontSize: 15, height: 1.35),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  hintText:
                      'e.g. Read 4 chapters; key insight on state management...',
                  hintStyle: TextStyle(
                    color: p.subtext.withAlpha(150),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Actions
            Row(
              children: [
                Expanded(
                  child: PressableScale(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: p.surface2,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: p.surface3.withAlpha(120)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: p.subtext,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: PressableScale(
                    onTap: _handleSave,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: p.accent,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: p.accent.withAlpha(80),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Save Reflection',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
