import 'package:flutter/cupertino.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/settings_widgets.dart';

/// Dedicated Apple HIG Settings Page presenting NoteKar's product roadmap
/// and upcoming architectural innovations for conscious timekeepers and chronometer purists.
class UpcomingFeaturesSettingsPage extends StatelessWidget {
  const UpcomingFeaturesSettingsPage({super.key, required this.p});

  final Palette p;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: spacing8),

        // Hero Philosophy Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: p.surface2,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: p.border.withValues(alpha: 0.6)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: p.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(CupertinoIcons.sparkles, color: p.accent, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Roadmap & Upcoming'.localized(context),
                      style: TextStyle(
                        color: p.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Our architectural pipeline for sovereign chronometer craft, edge intelligence, and uncompromising offline privacy.'
                          .localized(context),
                      style: TextStyle(
                        color: p.text2,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: spacing16),

        // 1. Voice & Edge Intelligence
        SettingsGroup(
          p: p,
          title: 'AUDIO & EDGE INTELLIGENCE'.localized(context),
          insetDividers: true,
          children: [
            _RoadmapCard(
              p: p,
              icon: CupertinoIcons.mic_fill,
              color: p.accent,
              title: 'Multi-Language Hands-Free Voice Notes',
              tag: 'Q4 2026',
              tagColor: p.accent,
              description:
                  '100% offline, on-device neural speech-to-text powered by edge Whisper. Dictate notes hands-free during commutes, walks, or workouts with automatic punctuation and hashtag extraction.',
              bulletPoints: const [
                '7 Live Localized Languages: English, Hindi, Spanish, French, German, Japanese, and Russian.',
                'Zero audio uploaded to cloud servers; 100% private local neural weights.',
                'Instant tag parsing (#deepwork, #reading) from transcribed speech.',
              ],
            ),
            _RoadmapCard(
              p: p,
              icon: CupertinoIcons.waveform_path_ecg,
              color: p.green,
              title: 'AI Temporal Synthesis & Circadian Narrative',
              tag: 'IN DEVELOPMENT',
              tagColor: p.green,
              description:
                  'On-device local LLM synthesizing daily and weekly intentionality ratios, identifying circadian peak focus hours, and confronting subconscious time leaks.',
              bulletPoints: const [
                'Contextual daily narrative: "The Story of Your Time" generated privately.',
                'Circadian flow state detection and chronotype alignment recommendations.',
                'Mathematical confrontation with the unaccounted Void without moral judgment.',
              ],
            ),
          ],
        ),

        const SizedBox(height: spacing16),

        // 2. System UI & Interactive Widgets
        SettingsGroup(
          p: p,
          title: 'SYSTEM EXTENSIONS & WIDGETS'.localized(context),
          insetDividers: true,
          children: [
            _RoadmapCard(
              p: p,
              icon: CupertinoIcons.bell_fill,
              color: const Color(0xFFFF9500),
              // iOS Orange
              title: 'Dynamic Live Activities & Interactive Lockscreen',
              tag: 'PLANNED',
              tagColor: const Color(0xFFFF9500),
              description:
                  'Real-time chronometer ticker in persistent notification with dynamic actions to pause, resume, change modes, or log tags directly without unlocking.',
              bulletPoints: const [
                'Live session duration ticker synchronized with hardware clock.',
                '1-tap mode swapping (Work, Deep Focus, Study) directly from lockscreen.',
                'Interactive quick tag pills right inside the notification panel.',
              ],
            ),
            _RoadmapCard(
              p: p,
              icon: CupertinoIcons.square_grid_2x2_fill,
              color: p.accent,
              title: 'Micro-Chrono Interactive Widgets (2x2 & 4x2)',
              tag: 'PLANNED',
              tagColor: p.accent,
              description:
                  'Next-generation Android App Widgets featuring real-time session elapsed tickers, circular day-progress gauge arcs, and instant mode-switching controls.',
              bulletPoints: const [
                'Live circular 24h Intentionality gauge reflecting waking hours utilized.',
                'Tactile one-touch IN/OUT transitions with immediate RemoteViews feedback.',
                'Sobriety streak progress bar with daily milestone celebration states.',
              ],
            ),
          ],
        ),

        const SizedBox(height: spacing16),

        // 3. Sovereignty & Knowledge Graphs
        SettingsGroup(
          p: p,
          title: 'SOVEREIGNTY & ANALYTICS'.localized(context),
          insetDividers: true,
          children: [
            _RoadmapCard(
              p: p,
              icon: CupertinoIcons.arrow_2_circlepath_circle_fill,
              color: const Color(0xFF5856D6),
              // iOS Purple
              title: 'Sovereign Peer-to-Peer LAN Sync',
              tag: 'RESEARCH',
              tagColor: const Color(0xFF5856D6),
              description:
                  'Zero-cloud peer-to-peer encrypted synchronization over local Wi-Fi / QR handshake. Seamlessly sync moments with Desktop (macOS, Windows, Linux) and Wear OS companion without accounts.',
              bulletPoints: const [
                'End-to-end encrypted TLS local socket transmission.',
                'Zero user accounts, telephone numbers, or cloud databases required.',
                'Conflict-free Replicated Data Type (CRDT) merge algorithms.',
              ],
            ),
            _RoadmapCard(
              p: p,
              icon: CupertinoIcons.circle_grid_hex_fill,
              color: const Color(0xFFFF2D55),
              // iOS Pink
              title: 'Chrono-Tag Association Matrix & Graph',
              tag: 'CONCEPT',
              tagColor: const Color(0xFFFF2D55),
              description:
                  'Visual network graph mapping nonlinear correlations between focus modes, custom hashtags, and times of day to uncover hidden habit patterns.',
              bulletPoints: const [
                'Interactive node graph showing which habits occur together.',
                'Heatmap correlations between mood/energy tags and focus duration.',
                'Exportable temporal vector embeddings for local graph visualization.',
              ],
            ),
          ],
        ),

        const SizedBox(height: spacing24),

        // Colophon Note
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'All roadmap innovations adhere strictly to NoteKar\'s 100% offline sovereign manifesto. No feature will ever compromise local storage or require internet surveillance.'
                .localized(context),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: p.text3,
              fontSize: 12,
              height: 1.4,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),

        const SizedBox(height: spacing48),
      ],
    );
  }
}

class _RoadmapCard extends StatelessWidget {
  const _RoadmapCard({
    required this.p,
    required this.icon,
    required this.color,
    required this.title,
    required this.tag,
    required this.tagColor,
    required this.description,
    required this.bulletPoints,
  });

  final Palette p;
  final IconData icon;
  final Color color;
  final String title;
  final String tag;
  final Color tagColor;
  final String description;
  final List<String> bulletPoints;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: p.text,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: tagColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: tagColor.withValues(alpha: 0.35),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: tagColor,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: TextStyle(color: p.text2, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 10),
          for (final bullet in bulletPoints) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      bullet,
                      style: TextStyle(
                        color: p.text3,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
