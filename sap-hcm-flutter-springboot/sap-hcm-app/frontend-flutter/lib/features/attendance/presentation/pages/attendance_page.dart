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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(checkIn ? 'Entree pointee' : 'Sortie pointee')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        _refresh();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_AttendanceData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const LoadingWidget();
        }
        if (snapshot.hasError) {
          return ErrorView(
              message: snapshot.error.toString(), onRetry: _refresh);
        }

        final data = snapshot.data!;
        final todayStatus = data.today['status']?.toString();
        final hasCheckedIn = data.today['checkInTime'] != null;
        final hasCheckedOut = data.today['checkOutTime'] != null;
        final todayDate = data.today['date']?.toString();
        final history = _personalHistoryWithToday(data);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle('Pointage / Presences',
                subtitle:
                    'Votre pointage du jour et votre historique personnel.'),
            const SizedBox(height: 18),
            AppCard(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 760;
                  final summary = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.today_outlined, size: 38),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Aujourd hui',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                            fontWeight: FontWeight.w800)),
                                Text(_statusText(todayStatus),
                                    style:
                                        TextStyle(color: Colors.grey.shade700)),
                              ],
                            ),
                          ),
                          StatusBadge(todayStatus),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _TimeChip(
                              icon: Icons.login,
                              label: 'Entree',
                              value: data.today['checkInTime']),
                          _TimeChip(
                              icon: Icons.logout,
                              label: 'Sortie',
                              value: data.today['checkOutTime']),
                          _TimeChip(
                              icon: Icons.timer_outlined,
                              label: 'Heures',
                              value: data.today['totalHours'] ?? '0'),
                        ],
                      ),
                    ],
                  );
                  final actions = Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment:
                        compact ? WrapAlignment.start : WrapAlignment.end,
                    children: [
                      AppButton(
                          label: 'Pointer entree',
                          icon: Icons.login,
                          onPressed: hasCheckedIn ? null : () => _action(true)),
                      AppButton(
                          label: 'Pointer sortie',
                          icon: Icons.logout,
                          outlined: true,
                          onPressed: (!hasCheckedIn || hasCheckedOut)
                              ? null
                              : () => _action(false)),
                    ],
                  );
                  if (compact) {
                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          summary,
                          const SizedBox(height: 16),
                          actions
                        ]);
                  }
                  return Row(
                    children: [
                      Expanded(child: summary),
                      const SizedBox(width: 18),
                      actions,
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            AppCard(
              child: Row(
                children: [
                  const Icon(Icons.manage_accounts_outlined),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Chaque pointage admin est enregistre ici dans son historique personnel.',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text('Historique personnel',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            if (history.isEmpty)
              const EmptyStateWidget(title: 'Aucun pointage')
            else
              ...history.map((a) => _AttendanceHistoryCard(
                  attendance: a, isToday: a['date']?.toString() == todayDate)),
          ],
        );
      },
    );
  }

  List<Map<String, dynamic>> _personalHistoryWithToday(_AttendanceData data) {
    final todayDate = data.today['date']?.toString();
    final history = List<Map<String, dynamic>>.from(data.history);
    final todayAlreadyInHistory =
        history.any((a) => a['date']?.toString() == todayDate);
    if (todayAlreadyInHistory || data.today['checkInTime'] == null) {
      return history;
    }

    return [
      {
        'date': data.today['date'],
        'employeeName': 'Moi',
        'checkInTime': data.today['checkInTime'],
        'checkOutTime': data.today['checkOutTime'],
        'totalHours': data.today['totalHours'] ?? 0,
        'status': data.today['status'],
      },
      ...history,
    ];
  }

  String _statusText(String? status) {
    if (status == null || status.isEmpty) {
      return 'Aucun pointage pour le moment';
    }
    return status.replaceAll('_', ' ');
  }
}

class _AttendanceData {
  _AttendanceData(this.today, this.history);
  final Map<String, dynamic> today;
  final List<Map<String, dynamic>> history;
}

class _TimeChip extends StatelessWidget {
  const _TimeChip(
      {required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final dynamic value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text('$label: ${value ?? '-'}'),
    );
  }
}

class _AttendanceHistoryCard extends StatelessWidget {
  const _AttendanceHistoryCard(
      {required this.attendance, required this.isToday});

  final Map<String, dynamic> attendance;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 720;
          final title = Row(
            children: [
              Icon(isToday ? Icons.today : Icons.event_available_outlined),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        isToday
                            ? 'Aujourd hui'
                            : '${attendance['date'] ?? '-'}',
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                    Text('${attendance['employeeName'] ?? 'Moi'}',
                        style: TextStyle(color: Colors.grey.shade700)),
                  ],
                ),
              ),
              StatusBadge(attendance['status']?.toString()),
            ],
          );
          final details = Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _HistoryValue(label: 'Entree', value: attendance['checkInTime']),
              _HistoryValue(label: 'Sortie', value: attendance['checkOutTime']),
              _HistoryValue(
                  label: 'Heures', value: '${attendance['totalHours'] ?? 0}h'),
            ],
          );
          if (compact) {
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [title, const SizedBox(height: 12), details]);
          }
          return Row(
            children: [
              Expanded(child: title),
              const SizedBox(width: 12),
              details,
            ],
          );
        },
      ),
    );
  }
}

class _HistoryValue extends StatelessWidget {
  const _HistoryValue({required this.label, required this.value});

  final String label;
  final dynamic value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 96),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
          const SizedBox(height: 2),
          Text('${value ?? '-'}',
              style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
