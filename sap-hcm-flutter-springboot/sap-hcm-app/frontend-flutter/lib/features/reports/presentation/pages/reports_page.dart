import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/custom_data_table.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/section_title.dart';
import '../../data/services/reports_service.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String _type = 'leaves';
  Future<Map<String, dynamic>>? _future;
  final _start = TextEditingController();
  final _end = TextEditingController();
  final _department = TextEditingController();
  final _employee = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= ReportsService(context.read<ApiClient>()).getReport(_type);
  }

  void _load() => setState(() => _future = ReportsService(context.read<ApiClient>()).getReport(_type));

  @override
  void dispose() {
    _start.dispose();
    _end.dispose();
    _department.dispose();
    _employee.dispose();
    super.dispose();
  }

  void _export(String format) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export $format simule avec les filtres selectionnes')));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Rapports RH / Export', subtitle: 'Presences, conges, paie, formations et evaluations avec exports simules.'),
        const SizedBox(height: 18),
        AppCard(
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              SizedBox(
                width: 220,
                child: DropdownButtonFormField<String>(
                  value: _type,
                  decoration: const InputDecoration(labelText: 'Type de rapport'),
                  items: const ['leaves', 'attendance', 'payroll', 'trainings', 'performance']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => _type = v ?? 'leaves'),
                ),
              ),
              SizedBox(width: 160, child: TextField(controller: _start, decoration: const InputDecoration(labelText: 'Date debut'))),
              SizedBox(width: 160, child: TextField(controller: _end, decoration: const InputDecoration(labelText: 'Date fin'))),
              SizedBox(width: 180, child: TextField(controller: _department, decoration: const InputDecoration(labelText: 'Departement'))),
              SizedBox(width: 180, child: TextField(controller: _employee, decoration: const InputDecoration(labelText: 'Employe'))),
              AppButton(label: 'Generer', icon: Icons.search, onPressed: _load),
              AppButton(label: 'Exporter PDF', icon: Icons.picture_as_pdf, outlined: true, onPressed: () => _export('PDF')),
              AppButton(label: 'Exporter Excel', icon: Icons.table_chart, outlined: true, onPressed: () => _export('Excel')),
            ],
          ),
        ),
        const SizedBox(height: 18),
        FutureBuilder<Map<String, dynamic>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) return const LoadingWidget();
            if (snapshot.hasError) return ErrorView(message: snapshot.error.toString(), onRetry: _load);
            final report = snapshot.data!;
            final columns = List<String>.from(report['columns'] ?? const []);
            final rows = List<Map<String, dynamic>>.from((report['rows'] ?? const []).map((e) => Map<String, dynamic>.from(e)));
            return AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(report['title']?.toString() ?? 'Rapport', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(report['period']?.toString() ?? ''),
                  const SizedBox(height: 14),
                  CustomDataTable(columns: columns, rows: rows),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
