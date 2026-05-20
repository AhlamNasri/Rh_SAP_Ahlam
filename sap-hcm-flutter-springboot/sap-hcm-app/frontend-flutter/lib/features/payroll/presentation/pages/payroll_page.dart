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
import '../../data/services/payroll_file_saver.dart';
import '../../data/services/payroll_service.dart';

class PayrollPage extends StatefulWidget {
  const PayrollPage({super.key});

  @override
  State<PayrollPage> createState() => _PayrollPageState();
}

class _PayrollPageState extends State<PayrollPage> {
  late Future<List<Map<String, dynamic>>> _future;
  final _searchController = TextEditingController();
  String _statusFilter = 'TOUS';
  int? _expandedId;
  int? _downloadingId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future = _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _load() {
    final auth = context.read<AuthProvider>();
    final service = PayrollService(context.read<ApiClient>());
    return auth.hasAnyRole(['HR', 'ADMIN']) ? service.all() : service.my();
  }

  void _refresh() => setState(() => _future = _load());

  Future<void> _download(Map<String, dynamic> payroll) async {
    final id = (payroll['id'] as num?)?.toInt();
    if (id == null) return;
    setState(() => _downloadingId = id);
    try {
      final document = await PayrollService(context.read<ApiClient>()).download(id);
      final savedTo = await savePayrollFile(
        bytes: document.bytes,
        fileName: document.fileName,
        mimeType: document.mimeType,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fiche de paie telechargee: $savedTo')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Telechargement impossible: $e')));
    } finally {
      if (mounted) setState(() => _downloadingId = null);
    }
  }

  void _showDetail(Map<String, dynamic> payroll) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Fiche ${payroll['month'] ?? '-'}'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Line('Employe', payroll['employeeName']),
              _Line('Departement', payroll['departmentName']),
              _Line('Salaire de base', '${_money(payroll['baseSalary'])} MAD'),
              _Line('Primes', '${_money(payroll['bonuses'])} MAD'),
              _Line('Heures supplementaires', '${_money(payroll['overtime'])} MAD'),
              _Line('Deductions', '${_money(payroll['deductions'])} MAD'),
              _Line('Charges simulees', '${_money(payroll['charges'])} MAD'),
              const Divider(),
              _Line('Net a payer', '${_money(payroll['netSalary'])} MAD'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer')),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _download(payroll);
            },
            icon: const Icon(Icons.download_outlined),
            label: const Text('Telecharger PDF'),
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
        final query = _searchController.text.trim().toLowerCase();
        final filtered = payrolls.where((payroll) {
          final status = payroll['status']?.toString() ?? '';
          final employee = payroll['employeeName']?.toString().toLowerCase() ?? '';
          final month = payroll['month']?.toString().toLowerCase() ?? '';
          final matchesStatus = _statusFilter == 'TOUS' || status == _statusFilter;
          final matchesQuery = query.isEmpty || employee.contains(query) || month.contains(query);
          return matchesStatus && matchesQuery;
        }).toList();

        final paidCount = payrolls.where((p) => p['status']?.toString() == 'PAYE').length;
        final totalNet = payrolls.fold<double>(0, (sum, p) => sum + _toDouble(p['netSalary']));
        final averageNet = payrolls.isEmpty ? 0.0 : totalNet / payrolls.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionTitle(
              'Gestion de la paie',
              subtitle: context.read<AuthProvider>().hasAnyRole(['HR', 'ADMIN'])
                  ? 'Vue RH/Admin avec consultation, filtres et export PDF securise.'
                  : 'Vos fiches de paie personnelles, pretes a consulter et telecharger.',
            ),
            const SizedBox(height: 18),
            _PayrollSummary(
              count: payrolls.length,
              paidCount: paidCount,
              totalNet: totalNet,
              averageNet: averageNet,
            ),
            const SizedBox(height: 16),
            _PayrollToolbar(
              controller: _searchController,
              selectedStatus: _statusFilter,
              onStatusChanged: (value) => setState(() => _statusFilter = value),
              onSearchChanged: (_) => setState(() {}),
              onRefresh: _refresh,
            ),
            const SizedBox(height: 16),
            if (payrolls.isEmpty)
              const EmptyStateWidget(title: 'Aucune fiche de paie')
            else if (filtered.isEmpty)
              const EmptyStateWidget(title: 'Aucun resultat', subtitle: 'Essayez un autre mois, employe ou statut.')
            else
              ...filtered.map(
                (payroll) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _PayrollCard(
                    payroll: payroll,
                    expanded: _expandedId == _payrollId(payroll),
                    downloading: _downloadingId == _payrollId(payroll),
                    onToggle: () {
                      final id = _payrollId(payroll);
                      setState(() => _expandedId = _expandedId == id ? null : id);
                    },
                    onDetail: () => _showDetail(payroll),
                    onDownload: () => _download(payroll),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  int? _payrollId(Map<String, dynamic> payroll) {
    return (payroll['id'] as num?)?.toInt();
  }

  String _money(dynamic value) {
    final number = _toDouble(value);
    if (number == 0 && value == null) return '-';
    return number.toStringAsFixed(number.truncateToDouble() == number ? 0 : 2);
  }
}

class _PayrollSummary extends StatelessWidget {
  const _PayrollSummary({required this.count, required this.paidCount, required this.totalNet, required this.averageNet});

  final int count;
  final int paidCount;
  final double totalNet;
  final double averageNet;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 900 ? 4 : constraints.maxWidth > 560 ? 2 : 1;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: columns,
          childAspectRatio: columns == 1 ? 4.2 : 2.7,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _MetricTile(label: 'Fiches', value: '$count', icon: Icons.receipt_long_outlined),
            _MetricTile(label: 'Payees', value: '$paidCount', icon: Icons.verified_outlined),
            _MetricTile(label: 'Net total', value: '${_format(totalNet)} MAD', icon: Icons.account_balance_wallet_outlined),
            _MetricTile(label: 'Net moyen', value: '${_format(averageNet)} MAD', icon: Icons.trending_up_outlined),
          ],
        );
      },
    );
  }

  String _format(double value) => value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2);
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: color.withOpacity(.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: TextStyle(color: Colors.grey.shade700)),
                const SizedBox(height: 4),
                Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PayrollToolbar extends StatelessWidget {
  const _PayrollToolbar({
    required this.controller,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.onSearchChanged,
    required this.onRefresh,
  });

  final TextEditingController controller;
  final String selectedStatus;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    const statuses = ['TOUS', 'PAYE', 'EN_ATTENTE', 'ANNULE'];
    return AppCard(
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 320,
            child: TextField(
              controller: controller,
              onChanged: onSearchChanged,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                labelText: 'Rechercher par employe ou mois',
              ),
            ),
          ),
          ...statuses.map(
            (status) => ChoiceChip(
              label: Text(status == 'TOUS' ? 'Tous' : status.replaceAll('_', ' ')),
              selected: selectedStatus == status,
              onSelected: (_) => onStatusChanged(status),
            ),
          ),
          IconButton(
            tooltip: 'Actualiser',
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}

class _PayrollCard extends StatelessWidget {
  const _PayrollCard({
    required this.payroll,
    required this.expanded,
    required this.downloading,
    required this.onToggle,
    required this.onDetail,
    required this.onDownload,
  });

  final Map<String, dynamic> payroll;
  final bool expanded;
  final bool downloading;
  final VoidCallback onToggle;
  final VoidCallback onDetail;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 720;
                  final title = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${payroll['employeeName'] ?? '-'} - ${payroll['month'] ?? '-'}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Brut: ${_money(payroll['grossSalary'])} MAD  |  Net: ${_money(payroll['netSalary'])} MAD  |  Paiement: ${payroll['paymentDate'] ?? '-'}',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                  );
                  final actions = Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      StatusBadge(payroll['status']?.toString()),
                      AppButton(label: 'Detail', icon: Icons.visibility_outlined, outlined: true, onPressed: onDetail),
                      AppButton(
                        label: downloading ? 'Telechargement...' : 'PDF',
                        icon: Icons.download_outlined,
                        onPressed: downloading ? null : onDownload,
                      ),
                      Icon(expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                    ],
                  );

                  if (compact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PayrollIcon(month: payroll['month']?.toString()),
                        const SizedBox(height: 12),
                        title,
                        const SizedBox(height: 12),
                        actions,
                      ],
                    );
                  }

                  return Row(
                    children: [
                      _PayrollIcon(month: payroll['month']?.toString()),
                      const SizedBox(width: 14),
                      Expanded(child: title),
                      const SizedBox(width: 12),
                      actions,
                    ],
                  );
                },
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: _PayrollBreakdown(payroll: payroll),
                ),
                crossFadeState: expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 180),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _money(dynamic value) {
    final number = value is num ? value.toDouble() : double.tryParse(value?.toString() ?? '') ?? 0;
    return number.toStringAsFixed(number.truncateToDouble() == number ? 0 : 2);
  }
}

class _PayrollIcon extends StatelessWidget {
  const _PayrollIcon({required this.month});

  final String? month;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(color: color.withOpacity(.1), borderRadius: BorderRadius.circular(8)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.payments_outlined, color: color),
          Text((month ?? '--').split('-').last, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12)),
        ],
      ),
    );
  }
}

class _PayrollBreakdown extends StatelessWidget {
  const _PayrollBreakdown({required this.payroll});

  final Map<String, dynamic> payroll;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Wrap(
        spacing: 18,
        runSpacing: 10,
        children: [
          _MiniAmount(label: 'Base', value: payroll['baseSalary']),
          _MiniAmount(label: 'Primes', value: payroll['bonuses']),
          _MiniAmount(label: 'Heures sup.', value: payroll['overtime']),
          _MiniAmount(label: 'Deductions', value: payroll['deductions']),
          _MiniAmount(label: 'Charges', value: payroll['charges']),
          _MiniAmount(label: 'Net', value: payroll['netSalary'], strong: true),
        ],
      ),
    );
  }
}

class _MiniAmount extends StatelessWidget {
  const _MiniAmount({required this.label, required this.value, this.strong = false});

  final String label;
  final dynamic value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final number = value is num ? value.toDouble() : double.tryParse(value?.toString() ?? '') ?? 0;
    final amount = number.toStringAsFixed(number.truncateToDouble() == number ? 0 : 2);
    return SizedBox(
      width: 135,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
          const SizedBox(height: 3),
          Text(
            '$amount MAD',
            style: TextStyle(fontWeight: strong ? FontWeight.w900 : FontWeight.w700),
          ),
        ],
      ),
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
