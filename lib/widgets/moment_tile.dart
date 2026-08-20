import 'package:flutter/material.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/ios_emoji_text.dart';

class MomentTile extends StatelessWidget {
  const MomentTile({
    super.key,
    required this.p,
    required this.entry,
    required this.selected,
    required this.compact,
    required this.onTap,
    required this.onLongPress,
    required this.onDelete,
    this.singleNumber,
  });

  final Palette p;
  final Moment entry;
  final bool selected;
  final bool compact;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback onDelete;
  final String? singleNumber;

  @override
  Widget build(BuildContext context) {
    final color = momentColor(p, entry.type);
    if (compact) {
      return GestureDetector(
        onTap: () {
          AppHaptics.light();
          onTap?.call();
        },
        onLongPress: () {
          AppHaptics.medium();
          onLongPress?.call();
        },
        child: Container(
          constraints: const BoxConstraints(minHeight: 22),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: selected ? p.surface3 : p.surface2,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? p.text3.withValues(alpha: 0.32) : p.border,
            ),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4), // iOS Inset look
                child: entry.type == 'single' && singleNumber != null
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 0.5,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          singleNumber!.localizedDigits(context),
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w900,
                            fontSize: 9.5,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      )
                    : Container(
                        width: 8, // Prominent iOS HIG style
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
              ),
              const SizedBox(width: 8),
              Text(
                timeOnly(entry.timestamp),
                style: TextStyle(
                  color: p.text,
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              if (entry.note.isNotEmpty) ...[
                const SizedBox(width: 6),
                Expanded(
                  child: IosEmojiText(
                    entry.note,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: p.text2, fontSize: 9.5),
                  ),
                ),
              ] else
                const Spacer(),
              IconButton(
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints.tightFor(
                  width: 28,
                  height: 22,
                ),
                padding: EdgeInsets.zero,
                onPressed: () {
                  AppHaptics.medium();
                  onDelete();
                },
                icon: Icon(Icons.close_rounded, color: p.text3, size: 12),
              ),
            ],
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: () {
        AppHaptics.light();
        onTap?.call();
      },
      onLongPress: () {
        AppHaptics.medium();
        onLongPress?.call();
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 12,
          vertical: compact ? 6 : 12,
        ),
        decoration: BoxDecoration(
          color: selected ? p.surface3 : p.surface2,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? p.text3.withValues(alpha: 0.34) : p.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: compact ? 28 : 38,
              height: compact ? 28 : 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: entry.type == 'single' && singleNumber != null
                  ? Text(
                      singleNumber!.localizedDigits(context),
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w900,
                        fontSize: compact ? 12 : 14,
                        letterSpacing: -0.2,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    )
                  : Icon(
                      entry.type == 'in'
                          ? Icons.south_west_rounded
                          : (entry.type == 'out'
                                ? Icons.north_east_rounded
                                : Icons.bolt_rounded),
                      color: color,
                      size: compact ? 16 : 18,
                    ),
            ),
            SizedBox(width: compact ? 8 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    timeOnly(entry.timestamp),
                    style: TextStyle(
                      color: p.text,
                      fontWeight: FontWeight.w800,
                      fontSize: compact ? 13 : 15,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  if (!compact || entry.note.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    IosEmojiText(
                      '${datePretty(entry.timestamp)}'
                      '${entry.note.isEmpty ? '' : ' - ${entry.note}'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: p.text2, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              visualDensity: compact
                  ? VisualDensity.compact
                  : VisualDensity.standard,
              constraints: BoxConstraints.tightFor(
                width: compact ? 32 : 40,
                height: compact ? 32 : 40,
              ),
              padding: EdgeInsets.zero,
              onPressed: () {
                AppHaptics.medium();
                onDelete();
              },
              icon: Icon(
                Icons.close_rounded,
                color: p.text3,
                size: compact ? 18 : 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
