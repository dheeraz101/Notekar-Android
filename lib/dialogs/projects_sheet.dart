import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/app_date_picker_sheet.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/models/project.dart';
import 'package:notekar/services/project_service.dart';
import 'package:notekar/widgets/pressable_scale.dart';

/// Apple HIG Projects Sheet for NoteKar.
/// Displays short-term initiatives, milestones, and active tracking progress.
class ProjectsSheet extends StatefulWidget {
  const ProjectsSheet({
    super.key,
    required this.p,
    required this.moments,
    this.activeCategory,
    this.activeProjectId,
    this.isSessionRunning = false,
    this.onStartSession,
    this.onStopSession,
  });

  final Palette p;
  final List<Moment> moments;
  final String? activeCategory;
  final String? activeProjectId;
  final bool isSessionRunning;
  final ValueChanged<Project>? onStartSession;
  final VoidCallback? onStopSession;

  static Future<dynamic> show(
    BuildContext context, {
    required Palette p,
    required List<Moment> moments,
    String? activeCategory,
    String? activeProjectId,
    bool isSessionRunning = false,
    ValueChanged<Project>? onStartSession,
    VoidCallback? onStopSession,
  }) {
    return showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProjectsSheet(
        p: p,
        moments: moments,
        activeCategory: activeCategory,
        activeProjectId: activeProjectId,
        isSessionRunning: isSessionRunning,
        onStartSession: onStartSession,
        onStopSession: onStopSession,
      ),
    );
  }

  @override
  State<ProjectsSheet> createState() => _ProjectsSheetState();
}

class _ProjectsSheetState extends State<ProjectsSheet> {
  int _selectedTab = 0; // 0: Active, 1: Completed
  List<Project> _projects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProjects();
    ProjectService.instance.projectsNotifier.addListener(_onProjectsChanged);
  }

  @override
  void dispose() {
    ProjectService.instance.projectsNotifier.removeListener(_onProjectsChanged);
    super.dispose();
  }

  void _onProjectsChanged() {
    if (mounted) {
      setState(() {
        _projects = ProjectService.instance.projectsNotifier.value;
      });
    }
  }

  Future<void> _loadProjects() async {
    final list = await ProjectService.instance.ensureInitialized();
    if (mounted) {
      setState(() {
        _projects = list;
        _isLoading = false;
      });
    }
  }

  void _openCreateOrEditProjectDialog([Project? existing]) {
    HapticFeedback.lightImpact();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreateOrEditProjectModal(
        p: widget.p,
        existing: existing,
        defaultCategory: widget.activeCategory,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final activeProjects = _projects.where((p) => !p.isCompleted).toList();
    final completedProjects = _projects.where((p) => p.isCompleted).toList();
    final displayProjects = _selectedTab == 0
        ? activeProjects
        : completedProjects;

    return AppSheet(
      p: p,
      title: 'Projects & Milestones',
      trailingAction: PressableScale(
        onTap: () => _openCreateOrEditProjectDialog(),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: p.surface3, shape: BoxShape.circle),
          child: Icon(Icons.add_rounded, size: 20, color: p.accent),
        ),
      ),
      child: Column(
        children: [
          // Segmented tab control (Active / Completed)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: p.surface2,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: p.surface3.withAlpha(120)),
              ),
              padding: const EdgeInsets.all(3),
              child: Row(
                children: [
                  Expanded(
                    child: PressableScale(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedTab = 0);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: _selectedTab == 0
                              ? p.accent
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(17),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Active (${activeProjects.length})',
                          style: TextStyle(
                            color: _selectedTab == 0 ? Colors.white : p.subtext,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: PressableScale(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedTab = 1);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: _selectedTab == 1
                              ? p.accent
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(17),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Completed (${completedProjects.length})',
                          style: TextStyle(
                            color: _selectedTab == 1 ? Colors.white : p.subtext,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Project cards list
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: p.accent,
                      strokeWidth: 2,
                    ),
                  )
                : displayProjects.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: p.surface2,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              _selectedTab == 0
                                  ? Icons.flag_outlined
                                  : Icons.check_circle_outline_rounded,
                              size: 32,
                              color: p.subtext,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _selectedTab == 0
                                ? 'No Active Projects'
                                : 'No Completed Projects',
                            style: TextStyle(
                              color: p.text,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedTab == 0
                                ? 'Create a short-term initiative with milestones like "Finish reading a book" or "Learn Chess".'
                                : 'Completed initiatives will appear here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: p.subtext,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                          if (_selectedTab == 0) ...[
                            const SizedBox(height: 20),
                            PressableScale(
                              onTap: () => _openCreateOrEditProjectDialog(),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: p.accent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  '+ New Project',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    itemCount: displayProjects.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final project = displayProjects[index];
                      final isCurrentlyActive =
                          widget.activeProjectId == project.id &&
                          widget.isSessionRunning;

                      return _ProjectCard(
                        key: ValueKey(project.id),
                        p: p,
                        project: project,
                        moments: widget.moments,
                        isCurrentlyTracking: isCurrentlyActive,
                        onStartSession: widget.onStartSession,
                        onStopSession: widget.onStopSession,
                        onEdit: () => _openCreateOrEditProjectDialog(project),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatefulWidget {
  const _ProjectCard({
    super.key,
    required this.p,
    required this.project,
    required this.moments,
    this.isCurrentlyTracking = false,
    this.onStartSession,
    this.onStopSession,
    this.onEdit,
  });

  final Palette p;
  final Project project;
  final List<Moment> moments;
  final bool isCurrentlyTracking;
  final ValueChanged<Project>? onStartSession;
  final VoidCallback? onStopSession;
  final VoidCallback? onEdit;

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  final TextEditingController _quickMsCtrl = TextEditingController();
  bool _showAddMilestone = false;

  @override
  void dispose() {
    _quickMsCtrl.dispose();
    super.dispose();
  }

  String _formatTracked(Duration d) {
    final totalHours = d.inMinutes / 60.0;
    if (totalHours < 0.1) {
      return '${d.inMinutes}m tracked';
    }
    return '${totalHours.toStringAsFixed(1)}h tracked';
  }

  void _handleAddMilestone() {
    final text = _quickMsCtrl.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.lightImpact();
    ProjectService.instance.addMilestone(widget.project.id, text);
    _quickMsCtrl.clear();
    setState(() => _showAddMilestone = false);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final project = widget.project;
    final tracked = project.computeTrackedDuration(widget.moments);
    final trackedMins = tracked.inMinutes;
    final targetMins = project.targetMinutes;

    double progress = 0.0;
    if (targetMins > 0) {
      progress = (trackedMins / targetMins).clamp(0.0, 1.0);
    } else if (project.milestones.isNotEmpty) {
      progress = project.milestoneProgress;
    }

    return Container(
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: widget.isCurrentlyTracking
              ? p.accent
              : p.surface3.withAlpha(120),
          width: widget.isCurrentlyTracking ? 2 : 1,
        ),
        boxShadow: widget.isCurrentlyTracking
            ? [
                BoxShadow(
                  color: p.accent.withAlpha(40),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: p.accent.withAlpha(30),
                  borderRadius: BorderRadius.circular(13),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.flag_rounded, size: 22, color: p.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.title,
                      style: TextStyle(
                        color: p.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (project.description.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        project.description,
                        style: TextStyle(color: p.subtext, fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: const Size(28, 28),
                onPressed: () => _showOptionsSheet(context),
                child: Icon(
                  Icons.more_horiz_rounded,
                  color: p.subtext,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Metadata row (Category, Time tracked, Target)
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (project.category != null && project.category!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: p.surface3.withAlpha(120),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    project.category!,
                    style: TextStyle(
                      color: p.text,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: p.surface3.withAlpha(120),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _formatTracked(tracked),
                  style: TextStyle(
                    color: p.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (targetMins > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: p.surface3.withAlpha(120),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Target: ${(targetMins / 60.0).toStringAsFixed(1)}h',
                    style: TextStyle(
                      color: p.subtext,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (project.deadline != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: p.surface3.withAlpha(120),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Due ${_formatDeadline(project.deadline!)}',
                    style: TextStyle(
                      color: p.subtext,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Apple HIG Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: p.surface3,
              valueColor: AlwaysStoppedAnimation<Color>(p.accent),
            ),
          ),
          const SizedBox(height: 14),

          // Milestones section
          if (project.milestones.isNotEmpty) ...[
            Text(
              'MILESTONES (${project.completedMilestonesCount}/${project.milestones.length})',
              style: TextStyle(
                color: p.subtext,
                fontSize: 11,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            ...project.milestones.map((ms) => _buildMilestoneRow(ms, p)),
            const SizedBox(height: 6),
          ],

          // Quick Add Milestone or Input
          if (_showAddMilestone) ...[
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: p.surface3,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.center,
                    child: TextField(
                      controller: _quickMsCtrl,
                      autofocus: true,
                      style: TextStyle(color: p.text, fontSize: 13),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        hintText: 'Milestone title...',
                        hintStyle: TextStyle(
                          color: p.subtext.withAlpha(140),
                          fontSize: 13,
                        ),
                      ),
                      onSubmitted: (_) => _handleAddMilestone(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PressableScale(
                  onTap: _handleAddMilestone,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: p.accent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                PressableScale(
                  onTap: () => setState(() => _showAddMilestone = false),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: p.surface3,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: p.subtext,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ] else ...[
            PressableScale(
              onTap: () => setState(() => _showAddMilestone = true),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.add_circle_outline_rounded,
                      size: 16,
                      color: p.accent,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Add Milestone',
                      style: TextStyle(
                        color: p.accent,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Footer Action (Start / Stop Session)
          if (!project.isCompleted)
            PressableScale(
              onTap: () {
                HapticFeedback.mediumImpact();
                if (widget.isCurrentlyTracking) {
                  widget.onStopSession?.call();
                } else {
                  Navigator.pop(context);
                  widget.onStartSession?.call(project);
                }
              },
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: widget.isCurrentlyTracking
                      ? const Color(0xFFEF4444)
                      : p.accent,
                  borderRadius: BorderRadius.circular(22),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.isCurrentlyTracking
                          ? Icons.stop_rounded
                          : Icons.play_arrow_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.isCurrentlyTracking
                          ? 'Stop Active Session'
                          : '▶ Start Session',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMilestoneRow(ProjectMilestone ms, Palette p) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: PressableScale(
        onTap: () {
          HapticFeedback.selectionClick();
          ProjectService.instance.toggleMilestone(widget.project.id, ms.id);
        },
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: ms.isCompleted ? p.accent : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: ms.isCompleted ? p.accent : p.subtext.withAlpha(140),
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: ms.isCompleted
                  ? const Icon(
                      Icons.check_rounded,
                      size: 13,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                ms.title,
                style: TextStyle(
                  color: ms.isCompleted ? p.subtext : p.text,
                  fontSize: 13,
                  fontWeight: ms.isCompleted
                      ? FontWeight.w500
                      : FontWeight.w600,
                  decoration: ms.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: const Size(24, 24),
              onPressed: () {
                HapticFeedback.lightImpact();
                ProjectService.instance.deleteMilestone(
                  widget.project.id,
                  ms.id,
                );
              },
              child: Icon(
                Icons.close_rounded,
                size: 14,
                color: p.subtext.withAlpha(120),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDeadline(int ms) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
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
    return '${months[dt.month - 1]} ${dt.day}';
  }

  void _showOptionsSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    showCupertinoModalPopup<void>(
      context: context,
      builder: (sheetContext) => CupertinoActionSheet(
        title: Text(widget.project.title),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(sheetContext);
              widget.onEdit?.call();
            },
            child: const Text('Edit Project'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(sheetContext);
              ProjectService.instance.toggleProjectCompletion(
                widget.project.id,
              );
            },
            child: Text(
              widget.project.isCompleted ? 'Mark Incomplete' : 'Mark Completed',
            ),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(sheetContext);
              _confirmDelete(context);
            },
            child: const Text('Delete Project'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(sheetContext),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showCupertinoDialog<void>(
      context: context,
      builder: (dlgContext) => CupertinoAlertDialog(
        title: const Text('Delete Project'),
        content: Text(
          'Are you sure you want to delete "${widget.project.title}"?',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(dlgContext),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(dlgContext);
              ProjectService.instance.deleteProject(widget.project.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _CreateOrEditProjectModal extends StatefulWidget {
  const _CreateOrEditProjectModal({
    required this.p,
    this.existing,
    this.defaultCategory,
  });

  final Palette p;
  final Project? existing;
  final String? defaultCategory;

  @override
  State<_CreateOrEditProjectModal> createState() =>
      _CreateOrEditProjectModalState();
}

class _CreateOrEditProjectModalState extends State<_CreateOrEditProjectModal> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _targetHoursCtrl;
  String? _selectedCategory;
  DateTime? _selectedDeadline;
  final List<String> _milestoneTitles = [];
  final TextEditingController _newMsCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final ex = widget.existing;
    _titleCtrl = TextEditingController(text: ex?.title ?? '');
    _descCtrl = TextEditingController(text: ex?.description ?? '');
    _targetHoursCtrl = TextEditingController(
      text: ex != null && ex.targetMinutes > 0
          ? (ex.targetMinutes / 60.0).toStringAsFixed(0)
          : '',
    );
    _selectedCategory = ex?.category ?? widget.defaultCategory;
    if (ex?.deadline != null) {
      _selectedDeadline = DateTime.fromMillisecondsSinceEpoch(ex!.deadline!);
    }
    if (ex != null) {
      _milestoneTitles.addAll(ex.milestones.map((m) => m.title));
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _targetHoursCtrl.dispose();
    _newMsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    HapticFeedback.lightImpact();
    final initial =
        _selectedDeadline ?? DateTime.now().add(const Duration(days: 14));
    final picked = await AppDatePickerSheet.show(
      context,
      p: widget.p,
      title: 'Target Deadline',
      initialDateTime: initial,
      minimumDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDeadline = picked);
    }
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;

    final targetHours = double.tryParse(_targetHoursCtrl.text.trim()) ?? 0.0;
    final targetMins = (targetHours * 60).round();

    final now = DateTime.now().millisecondsSinceEpoch;
    final ex = widget.existing;

    final milestones = <ProjectMilestone>[];
    for (int i = 0; i < _milestoneTitles.length; i++) {
      final t = _milestoneTitles[i];
      // preserve existing milestone id/state if available
      if (ex != null && i < ex.milestones.length) {
        milestones.add(ex.milestones[i].copyWith(title: t));
      } else {
        milestones.add(ProjectMilestone(id: 'ms_${now}_$i', title: t));
      }
    }

    final project = Project(
      id: ex?.id ?? 'proj_$now',
      title: title,
      description: _descCtrl.text.trim(),
      category: _selectedCategory,
      targetMinutes: targetMins,
      deadline: _selectedDeadline?.millisecondsSinceEpoch,
      createdAt: ex?.createdAt ?? now,
      isCompleted: ex?.isCompleted ?? false,
      completedAt: ex?.completedAt,
      milestones: milestones,
      linkedGoalId: ex?.linkedGoalId,
    );

    HapticFeedback.mediumImpact();
    await ProjectService.instance.saveProject(project);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isEditing = widget.existing != null;

    return AppSheet(
      p: p,
      title: isEditing ? 'Edit Project' : 'New Project',
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + bottomInset),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title input
            Text(
              'TITLE',
              style: TextStyle(
                color: p.subtext,
                fontSize: 11,
                letterSpacing: 1.0,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: p.surface2,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: p.surface3.withAlpha(120)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: TextField(
                controller: _titleCtrl,
                style: TextStyle(color: p.text, fontSize: 15),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  hintText: 'e.g. Finish reading Clean Architecture',
                  hintStyle: TextStyle(
                    color: p.subtext.withAlpha(140),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Description input
            Text(
              'DESCRIPTION (OPTIONAL)',
              style: TextStyle(
                color: p.subtext,
                fontSize: 11,
                letterSpacing: 1.0,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: p.surface2,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: p.surface3.withAlpha(120)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: TextField(
                controller: _descCtrl,
                maxLines: 2,
                style: TextStyle(color: p.text, fontSize: 14),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  hintText: 'Brief notes on this initiative...',
                  hintStyle: TextStyle(
                    color: p.subtext.withAlpha(140),
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Target Hours & Deadline row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TARGET (HOURS)',
                        style: TextStyle(
                          color: p.subtext,
                          fontSize: 11,
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: p.surface2,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: p.surface3.withAlpha(120)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        alignment: Alignment.center,
                        child: TextField(
                          controller: _targetHoursCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          style: TextStyle(color: p.text, fontSize: 14),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            hintText: 'e.g. 15',
                            hintStyle: TextStyle(
                              color: p.subtext.withAlpha(140),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DEADLINE',
                        style: TextStyle(
                          color: p.subtext,
                          fontSize: 11,
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      PressableScale(
                        onTap: _pickDeadline,
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: p.surface2,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: p.surface3.withAlpha(120),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _selectedDeadline != null
                                ? '${_selectedDeadline!.day}/${_selectedDeadline!.month}/${_selectedDeadline!.year}'
                                : 'Select date',
                            style: TextStyle(
                              color: _selectedDeadline != null
                                  ? p.text
                                  : p.subtext,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Milestones setup
            Text(
              'MILESTONES / CHECKPOINTS',
              style: TextStyle(
                color: p.subtext,
                fontSize: 11,
                letterSpacing: 1.0,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            ..._milestoneTitles.asMap().entries.map((entry) {
              final idx = entry.key;
              final title = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: p.surface2,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 16,
                        color: p.accent,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: p.text,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(20, 20),
                        onPressed: () {
                          setState(() => _milestoneTitles.removeAt(idx));
                        },
                        child: Icon(
                          Icons.close_rounded,
                          size: 14,
                          color: p.subtext,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: p.surface2,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: p.surface3.withAlpha(120)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    child: TextField(
                      controller: _newMsCtrl,
                      style: TextStyle(color: p.text, fontSize: 13),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        hintText: 'e.g. Chapter 1, Section 2...',
                        hintStyle: TextStyle(
                          color: p.subtext.withAlpha(140),
                          fontSize: 13,
                        ),
                      ),
                      onSubmitted: (val) {
                        if (val.trim().isNotEmpty) {
                          setState(() {
                            _milestoneTitles.add(val.trim());
                            _newMsCtrl.clear();
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PressableScale(
                  onTap: () {
                    final val = _newMsCtrl.text.trim();
                    if (val.isNotEmpty) {
                      setState(() {
                        _milestoneTitles.add(val);
                        _newMsCtrl.clear();
                      });
                    }
                  },
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: p.surface3,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '+ Add',
                      style: TextStyle(
                        color: p.accent,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Save button
            PressableScale(
              onTap: _save,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: p.accent,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: p.accent.withAlpha(70),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  isEditing ? 'Save Changes' : 'Create Project',
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
