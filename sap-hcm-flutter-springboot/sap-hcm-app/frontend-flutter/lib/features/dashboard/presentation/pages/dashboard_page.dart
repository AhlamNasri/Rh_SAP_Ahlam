import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/section_title.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../data/services/dashboard_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<_DashboardData> _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future = _load();
  }

  Future<_DashboardData> _load() async {
    final service = DashboardService(context.read<ApiClient>());
    final results = await Future.wait([
      service.stats(),
      service.employeesByDepartment(),
      service.leavesByMonth(),
      service.attendanceSummary(),
    ]);
    return _DashboardData(
      stats: results[0] as Map<String, dynamic>,
      departments: results[1] as List<Map<String, dynamic>>,
      leaves: results[2] as List<Map<String, dynamic>>,
      attendance: results[3] as List<Map<String, dynamic>>,
    );
  }

  void _refresh() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_DashboardData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) return const LoadingWidget();
        if (snapshot.hasError) return ErrorView(message: snapshot.error.toString(), onRetry: _refresh);
        final data = snapshot.data!;
        final stats = data.stats;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle('Vue globale RH', subtitle: 'Indicateurs simules et prepares pour integration SAP Business Accelerator Hub.'),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth > 1000 ? 4 : constraints.maxWidth > 650 ? 2 : 1;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: columns,
                  childAspectRatio: columns == 1 ? 3.4 : 2.2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  children: [
                    StatCard(title: 'Employes', value: '${stats['totalEmployees'] ?? 0}', icon: Icons.people_outline),
                    StatCard(title: 'Presents aujourd hui', value: '${stats['presentToday'] ?? 0}', icon: Icons.access_time),
                    StatCard(title: 'Conges en attente', value: '${stats['pendingLeaves'] ?? 0}', icon: Icons.beach_access_outlined),
                    StatCard(title: 'Masse salariale', value: '${stats['simulatedPayrollMass'] ?? 0} MAD', icon: Icons.payments_outlined),
                    StatCard(title: 'Conges approuves', value: '${stats['approvedLeaves'] ?? 0}', icon: Icons.check_circle_outline),
                    StatCard(title: 'Candidats', value: '${stats['recruitmentCandidates'] ?? 0}', icon: Icons.work_outline),
                    StatCard(title: 'Formations actives', value: '${stats['activeTrainings'] ?? 0}', icon: Icons.school_outlined),
                    StatCard(title: 'Evaluations a faire', value: '${stats['pendingReviews'] ?? 0}', icon: Icons.grade_outlined),
                  ],
                );
              },
            ),
            const SizedBox(height: 22),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(width: 520, child: _BarChartCard(title: 'Employes par departement', data: data.departments, labelKey: 'label', valueKey: 'value')),
                SizedBox(width: 520, child: _BarChartCard(title: 'Conges par mois', data: data.leaves, labelKey: 'month', valueKey: 'count')),
                SizedBox(width: 520, child: _BarChartCard(title: 'Evolution des presences', data: data.attendance, labelKey: 'date', valueKey: 'count')),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _BarChartCard extends StatelessWidget {
  const _BarChartCard({required this.title, required this.data, required this.labelKey, required this.valueKey});

  final String title;
  final List<Map<String, dynamic>> data;
  final String labelKey;
  final String valueKey;

  @override
  Widget build(BuildContext context) {
    final items = data.take(8).toList();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 18),
          SizedBox(
            height: 260,
            child: items.isEmpty
                ? const Center(child: Text('Aucune donnee'))
                : BarChart(
                    BarChartData(
                      barGroups: [
                        for (var i = 0; i < items.length; i++)
                          BarChartGroupData(x: i, barRods: [BarChartRodData(toY: ((items[i][valueKey] ?? 0) as num).toDouble())]),
                      ],
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= items.length) return const SizedBox.shrink();
                              final label = '${items[index][labelKey]}';
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(label.length > 8 ? label.substring(0, 8) : label, style: const TextStyle(fontSize: 10)),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _DashboardData {
  _DashboardData({required this.stats, required this.departments, required this.leaves, required this.attendance});
  final Map<String, dynamic> stats;
  final List<Map<String, dynamic>> departments;
  final List<Map<String, dynamic>> leaves;
  final List<Map<String, dynamic>> attendance;
}
