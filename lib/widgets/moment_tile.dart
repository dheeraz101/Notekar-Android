import 'package:flutter/material.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';

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
  });

  final Palette p;
  final Moment entry;
  final bool selected;
  final bool compact;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final color = entry.type == 'out'
        ? p.orange
        : entry.type == 'single'
        ? p.accent
        : p.green;
    if (compact) {
      return GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
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
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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
                  child: Text(
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
                  width: 18,
                  height: 18,
                ),
                padding: EdgeInsets.zero,
                onPressed: onDelete,
                icon: Icon(Icons.close_rounded, color: p.text3, size: 12),
              ),
            ],
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
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
              child: entry.type == 'single'
                  ? Icon(
                      Icons.arrow_upward_rounded,
                      color: color,
                      size: compact ? 16 : 18,
                    )
                  : Text(
                      entry.type.toUpperCase(),
                      style: TextStyle(
                        color: color,
                        fontSize: compact ? 10 : 11,
                        fontWeight: FontWeight.w900,
                      ),
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
                    ),
                  ),
                  if (!compact || entry.note.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
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
              onPressed: onDelete,
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
