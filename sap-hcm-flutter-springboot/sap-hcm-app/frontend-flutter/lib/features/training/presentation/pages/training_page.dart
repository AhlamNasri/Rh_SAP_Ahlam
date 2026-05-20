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
import '../../data/services/training_service.dart';

class TrainingPage extends StatefulWidget {
  const TrainingPage({super.key});

  @override
  State<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future = TrainingService(context.read<ApiClient>()).all();
  }

  void _refresh() => setState(() => _future = TrainingService(context.read<ApiClient>()).all());

  Future<void> _addTraining() async {
    final title = TextEditingController();
    final trainer = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Creer une formation'),
        content: SizedBox(
          width: 420,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: title, decoration: const InputDecoration(labelText: 'Titre')),
            const SizedBox(height: 12),
            TextField(controller: trainer, decoration: const InputDecoration(labelText: 'Formateur')),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Creer')),
        ],
      ),
    );
    if (ok == true) {
      await TrainingService(context.read<ApiClient>()).create({
        'title': title.text,
        'description': 'Formation ajoutee depuis Flutter',
        'durationHours': 8,
        'trainer': trainer.text,
        'status': 'PLANIFIEE',
      });
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final canCreate = context.watch<AuthProvider>().hasAnyRole(['HR', 'ADMIN']);
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) return const LoadingWidget();
        if (snapshot.hasError) return ErrorView(message: snapshot.error.toString(), onRetry: _refresh);
        final trainings = snapshot.data ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Expanded(child: SectionTitle('Suivi des formations', subtitle: 'Catalogue, progression et employes inscrits.')),
              if (canCreate) AppButton(label: 'Creer une formation', icon: Icons.add, onPressed: _addTraining),
            ]),
            const SizedBox(height: 18),
            if (trainings.isEmpty)
              const EmptyStateWidget(title: 'Aucune formation')
            else
              ...trainings.map((t) {
                final employees = List<String>.from(t['enrolledEmployees'] ?? const []);
                return AppCard(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Icon(Icons.school_outlined),
                      const SizedBox(width: 12),
                      Expanded(child: Text('${t['title']} • ${t['durationHours'] ?? 0}h', style: const TextStyle(fontWeight: FontWeight.w800))),
                      StatusBadge(t['status']?.toString()),
                    ]),
                    const SizedBox(height: 8),
                    Text('${t['description'] ?? ''}'),
                    Text('Formateur: ${t['trainer'] ?? '-'} • ${t['startDate'] ?? '-'} -> ${t['endDate'] ?? '-'}'),
                    if (t['progressPercent'] != null) LinearProgressIndicator(value: ((t['progressPercent'] as num).toDouble()) / 100),
                    if (employees.isNotEmpty) Text('Inscrits: ${employees.join(', ')}'),
                  ]),
                );
              }),
          ],
        );
      },
    );
  }
}
