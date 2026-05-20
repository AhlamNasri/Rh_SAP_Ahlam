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
import '../../data/services/recruitment_service.dart';

class RecruitmentPage extends StatefulWidget {
  const RecruitmentPage({super.key});

  @override
  State<RecruitmentPage> createState() => _RecruitmentPageState();
}

class _RecruitmentPageState extends State<RecruitmentPage> {
  late Future<_RecruitmentData> _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future = _load();
  }

  Future<_RecruitmentData> _load() async {
    final service = RecruitmentService(context.read<ApiClient>());
    return _RecruitmentData(await service.jobs(), await service.candidates());
  }

  void _refresh() => setState(() => _future = _load());

  Future<void> _addJob() async {
    final title = TextEditingController();
    final desc = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une offre'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: title, decoration: const InputDecoration(labelText: 'Titre du poste')),
              const SizedBox(height: 12),
              TextField(controller: desc, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ajouter')),
        ],
      ),
    );
    if (ok == true) {
      try {
        await RecruitmentService(context.read<ApiClient>()).createJob({
          'title': title.text,
          'departmentId': 3,
          'contractType': 'CDI',
          'status': 'OUVERTE',
          'description': desc.text,
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Offre ajoutee')));
        _refresh();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_RecruitmentData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) return const LoadingWidget();
        if (snapshot.hasError) return ErrorView(message: snapshot.error.toString(), onRetry: _refresh);
        final data = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Expanded(child: SectionTitle('Recrutement', subtitle: 'Offres d emploi, candidats et statut de candidature.')),
              AppButton(label: 'Ajouter une offre', icon: Icons.add, onPressed: _addJob),
            ]),
            const SizedBox(height: 18),
            Text('Offres d emploi', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            if (data.jobs.isEmpty)
              const EmptyStateWidget(title: 'Aucune offre')
            else
              ...data.jobs.map((j) => AppCard(
                    child: Row(
                      children: [
                        const Icon(Icons.work_outline),
                        const SizedBox(width: 14),
                        Expanded(child: Text('${j['title']} • ${j['departmentName'] ?? '-'} • ${j['contractType']}', style: const TextStyle(fontWeight: FontWeight.w700))),
                        StatusBadge(j['status']?.toString()),
                      ],
                    ),
                  )),
            const SizedBox(height: 18),
            Text('Candidats', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            ...data.candidates.map((c) => AppCard(
                  child: Row(
                    children: [
                      const Icon(Icons.person_search_outlined),
                      const SizedBox(width: 14),
                      Expanded(child: Text('${c['fullName']} • ${c['email']} • ${c['jobOfferTitle'] ?? '-'}')),
                      StatusBadge(c['status']?.toString()),
                      PopupMenuButton<String>(
                        onSelected: (status) async {
                          await RecruitmentService(context.read<ApiClient>()).updateCandidateStatus((c['id'] as num).toInt(), status);
                          _refresh();
                        },
                        itemBuilder: (_) => ['RECUE', 'ENTRETIEN', 'ACCEPTEE', 'REFUSEE'].map((s) => PopupMenuItem(value: s, child: Text(s))).toList(),
                      ),
                    ],
                  ),
                )),
          ],
        );
      },
    );
  }
}

class _RecruitmentData {
  _RecruitmentData(this.jobs, this.candidates);
  final List<Map<String, dynamic>> jobs;
  final List<Map<String, dynamic>> candidates;
}
