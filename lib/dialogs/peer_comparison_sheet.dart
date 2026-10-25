import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/models/peer_profile.dart';
import 'package:notekar/services/peer_profile_service.dart';
import 'package:notekar/services/user_profile_service.dart';
import 'package:notekar/widgets/design_system/nk_button.dart';

/// Modal bottom sheet providing deep side-by-side temporal horizon comparison.
class PeerComparisonSheet extends StatefulWidget {
  const PeerComparisonSheet({
    super.key,
    required this.p,
    required this.peer,
    this.onPeerRemoved,
  });

  final Palette p;
  final PeerProfile peer;
  final VoidCallback? onPeerRemoved;

  static Future<void> show(
    BuildContext context, {
    required Palette p,
    required PeerProfile peer,
    VoidCallback? onPeerRemoved,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          PeerComparisonSheet(p: p, peer: peer, onPeerRemoved: onPeerRemoved),
    );
  }

  @override
  State<PeerComparisonSheet> createState() => _PeerComparisonSheetState();
}

class _PeerComparisonSheetState extends State<PeerComparisonSheet> {
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _checkSaved();
  }

  Future<void> _checkSaved() async {
    final saved = await PeerProfileService.instance.getSavedPeerProfile();
    if (saved != null &&
        saved.name == widget.peer.name &&
        saved.timestamp == widget.peer.timestamp) {
      if (mounted) setState(() => _isSaved = true);
    }
  }

  Future<void> _removePeer() async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Remove Peer Profile?'),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            'Remove "${widget.peer.name}" from your saved comparison profiles?',
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await PeerProfileService.instance.clearPeerProfile();
      HapticFeedback.mediumImpact();
      widget.onPeerRemoved?.call();
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final peer = widget.peer;
    final myProfile = UserProfileService();
    final myHorizon = myProfile.calculateLifeHorizon();
    final myName = myProfile.name.trim().isNotEmpty
        ? myProfile.name.trim()
        : 'Me';

    final myLivedPct = (myHorizon.livedPercentage * 100).toStringAsFixed(1);
    final peerLivedPct = (peer.livedPercentage * 100).toStringAsFixed(1);
    final weeksDelta = myHorizon.remainingWeeks - peer.remainingWeeks;

    return AppSheet(
      p: p,
      title: 'Horizon Comparison',
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Dual Comparison Bar Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: p.surface2,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: p.border),
              ),
              child: Row(
                children: [
                  // My Avatar
                  Expanded(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: p.accent.withValues(alpha: 0.2),
                          child: Text(
                            myName.substring(0, 1).toUpperCase(),
                            style: TextStyle(
                              color: p.accent,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          myName,
                          style: TextStyle(
                            color: p.text,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${myHorizon.ageYears}y / ${myHorizon.targetYears}y',
                          style: TextStyle(color: p.text3, fontSize: 11),
                        ),
                      ],
                    ),
                  ),

                  // Center VS Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: p.surface3,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'VS',
                      style: TextStyle(
                        color: p.text3,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  // Peer Avatar
                  Expanded(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: p.orange.withValues(alpha: 0.2),
                          child: Text(
                            peer.name.substring(0, 1).toUpperCase(),
                            style: TextStyle(
                              color: p.orange,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          peer.name,
                          style: TextStyle(
                            color: p.text,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${peer.ageYears.toStringAsFixed(1)}y / ${peer.targetYears}y',
                          style: TextStyle(color: p.text3, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. 24-Hour Life Clock Comparison
            _buildMetricCard(
              p: p,
              title: '24-HOUR LIFE CLOCK',
              icon: CupertinoIcons.clock_fill,
              myVal: myHorizon.lifeClockFormatted,
              peerVal: peer.lifeClockFormatted,
              mySub: myHorizon.lifeClockTimeOfDay,
              peerSub: peer.lifeClockTimeOfDay,
              highlightColor: p.accent,
            ),
            const SizedBox(height: 12),

            // 3. Waking Weeks Ahead
            _buildMetricCard(
              p: p,
              title: 'WAKING WEEKS REMAINING',
              icon: CupertinoIcons.calendar_today,
              myVal: '${myHorizon.remainingWeeks} wks',
              peerVal: '${peer.remainingWeeks} wks',
              mySub: weeksDelta >= 0 ? '+${weeksDelta.abs()} wks' : '',
              peerSub: weeksDelta < 0 ? '+${weeksDelta.abs()} wks' : '',
              highlightColor: p.orange,
            ),
            const SizedBox(height: 12),

            // 4. Conscious Lived Percentage
            _buildMetricCard(
              p: p,
              title: 'CONSCIOUS LIFE LIVED',
              icon: CupertinoIcons.hourglass,
              myVal: '$myLivedPct%',
              peerVal: '$peerLivedPct%',
              mySub: 'Target ${myHorizon.targetYears}y',
              peerSub: 'Target ${peer.targetYears}y',
              highlightColor: p.green,
            ),
            const SizedBox(height: 16),

            // 5. Dual Progress Bar Visualizer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: p.surface2,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: p.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PROGRESS SPECTRUM',
                    style: TextStyle(
                      color: p.text3,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // My Progress
                  Row(
                    children: [
                      SizedBox(
                        width: 55,
                        child: Text(
                          myName,
                          style: TextStyle(
                            color: p.text,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            height: 7,
                            color: p.surface3,
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: myHorizon.livedPercentage.clamp(
                                0.01,
                                1.0,
                              ),
                              child: Container(color: p.accent),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$myLivedPct%',
                        style: TextStyle(
                          color: p.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Peer Progress
                  Row(
                    children: [
                      SizedBox(
                        width: 55,
                        child: Text(
                          peer.name,
                          style: TextStyle(
                            color: p.text,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            height: 7,
                            color: p.surface3,
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: peer.livedPercentage.clamp(
                                0.01,
                                1.0,
                              ),
                              child: Container(color: p.orange),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$peerLivedPct%',
                        style: TextStyle(
                          color: p.orange,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Bottom Actions
            Row(
              children: [
                Expanded(
                  child: NkButton.primary(
                    p: p,
                    label: 'Done',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                if (_isSaved) ...[
                  const SizedBox(width: 12),
                  NkButton.destructive(
                    p: p,
                    label: 'Remove Peer',
                    icon: CupertinoIcons.trash,
                    onPressed: _removePeer,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required Palette p,
    required String title,
    required IconData icon,
    required String myVal,
    required String peerVal,
    required String mySub,
    required String peerSub,
    required Color highlightColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: highlightColor, size: 14),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: p.text3,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // My Metric
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    myVal,
                    style: TextStyle(
                      color: p.text,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (mySub.isNotEmpty)
                    Text(
                      mySub,
                      style: TextStyle(
                        color: highlightColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
              Icon(
                CupertinoIcons.chevron_left_2,
                color: p.text3.withValues(alpha: 0.4),
                size: 14,
              ),
              // Peer Metric
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    peerVal,
                    style: TextStyle(
                      color: p.text,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (peerSub.isNotEmpty)
                    Text(
                      peerSub,
                      style: TextStyle(
                        color: p.orange,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
