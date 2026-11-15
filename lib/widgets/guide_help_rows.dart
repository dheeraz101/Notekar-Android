import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/l10n_utils.dart';

class GuideRow extends StatelessWidget {
  const GuideRow({
    super.key,
    required this.p,
    required this.icon,
    required this.title,
    required this.text,
  });

  final Palette p;
  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: p.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: p.accent, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.localized(context),
                  style: TextStyle(
                    color: p.text,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  text.localized(context),
                  style: TextStyle(color: p.text2, fontSize: 13, height: 1.38),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HelpRow extends StatelessWidget {
  const HelpRow({
    super.key,
    required this.p,
    required this.question,
    required this.answer,
  });

  final Palette p;
  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
      ),
      child: Material(
        color: Colors.transparent,
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          iconColor: p.accent,
          collapsedIconColor: p.text3,
          leading: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: p.surface3,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(CupertinoIcons.question, size: 14, color: p.text2),
            ),
          ),
          title: Text(
            question.localized(context),
            style: TextStyle(
              color: p.text,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 40),
                child: Text(
                  answer.localized(context),
                  style: TextStyle(color: p.text2, fontSize: 13, height: 1.45),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
