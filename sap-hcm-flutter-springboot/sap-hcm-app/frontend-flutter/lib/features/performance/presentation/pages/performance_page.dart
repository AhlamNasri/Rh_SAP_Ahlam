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
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/services/performance_service.dart';

class PerformancePage extends StatefulWidget {
  const PerformancePage({super.key});

  @override
  State<PerformancePage> createState() => _PerformancePageState();
}

class _PerformancePageState extends State<PerformancePage> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() {
    final auth = context.read<AuthProvider>();
    final service = PerformanceService(context.read<ApiClient>());
    return auth.hasAnyRole(['MANAGER', 'HR', 'ADMIN']) ? service.all() : service.my();
  }

  void _refresh() => setState(() => _future = _load());

  Future<void> _addReview() async {
    final employeeId = TextEditingController(text: '4');
    final period = TextEditingController(text: 'S2-2026');
    final comment = TextEditingController();
    double score = 4;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvelle evaluation'),
        content: StatefulBuilder(builder: (context, setDialogState) {
          return SizedBox(
            width: 440,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: employeeId, decoration: const InputDecoration(labelText: 'ID employe evalue')),
              const SizedBox(height: 12),
              TextField(controller: period, decoration: const InputDecoration(labelText: 'Periode')),
              const SizedBox(height: 12),
              Slider(value: score, min: 1, max: 5, divisions: 4, label: score.round().toString(), onChanged: (v) => setDialogState(() => score = v)),
              TextField(controller: comment, decoration: const InputDecoration(labelText: 'Commentaire manager'), maxLines: 3),
            ]),
          );
        }),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Creer')),
        ],
      ),
    );
    if (ok == true) {
      try {
        await PerformanceService(context.read<ApiClient>()).create({
          'employeeId': int.parse(employeeId.text),
          'period': period.text,
          'objective1': 'Qualite de livraison',
          'objective2': 'Collaboration',
          'objective3': 'Competence SAP HCM',
          'score': score.round(),
          'comment': comment.text,
          'status': 'BROUILLON',
        });
        _refresh();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canCreate = context.watch<AuthProvider>().hasAnyRole(['MANAGER', 'HR', 'ADMIN']);
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) return const LoadingWidget();
        if (snapshot.hasError) return ErrorView(message: snapshot.error.toString(), onRetry: _refresh);
        final reviews = snapshot.data ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Expanded(child: SectionTitle('Evaluation des performances', subtitle: 'Objectifs, score global et validation manager/RH.')),
              if (canCreate) AppButton(label: 'Nouvelle evaluation', icon: Icons.add, onPressed: _addReview),
            ]),
            const SizedBox(height: 18),
            if (reviews.isEmpty)
              const EmptyStateWidget(title: 'Aucune evaluation')
            else
              ...reviews.map((r) => AppCard(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Expanded(child: Text('${r['employeeName']} • ${r['period']}', style: const TextStyle(fontWeight: FontWeight.w800))),
                        StatusBadge(r['status']?.toString()),
                      ]),
                      const SizedBox(height: 8),
                      Text('Manager: ${r['managerName'] ?? '-'} • Score: ${r['score'] ?? '-'} / 5'),
                      Text('Objectifs: ${r['objective1'] ?? '-'} | ${r['objective2'] ?? '-'} | ${r['objective3'] ?? '-'}'),
                      if ((r['comment'] ?? '').toString().isNotEmpty) Text('Commentaire: ${r['comment']}'),
                    ]),
                  )),
          ],
        );
      },
    );
  }
}
