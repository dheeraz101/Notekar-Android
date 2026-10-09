import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/services/audio_service.dart';
import 'package:notekar/widgets/pressable_scale.dart';

/// Apple Voice Memos / iMessage style voice player pill for the history timeline.
class TimelineVoicePlayerPill extends StatefulWidget {
  const TimelineVoicePlayerPill({
    super.key,
    required this.p,
    required this.voicePath,
    this.durationMs,
    this.compact = false,
  });

  final Palette p;
  final String voicePath;
  final int? durationMs;
  final bool compact;

  @override
  State<TimelineVoicePlayerPill> createState() =>
      _TimelineVoicePlayerPillState();
}

class _TimelineVoicePlayerPillState extends State<TimelineVoicePlayerPill> {
  final AudioService _audioService = AudioService.instance;

  @override
  void initState() {
    super.initState();
    _audioService.addListener(_onAudioStateChanged);
  }

  @override
  void dispose() {
    _audioService.removeListener(_onAudioStateChanged);
    super.dispose();
  }

  void _onAudioStateChanged() {
    if (mounted) setState(() {});
  }

  bool get _isThisPlaying =>
      _audioService.currentPlayingPath == widget.voicePath &&
      _audioService.isPlaying;

  Duration get _totalDuration {
    if (_audioService.currentPlayingPath == widget.voicePath &&
        _audioService.totalDuration > Duration.zero) {
      return _audioService.totalDuration;
    }
    if (widget.durationMs != null && widget.durationMs! > 0) {
      return Duration(milliseconds: widget.durationMs!);
    }
    return const Duration(seconds: 12);
  }

  Duration get _currentPosition {
    if (_audioService.currentPlayingPath == widget.voicePath) {
      return _audioService.currentPosition;
    }
    return Duration.zero;
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '${m.toString().padLeft(1, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _togglePlayPause() {
    HapticFeedback.selectionClick();
    if (_isThisPlaying) {
      _audioService.pause();
    } else {
      _audioService.play(
        widget.voicePath,
        speed: _audioService.playbackSpeed,
        fallbackDuration: widget.durationMs != null
            ? Duration(milliseconds: widget.durationMs!)
            : null,
      );
    }
  }

  void _cycleSpeed() {
    HapticFeedback.selectionClick();
    _audioService.cyclePlaybackSpeed();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final isCompact = widget.compact;
    final total = _totalDuration;
    final pos = _currentPosition;
    final progress = total.inMilliseconds > 0
        ? (pos.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Padding(
      padding: const EdgeInsets.only(top: 6.0, bottom: 2.0),
      child: Container(
        width: double.infinity,
        height: isCompact ? 38 : 44,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: p.surface3.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: p.border.withValues(alpha: 0.6),
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            // Play / Pause Circle Button
            PressableScale(
              onTap: _togglePlayPause,
              child: Container(
                width: isCompact ? 28 : 32,
                height: isCompact ? 28 : 32,
                decoration: BoxDecoration(
                  color: p.accent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    _isThisPlaying
                        ? CupertinoIcons.pause_fill
                        : CupertinoIcons.play_fill,
                    size: isCompact ? 13 : 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Waveform Scrubber
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragUpdate: (details) {
                  final box = context.findRenderObject() as RenderBox?;
                  if (box != null && total > Duration.zero) {
                    final localX = details.localPosition.dx;
                    final ratio = (localX / box.size.width).clamp(0.0, 1.0);
                    final targetMs = (ratio * total.inMilliseconds).toInt();
                    _audioService.seek(Duration(milliseconds: targetMs));
                  }
                },
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const barCount = 20;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: List.generate(barCount, (index) {
                        final barRatio = (index + 1) / barCount;
                        final isFilled = barRatio <= progress;
                        final heights = [
                          10.0,
                          16.0,
                          22.0,
                          14.0,
                          18.0,
                          24.0,
                          12.0,
                          20.0,
                          16.0,
                          22.0,
                        ];
                        final h =
                            heights[index % heights.length] *
                            (isCompact ? 0.72 : 0.88);

                        return Container(
                          width: 2.6,
                          height: h,
                          decoration: BoxDecoration(
                            color: isFilled
                                ? p.accent
                                : p.text3.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Time indicator: 0:14 / 0:42
            Text(
              '${_formatDuration(pos)} / ${_formatDuration(total)}',
              style: TextStyle(
                color: p.text2,
                fontSize: isCompact ? 10.5 : 11.5,
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: 8),

            // Speed multiplier pill
            PressableScale(
              onTap: _cycleSpeed,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2.5,
                ),
                decoration: BoxDecoration(
                  color: p.surface2,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: p.border.withValues(alpha: 0.5),
                    width: 0.6,
                  ),
                ),
                child: Text(
                  '${_audioService.playbackSpeed.toStringAsFixed(1)}x',
                  style: TextStyle(
                    color: p.accent,
                    fontSize: 10,
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
