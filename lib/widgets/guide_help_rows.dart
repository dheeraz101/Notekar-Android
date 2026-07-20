import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';

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
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: p.accent, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: p.text, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(
                  text,
                  style: TextStyle(color: p.text2, fontSize: 13, height: 1.35),
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
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        iconColor: p.accent,
        collapsedIconColor: p.text3,
        title: Text(
          question,
          style: TextStyle(
            color: p.text,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              answer,
              style: TextStyle(color: p.text2, fontSize: 13, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}
