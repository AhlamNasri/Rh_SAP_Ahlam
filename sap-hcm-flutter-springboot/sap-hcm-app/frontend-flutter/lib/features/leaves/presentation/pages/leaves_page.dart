import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
import '../../data/services/leaves_service.dart';

class LeavesPage extends StatefulWidget {
  const LeavesPage({super.key});

  @override
  State<LeavesPage> createState() => _LeavesPageState();
}

class _LeavesPageState extends State<LeavesPage> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() {
    final auth = context.read<AuthProvider>();
    final service = LeavesService(context.read<ApiClient>());
    return auth.hasAnyRole(['MANAGER', 'HR', 'ADMIN']) ? service.all() : service.my();
  }
  void _refresh() => setState(() => _future = _load());

  Future<void> _openCreateDialog() async {
    final service = LeavesService(context.read<ApiClient>());
    final type = ValueNotifier<String>('CONGE_ANNUEL');
    final start = TextEditingController(text: DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 7))));
    final end = TextEditingController(text: DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 9))));
    final reason = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvelle demande de conge'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ValueListenableBuilder<String>(
                valueListenable: type,
                builder: (_, value, __) => DropdownButtonFormField<String>(
                  value: value,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: const ['CONGE_ANNUEL', 'CONGE_MALADIE', 'CONGE_EXCEPTIONNEL', 'CONGE_SANS_SOLDE']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => type.value = v ?? value,
                ),
              ),
              const SizedBox(height: 12),
              TextField(controller: start, decoration: const InputDecoration(labelText: 'Date debut yyyy-MM-dd')),
              const SizedBox(height: 12),
              TextField(controller: end, decoration: const InputDecoration(labelText: 'Date fin yyyy-MM-dd')),
              const SizedBox(height: 12),
              TextField(controller: reason, decoration: const InputDecoration(labelText: 'Motif'), maxLines: 3),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Envoyer')),
        ],
      ),
    );
    if (ok == true) {
      try {
        await service.create({'type': type.value, 'startDate': start.text, 'endDate': end.text, 'reason': reason.text});
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Demande envoyee')));
        _refresh();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _decide(int id, bool approve) async {
    final service = LeavesService(context.read<ApiClient>());
    try {
      approve ? await service.approve(id) : await service.reject(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(approve ? 'Conge approuve' : 'Conge refuse')));
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final canDecide = auth.hasAnyRole(['MANAGER', 'HR', 'ADMIN']);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(child: SectionTitle('Gestion des conges', subtitle: 'Demande, suivi et validation selon les roles.')),
            AppButton(label: 'Demander un conge', icon: Icons.add, onPressed: _openCreateDialog),
          ],
        ),
        const SizedBox(height: 18),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) return const LoadingWidget();
            if (snapshot.hasError) return ErrorView(message: snapshot.error.toString(), onRetry: _refresh);
            final leaves = snapshot.data ?? [];
            if (leaves.isEmpty) return const EmptyStateWidget(title: 'Aucune demande de conge');
            final pending = leaves.where((e) => e['status'] == 'EN_ATTENTE').length;
            final approved = leaves.where((e) => e['status'] == 'APPROUVE').length;
            return Column(
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _MiniStat('Demandes', leaves.length.toString()),
                    _MiniStat('En attente', pending.toString()),
                    _MiniStat('Approuvees', approved.toString()),
                  ],
                ),
                const SizedBox(height: 16),
                ...leaves.map((leave) => AppCard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.beach_access_outlined),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${leave['employeeName'] ?? '-'} • ${leave['type'] ?? '-'}', style: const TextStyle(fontWeight: FontWeight.w800)),
                                const SizedBox(height: 6),
                                Text('${leave['startDate']} -> ${leave['endDate']} • ${leave['days']} jours'),
                                if ((leave['reason'] ?? '').toString().isNotEmpty) Text(leave['reason'].toString()),
                              ],
                            ),
                          ),
                          StatusBadge(leave['status']?.toString()),
                          if (canDecide && leave['status'] == 'EN_ATTENTE') ...[
                            const SizedBox(width: 8),
                            IconButton(onPressed: () => _decide((leave['id'] as num).toInt(), true), icon: const Icon(Icons.check_circle, color: Colors.green)),
                            IconButton(onPressed: () => _decide((leave['id'] as num).toInt(), false), icon: const Icon(Icons.cancel, color: Colors.red)),
                          ],
                        ],
                      ),
                    )),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700)),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        ]),
      ),
    );
  }
}
