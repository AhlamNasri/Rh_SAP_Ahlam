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
import '../../data/services/payroll_service.dart';

class PayrollPage extends StatefulWidget {
  const PayrollPage({super.key});

  @override
  State<PayrollPage> createState() => _PayrollPageState();
}

class _PayrollPageState extends State<PayrollPage> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() {
    final auth = context.read<AuthProvider>();
    final service = PayrollService(context.read<ApiClient>());
    return auth.hasAnyRole(['HR', 'ADMIN']) ? service.all() : service.my();
  }

  void _refresh() => setState(() => _future = _load());

  void _showDetail(Map<String, dynamic> p) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Fiche ${p['month']}'),
        content: SizedBox(
          width: 460,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Line('Employe', p['employeeName']),
              _Line('Salaire de base', '${p['baseSalary']} MAD'),
              _Line('Primes', '${p['bonuses']} MAD'),
              _Line('Heures supplementaires', '${p['overtime']} MAD'),
              _Line('Deductions', '${p['deductions']} MAD'),
              _Line('Charges simulees', '${p['charges']} MAD'),
              const Divider(),
              _Line('Net a payer', '${p['netSalary']} MAD'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Telechargement PDF simule')));
            },
            child: const Text('Telecharger PDF'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) return const LoadingWidget();
        if (snapshot.hasError) return ErrorView(message: snapshot.error.toString(), onRetry: _refresh);
        final payrolls = snapshot.data ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle('Gestion de la paie', subtitle: 'Acces securise: employe voit ses fiches, RH/Admin voient toutes les fiches.'),
            const SizedBox(height: 18),
            if (payrolls.isEmpty)
              const EmptyStateWidget(title: 'Aucune fiche de paie')
            else
              ...payrolls.map((p) => AppCard(
                    child: Row(
                      children: [
                        const Icon(Icons.payments_outlined),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${p['employeeName'] ?? '-'} • ${p['month']}', style: const TextStyle(fontWeight: FontWeight.w800)),
                              Text('Brut: ${p['grossSalary']} MAD • Net: ${p['netSalary']} MAD • Paiement: ${p['paymentDate']}'),
                            ],
                          ),
                        ),
                        StatusBadge(p['status']?.toString()),
                        const SizedBox(width: 8),
                        AppButton(label: 'Voir detail', icon: Icons.visibility_outlined, outlined: true, onPressed: () => _showDetail(p)),
                      ],
                    ),
                  )),
          ],
        );
      },
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(this.label, this.value);
  final String label;
  final dynamic value;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(color: Colors.grey.shade700))),
          Text('$value', style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
