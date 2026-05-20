import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_card.dart';

class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.title, required this.value, required this.icon, this.subtitle});

  final String title;
  final String value;
  final IconData icon;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.sapBlue.withOpacity(.10), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: AppTheme.sapBlue),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.grey.shade700)),
                const SizedBox(height: 6),
                Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                if (subtitle != null) Text(subtitle!, style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
