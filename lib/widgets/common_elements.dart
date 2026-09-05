import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/glass.dart';
import 'package:notekar/widgets/pressable_scale.dart';

class ChipButton extends StatelessWidget {
  const ChipButton({
    super.key,
    required this.p,
    this.label,
    this.icon,
    this.semanticLabel,
    required this.active,
    required this.onTap,
    this.onLongPress,
  });

  final Palette p;
  final String? label;
  final IconData? icon;
  final String? semanticLabel;
  final bool active;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final hasLabel = label != null && label!.isNotEmpty;
    final hasIcon = icon != null;

    return PressableScale(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: (hasIcon && !hasLabel) ? 11 : 14,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: active ? p.surface3 : p.surface2,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: active ? p.accent : p.border),
          boxShadow: active ? selectedGlow(p.accent) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasIcon) ...[
              Icon(
                icon,
                color: active ? p.text : p.text2,
                size: 16,
                semanticLabel: semanticLabel,
              ),
              if (hasLabel) const SizedBox(width: 6),
            ],
            if (hasLabel)
              Text(
                label!.localized(context),
                style: TextStyle(
                  color: active ? p.text : p.text2,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel({super.key, required this.p, required this.text});

  final Palette p;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        spacing8,
        spacing24,
        spacing8,
        spacing8,
      ),
      child: Text(
        text.localized(context),
        style: TextStyle(
          color: p.text3,
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class HighlightedText extends StatelessWidget {
  const HighlightedText({
    super.key,
    required this.text,
    required this.query,
    required this.baseStyle,
    required this.highlightStyle,
  });

  final String text;
  final String? query;
  final TextStyle baseStyle;
  final TextStyle highlightStyle;

  @override
  Widget build(BuildContext context) {
    final q = query?.trim();
    if (q == null || q.isEmpty) {
      return Text(text, style: baseStyle);
    }
    final lower = text.toLowerCase();
    final index = lower.indexOf(q.toLowerCase());
    if (index < 0) return Text(text, style: baseStyle);
    return RichText(
      text: TextSpan(
        style: baseStyle,
        children: [
          TextSpan(text: text.substring(0, index)),
          TextSpan(
            text: text.substring(index, index + q.length),
            style: highlightStyle,
          ),
          TextSpan(text: text.substring(index + q.length)),
        ],
      ),
    );
  }
}

class SettingsStatusPill extends StatelessWidget {
  const SettingsStatusPill({
    super.key,
    required this.p,
    required this.label,
    required this.color,
  });

  final Palette p;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final String cleanLabel = label.trim().toUpperCase();
    IconData? typeIcon;
    if (cleanLabel == 'IN') {
      typeIcon = Icons.south_west_rounded;
    } else if (cleanLabel == 'OUT') {
      typeIcon = Icons.north_east_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (typeIcon != null) ...[
            Icon(typeIcon, color: color, size: 12),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsPageNote extends StatelessWidget {
  const SettingsPageNote({super.key, required this.p, required this.text});

  final Palette p;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Icon(
              Icons.info_outline_rounded,
              color: p.text3.withValues(alpha: 0.6),
              size: 13,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: p.text3,
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.05,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DiagnosticRow extends StatelessWidget {
  const DiagnosticRow({
    super.key,
    required this.p,
    required this.label,
    required this.value,
  });

  final Palette p;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      padding: const EdgeInsets.symmetric(
        horizontal: spacing16,
        vertical: spacing12,
      ),
      child: Align(
        alignment: Alignment.center,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 4,
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: p.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
            ),
            const SizedBox(width: spacing12),
            Expanded(
              flex: 5,
              child: Text(
                value,
                textAlign: TextAlign.right,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: p.text2, fontSize: 13, height: 1.25),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HIGEmptyState extends StatelessWidget {
  const HIGEmptyState({
    super.key,
    required this.p,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  });

  final Palette p;
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: compact ? 32 : 44),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: compact ? 56 : 72,
              color: p.text3.withValues(alpha: 0.25),
            ),
            SizedBox(height: compact ? 16 : 24),
            Text(
              title.localized(context),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: p.text,
                fontSize: compact ? 18 : 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message.localized(context),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: p.text3,
                fontSize: compact ? 14 : 15,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: compact ? 20 : 28),
              FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: p.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: Text(
                  actionLabel!.localized(context),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SliverStickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  SliverStickyHeaderDelegate({required this.child, required this.height});

  final Widget child;
  final double height;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant SliverStickyHeaderDelegate oldDelegate) {
    return oldDelegate.child != child || oldDelegate.height != height;
  }
}

class HIGShimmerLoader extends StatefulWidget {
  const HIGShimmerLoader({
    super.key,
    required this.p,
    this.height = 60,
    this.count = 3,
    this.radius = 24,
  });

  final Palette p;
  final double height;
  final int count;
  final double radius;

  @override
  State<HIGShimmerLoader> createState() => _HIGShimmerLoaderState();
}

class _HIGShimmerLoaderState extends State<HIGShimmerLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.20,
      end: 0.55,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Column(
          children: [
            for (int i = 0; i < widget.count; i++) ...[
              Container(
                height: widget.height,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: widget.p.surface3.withValues(alpha: _animation.value),
                  borderRadius: BorderRadius.circular(widget.radius),
                  border: Border.all(
                    color: widget.p.border.withValues(alpha: 0.3),
                  ),
                ),
              ),
              if (i < widget.count - 1) const SizedBox(height: 10),
            ],
          ],
        );
      },
    );
  }
}

/// Shows an Apple iOS-style Dynamic Pill Toast Notification floating at the top of the screen.
void showIosPillToast({
  required BuildContext context,
  required Palette p,
  required String message,
  IconData icon = Icons.check_circle_rounded,
  Duration duration = const Duration(milliseconds: 2000),
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  late final OverlayEntry entry;

  entry = OverlayEntry(
    builder: (context) {
      return _IosPillToastWidget(
        p: p,
        message: message,
        icon: icon,
        onDismiss: () => entry.remove(),
        duration: duration,
      );
    },
  );

  overlay.insert(entry);
}

class _IosPillToastWidget extends StatefulWidget {
  const _IosPillToastWidget({
    required this.p,
    required this.message,
    required this.icon,
    required this.onDismiss,
    required this.duration,
  });

  final Palette p;
  final String message;
  final IconData icon;
  final VoidCallback onDismiss;
  final Duration duration;

  @override
  State<_IosPillToastWidget> createState() => _IosPillToastWidgetState();
}

class _IosPillToastWidgetState extends State<_IosPillToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      reverseDuration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    Future.delayed(widget.duration, () async {
      if (mounted) {
        await _controller.reverse();
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final p = widget.p;

    return Positioned(
      top: topInset + 12,
      left: 20,
      right: 20,
      child: IgnorePointer(
        child: Material(
          color: Colors.transparent,
          child: Align(
            alignment: Alignment.topCenter,
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: p.name == 'amoled'
                          ? Colors.black
                          : (p.name == 'light'
                                ? const Color(0xF01C1C1E)
                                : p.surface2),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 0.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(widget.icon, color: p.accent, size: 18),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            widget.message,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 52+ worldwide target languages planned for community translation.
const List<({String code, String name, String native})> kUpcomingLanguages = [
  (code: 'ar', name: 'Arabic', native: 'العربية (Arabic)'),
  (code: 'pt', name: 'Portuguese', native: 'Português (Portuguese)'),
  (code: 'it', name: 'Italian', native: 'Italiano (Italian)'),
  (
    code: 'zh-CN',
    name: 'Chinese (Simplified)',
    native: '简体中文 (Chinese Simplified)',
  ),
  (
    code: 'zh-TW',
    name: 'Chinese (Traditional)',
    native: '繁體中文 (Chinese Traditional)',
  ),
  (code: 'ko', name: 'Korean', native: '한국어 (Korean)'),
  (code: 'tr', name: 'Turkish', native: 'Türkçe (Turkish)'),
  (code: 'nl', name: 'Dutch', native: 'Nederlands (Dutch)'),
  (code: 'pl', name: 'Polish', native: 'Polski (Polish)'),
  (code: 'sv', name: 'Swedish', native: 'Svenska (Swedish)'),
  (code: 'id', name: 'Indonesian', native: 'Bahasa Indonesia'),
  (code: 'vi', name: 'Vietnamese', native: 'Tiếng Việt (Vietnamese)'),
  (code: 'th', name: 'Thai', native: 'ไทย (Thai)'),
  (code: 'uk', name: 'Ukrainian', native: 'Українська (Ukrainian)'),
  (code: 'el', name: 'Greek', native: 'Ελληνικά (Greek)'),
  (code: 'cs', name: 'Czech', native: 'Čeština (Czech)'),
  (code: 'ro', name: 'Romanian', native: 'Română (Romanian)'),
  (code: 'hu', name: 'Hungarian', native: 'Magyar (Hungarian)'),
  (code: 'da', name: 'Danish', native: 'Dansk (Danish)'),
  (code: 'fi', name: 'Finnish', native: 'Suomi (Finnish)'),
  (code: 'no', name: 'Norwegian', native: 'Norsk (Norwegian)'),
  (code: 'he', name: 'Hebrew', native: 'עברית (Hebrew)'),
  (code: 'bn', name: 'Bengali', native: 'বাংলা (Bengali)'),
  (code: 'mr', name: 'Marathi', native: 'मराठी (Marathi)'),
  (code: 'te', name: 'Telugu', native: 'తెలుగు (Telugu)'),
  (code: 'ta', name: 'Tamil', native: 'தமிழ் (Tamil)'),
  (code: 'gu', name: 'Gujarati', native: 'ગુજરાતી (Gujarati)'),
  (code: 'ur', name: 'Urdu', native: 'اردو (Urdu)'),
  (code: 'kn', name: 'Kannada', native: 'ಕನ್ನಡ (Kannada)'),
  (code: 'ml', name: 'Malayalam', native: 'മലയാളം (Malayalam)'),
  (code: 'pa', name: 'Punjabi', native: 'ਪੰਜਾਬੀ (Punjabi)'),
  (code: 'sw', name: 'Swahili', native: 'Kiswahili (Swahili)'),
  (code: 'fa', name: 'Persian', native: 'فارسی (Persian)'),
  (code: 'ms', name: 'Malay', native: 'Bahasa Melayu'),
  (code: 'tl', name: 'Tagalog', native: 'Filipino (Tagalog)'),
  (code: 'sk', name: 'Slovak', native: 'Slovenčina (Slovak)'),
  (code: 'bg', name: 'Bulgarian', native: 'Български (Bulgarian)'),
  (code: 'hr', name: 'Croatian', native: 'Hrvatski (Croatian)'),
  (code: 'sr', name: 'Serbian', native: 'Српски (Serbian)'),
  (code: 'lt', name: 'Lithuanian', native: 'Lietuvių (Lithuanian)'),
  (code: 'sl', name: 'Slovenian', native: 'Slovenščina (Slovenian)'),
  (code: 'lv', name: 'Latvian', native: 'Latviešu (Latvian)'),
  (code: 'et', name: 'Estonian', native: 'Eesti (Estonian)'),
  (code: 'eu', name: 'Basque', native: 'Euskara (Basque)'),
  (code: 'ca', name: 'Catalan', native: 'Català (Catalan)'),
  (code: 'cy', name: 'Welsh', native: 'Cymraeg (Welsh)'),
  (code: 'ga', name: 'Irish', native: 'Gaeilge (Irish)'),
  (code: 'is', name: 'Icelandic', native: 'Íslenska (Icelandic)'),
  (code: 'sq', name: 'Albanian', native: 'Shqip (Albanian)'),
  (code: 'mk', name: 'Macedonian', native: 'Македонски (Macedonian)'),
  (code: 'hy', name: 'Armenian', native: 'Հայերեն (Armenian)'),
  (code: 'ka', name: 'Georgian', native: 'ქართული (Georgian)'),
];

/// Shows a sleek Apple-style bottom sheet informing the user that translation for [languageName]
/// is upcoming, inviting community contributions on GitHub.
Future<void> showUpcomingLanguageNotice(
  BuildContext context,
  Palette p,
  String languageName, {
  void Function(String url)? onOpenLink,
}) async {
  HapticFeedback.selectionClick();
  const translationsGuideUrl =
      'https://github.com/dheeraz101/Notekar-Android/blob/main/TRANSLATIONS.md';
  const MethodChannel fileChannel = MethodChannel(
    'com.project.yabp.notekar/files',
  );

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    isScrollControlled: true,
    builder: (ctx) {
      return Container(
        decoration: BoxDecoration(
          color: p.surface.withValues(alpha: 0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(
            color: p.accent.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: Glass(
            p: p,
            radius: 32,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: p.text3.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: p.accent.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: p.accent.withValues(alpha: 0.25),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.translate_rounded,
                    color: p.accent,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  languageName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: p.text,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: p.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: p.orange.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Upcoming'.localized(context),
                    style: TextStyle(
                      color: p.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'This language is currently under development. You can help translate NoteKar into your native language by contributing on GitHub.'
                      .localized(context),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: p.text2, fontSize: 14, height: 1.45),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: PressableScale(
                        onTap: () async {
                          Navigator.pop(ctx);
                          if (onOpenLink != null) {
                            onOpenLink(translationsGuideUrl);
                          } else {
                            try {
                              await fileChannel.invokeMethod<void>('openUrl', {
                                'url': translationsGuideUrl,
                              });
                            } catch (_) {
                              await Clipboard.setData(
                                const ClipboardData(text: translationsGuideUrl),
                              );
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: p.accent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.favorite_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Contribute on GitHub'.localized(context),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'Dismiss'.localized(context),
                    style: TextStyle(
                      color: p.text3,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// A pill badge widget indicating 'Upcoming' status for non-live languages.
class UpcomingBadge extends StatelessWidget {
  const UpcomingBadge({super.key, required this.p});

  final Palette p;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: p.orange.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: p.orange.withValues(alpha: 0.28), width: 0.8),
      ),
      child: Text(
        'Upcoming'.localized(context),
        style: TextStyle(
          color: p.orange,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
