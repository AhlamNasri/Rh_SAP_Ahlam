import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key});

  final String? status;

  Color get _color {
    final value = (status ?? '').toUpperCase();
    if (value.contains('APPROUVE') || value.contains('PAYE') || value.contains('PRESENT') || value.contains('VALIDEE') || value.contains('ACCEPTEE') || value.contains('TERMINEE')) {
      return AppTheme.success;
    }
    if (value.contains('ATTENTE') || value.contains('BROUILLON') || value.contains('RECUE') || value.contains('PLANIFIEE') || value.contains('EN_COURS') || value.contains('ENTRETIEN')) {
      return AppTheme.warning;
    }
    if (value.contains('REFUSE') || value.contains('ABSENT') || value.contains('FERMEE')) {
      return AppTheme.danger;
    }
    return AppTheme.sapBlue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: _color.withOpacity(.12), borderRadius: BorderRadius.circular(40)),
      child: Text(status ?? '-', style: TextStyle(color: _color, fontWeight: FontWeight.w700, fontSize: 12)),
    );
  }
}
