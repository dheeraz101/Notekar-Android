import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/dialogs/peer_comparison_sheet.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/models/peer_profile.dart';
import 'package:notekar/services/peer_profile_service.dart';
import 'package:notekar/services/user_profile_service.dart';
import 'package:notekar/widgets/design_system/nk_button.dart';

/// Modal bottom sheet presenting a scanned NoteKar peer's temporal profile.
class PeerProfileDetailSheet extends StatefulWidget {
  const PeerProfileDetailSheet({
    super.key,
    required this.p,
    required this.peer,
    this.onSavedChanged,
  });

  final Palette p;
  final PeerProfile peer;
  final VoidCallback? onSavedChanged;

  static Future<void> show(
    BuildContext context, {
    required Palette p,
    required PeerProfile peer,
    VoidCallback? onSavedChanged,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PeerProfileDetailSheet(
        p: p,
        peer: peer,
        onSavedChanged: onSavedChanged,
      ),
    );
  }

  @override
  State<PeerProfileDetailSheet> createState() => _PeerProfileDetailSheetState();
}

class _PeerProfileDetailSheetState extends State<PeerProfileDetailSheet> {
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _checkSavedState();
  }

  Future<void> _checkSavedState() async {
    final saved = await PeerProfileService.instance.getSavedPeerProfile();
    if (saved != null &&
        saved.name == widget.peer.name &&
        saved.timestamp == widget.peer.timestamp) {
      if (mounted) setState(() => _isSaved = true);
    }
  }

  Future<void> _handleSaveOrReplace() async {
    final currentPeer = await PeerProfileService.instance.getSavedPeerProfile();

    if (currentPeer != null &&
        (currentPeer.name != widget.peer.name ||
            currentPeer.timestamp != widget.peer.timestamp)) {
      // Prompt user to replace or view only
      if (!mounted) return;
      final shouldReplace = await showCupertinoDialog<bool>(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Replace Saved Peer?'),
          content: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'You currently have "${currentPeer.name}" saved. NoteKar allows exactly one active peer profile at a time. Would you like to replace it with "${widget.peer.name}"?',
            ),
          ),
          actions: [
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('View Only'),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Replace'),
            ),
          ],
        ),
      );

      if (shouldReplace == true) {
        await PeerProfileService.instance.savePeerProfile(widget.peer);
        HapticFeedback.heavyImpact();
        if (mounted) {
          setState(() => _isSaved = true);
          widget.onSavedChanged?.call();
        }
      }
      return;
    }

    // Direct save if no conflict
    await PeerProfileService.instance.savePeerProfile(widget.peer);
    HapticFeedback.heavyImpact();
    if (mounted) {
      setState(() => _isSaved = true);
      widget.onSavedChanged?.call();
    }
  }

  void _openComparison() {
    HapticFeedback.selectionClick();
    Navigator.of(context).pop();
    PeerComparisonSheet.show(
      context,
      p: widget.p,
      peer: widget.peer,
      onPeerRemoved: widget.onSavedChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final peer = widget.peer;
    final myProfile = UserProfileService();
    final myHorizon = myProfile.calculateLifeHorizon();

    final livedPct = (peer.livedPercentage * 100).toStringAsFixed(1);
    final myLivedPct = (myHorizon.livedPercentage * 100).toStringAsFixed(1);

    return AppSheet(
      p: p,
      title: 'Peer Horizon Pass',
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Peer Card Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E212D), Color(0xFF10121A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pass Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: p.accent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: p.accent.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.checkmark_shield_fill,
                                color: p.accent,
                                size: 11,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'VERIFIED HORIZON PASS',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: p.accent,
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        peer.lifeClockTimeOfDay.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Name & Horizon Target
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: p.accent.withValues(alpha: 0.25),
                        child: Text(
                          peer.name.isNotEmpty
                              ? peer.name.substring(0, 1).toUpperCase()
                              : 'E',
                          style: TextStyle(
                            color: p.accent,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              peer.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${peer.ageYears.toStringAsFixed(1)}y • ${peer.targetYears}y Life Horizon',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Big Life Clock Banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '24-HOUR LIFE CLOCK',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              peer.lifeClockFormatted,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'CONSCIOUS LIVED',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$livedPct%',
                              style: TextStyle(
                                color: p.orange,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Waking Weeks Pill
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'WAKING WEEKS AHEAD',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        '${peer.remainingWeeks} weeks',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Quick Comparison Preview Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: p.surface2,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: p.border),
              ),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.arrow_right_arrow_left_circle_fill,
                    color: p.accent,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your Life Clock is at ${myHorizon.lifeClockFormatted} ($myLivedPct% lived) vs ${peer.name} at ${peer.lifeClockFormatted} ($livedPct% lived).',
                      style: TextStyle(
                        color: p.text2,
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: NkButton.primary(
                    p: p,
                    label: 'Compare',
                    icon: CupertinoIcons.chart_pie_fill,
                    onPressed: _openComparison,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: NkButton.secondary(
                    p: p,
                    label: _isSaved ? 'Peer Saved' : 'Save Peer',
                    icon: _isSaved
                        ? CupertinoIcons.checkmark_alt
                        : CupertinoIcons.bookmark_fill,
                    onPressed: _isSaved ? null : _handleSaveOrReplace,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
