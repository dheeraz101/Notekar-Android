import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/widgets/glass.dart';

class AppSheet extends StatelessWidget {
  const AppSheet({
    super.key,
    required this.p,
    required this.title,
    required this.child,
    this.docked = false,
    this.blur = false,
    this.controller,
    this.showLargeTitle = false,
  });

  final Palette p;
  final String title;
  final Widget child;
  final bool docked;
  final bool blur;
  final ScrollController? controller;
  final bool showLargeTitle;

  @override
  Widget build(BuildContext context) {
    final content = GestureDetector(
      onVerticalDragEnd: (details) {
        if ((details.primaryVelocity ?? 0) > 650) {
          Navigator.maybePop(context);
        }
      },
      child: Glass(
        p: p,
        blur: blur,
        radius: docked ? 24 : 24,
        borderRadius: docked
            ? const BorderRadius.vertical(top: Radius.circular(24))
            : null,
        padding: const EdgeInsets.fromLTRB(spacing16, spacing8, spacing16, spacing16),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: docked ? 720 : 460),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 5,
                margin: const EdgeInsets.only(bottom: spacing8),
                decoration: BoxDecoration(
                  color: p.text3.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: p.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, size: 22),
                    color: p.text2,
                  ),
                ],
              ),
              const SizedBox(height: spacing8),
              child,
            ],
          ),
        ),
      ),
    );

    if (docked) {
      return Padding(
        padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top + 10),
        child: content,
      );
    }
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(spacing16),
      child: content,
    );
  }
}

class AppSheetLargeTitle extends StatelessWidget {
  const AppSheetLargeTitle({
    super.key,
    required this.p,
    required this.title,
    this.extra,
    this.scrollController,
  });

  final Palette p;
  final String title;
  final Widget? extra;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: spacing16),
          child: Text(
            title,
            style: TextStyle(
              color: p.text,
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.4,
              fontFamily: 'Inter',
            ),
          ),
        ),
        if (extra != null) ...[
          extra!,
          const SizedBox(height: spacing16),
        ],
      ],
    );
  }
}
