import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/section_title.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../data/services/attendance_service.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  late Future<_AttendanceData> _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future = _load();
  }

  Future<_AttendanceData> _load() async {
    final service = AttendanceService(context.read<ApiClient>());
    final today = await service.today();
    final history = await service.my();
    return _AttendanceData(today, history);
  }

  void _refresh() => setState(() => _future = _load());

  Future<void> _action(bool checkIn) async {
    final service = AttendanceService(context.read<ApiClient>());
    try {
      checkIn ? await service.checkIn() : await service.checkOut();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(checkIn ? 'Entree pointee' : 'Sortie pointee')));
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_AttendanceData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) return const LoadingWidget();
        if (snapshot.hasError) return ErrorView(message: snapshot.error.toString(), onRetry: _refresh);
        final data = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle('Pointage / Presences', subtitle: 'Pointage entree/sortie avec controle metier cote API.'),
            const SizedBox(height: 18),
            AppCard(
              child: Row(
                children: [
                  const Icon(Icons.today_outlined, size: 42),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Statut du jour', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            StatusBadge(data.today['status']?.toString()),
                            Chip(label: Text('Entree: ${data.today['checkInTime'] ?? '-'}')),
                            Chip(label: Text('Sortie: ${data.today['checkOutTime'] ?? '-'}')),
                            Chip(label: Text('Heures: ${data.today['totalHours'] ?? '0'}')),
                          ],
                        ),
                      ],
                    ),
                  ),
                  AppButton(label: 'Pointer entree', icon: Icons.login, onPressed: () => _action(true)),
                  const SizedBox(width: 8),
                  AppButton(label: 'Pointer sortie', icon: Icons.logout, outlined: true, onPressed: () => _action(false)),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text('Historique', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            if (data.history.isEmpty)
              const EmptyStateWidget(title: 'Aucun pointage')
            else
              ...data.history.map((a) => AppCard(
                    child: Row(
                      children: [
                        Expanded(child: Text('${a['date']} • ${a['employeeName'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.w700))),
                        Text('Entree ${a['checkInTime'] ?? '-'}'),
                        const SizedBox(width: 12),
                        Text('Sortie ${a['checkOutTime'] ?? '-'}'),
                        const SizedBox(width: 12),
                        Text('${a['totalHours'] ?? 0}h'),
                        const SizedBox(width: 12),
                        StatusBadge(a['status']?.toString()),
                      ],
                    ),
                  )),
          ],
        );
      },
    );
  }
}

class _AttendanceData {
  _AttendanceData(this.today, this.history);
  final Map<String, dynamic> today;
  final List<Map<String, dynamic>> history;
}
