import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/section_title.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../attendance/data/services/attendance_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../leaves/data/services/leaves_service.dart';
import '../../../payroll/data/services/payroll_service.dart';
import '../../../performance/data/services/performance_service.dart';
import '../../../profile/data/services/employee_service.dart';
import '../../../training/data/services/training_service.dart';
import '../../data/services/dashboard_service.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.hasAnyRole(['HR', 'ADMIN'])) return const _HrDashboardPage();
    return const _EmployeeDashboardPage();
  }
}

class _HrDashboardPage extends StatefulWidget {
  const _HrDashboardPage();

  @override
  State<_HrDashboardPage> createState() => _HrDashboardPageState();
}

class _HrDashboardPageState extends State<_HrDashboardPage> {
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

class _EmployeeDashboardPage extends StatefulWidget {
  const _EmployeeDashboardPage();

  @override
  State<_EmployeeDashboardPage> createState() => _EmployeeDashboardPageState();
}

class _EmployeeDashboardPageState extends State<_EmployeeDashboardPage> {
  late Future<_EmployeeDashboardData> _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future = _load();
  }

  Future<_EmployeeDashboardData> _load() async {
    final api = context.read<ApiClient>();
    final results = await Future.wait([
      EmployeeService(api).me(),
      LeavesService(api).my(),
      AttendanceService(api).today(),
      AttendanceService(api).my(),
      PayrollService(api).my(),
      TrainingService(api).my(),
      PerformanceService(api).my(),
    ]);
    return _EmployeeDashboardData(
      profile: results[0] as Map<String, dynamic>,
      leaves: results[1] as List<Map<String, dynamic>>,
      todayAttendance: results[2] as Map<String, dynamic>,
      attendanceHistory: results[3] as List<Map<String, dynamic>>,
      payrolls: results[4] as List<Map<String, dynamic>>,
      trainings: results[5] as List<Map<String, dynamic>>,
      reviews: results[6] as List<Map<String, dynamic>>,
    );
  }

  void _refresh() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_EmployeeDashboardData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) return const LoadingWidget();
        if (snapshot.hasError) return ErrorView(message: snapshot.error.toString(), onRetry: _refresh);
        final data = snapshot.data!;
        final profile = data.profile;
        final pendingLeaves = data.leaves.where((leave) => leave['status'] == 'EN_ATTENTE').length;
        final approvedLeaves = data.leaves.where((leave) => leave['status'] == 'APPROUVE').length;
        final latestPayroll = data.payrolls.isEmpty ? null : data.payrolls.first;
        final latestReview = data.reviews.isEmpty ? null : data.reviews.first;
        final lastAttendance = data.attendanceHistory.isEmpty ? null : data.attendanceHistory.first;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionTitle(
              'Tableau de bord employe',
              subtitle: 'Bienvenue ${profile['firstName'] ?? profile['fullName'] ?? ''}. Vos informations RH personnelles en un coup d oeil.',
            ),
            const SizedBox(height: 18),
            AppCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundImage: NetworkImage(profile['avatarUrl']?.toString() ?? 'https://ui-avatars.com/api/?name=EMP'),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(profile['fullName']?.toString() ?? '-', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        Text('${profile['jobTitle'] ?? '-'} - ${profile['departmentName'] ?? '-'}'),
                        Text('Manager: ${profile['managerName'] ?? '-'}'),
                      ],
                    ),
                  ),
                  StatusBadge((profile['active'] == true) ? 'ACTIF' : 'INACTIF'),
                ],
              ),
            ),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth > 1000 ? 4 : constraints.maxWidth > 650 ? 2 : 1;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: columns,
                  childAspectRatio: columns == 1 ? 3.2 : 2.1,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  children: [
                    StatCard(title: 'Solde conges', value: '${profile['annualLeaveBalance'] ?? 0} j', icon: Icons.beach_access_outlined, subtitle: '$pendingLeaves demande(s) en attente'),
                    StatCard(title: 'Pointage du jour', value: _statusLabel(data.todayAttendance['status']), icon: Icons.access_time, subtitle: 'Entree ${data.todayAttendance['checkInTime'] ?? '-'} / Sortie ${data.todayAttendance['checkOutTime'] ?? '-'}'),
                    StatCard(title: 'Derniere paie', value: latestPayroll == null ? '-' : '${latestPayroll['netSalary']} MAD', icon: Icons.payments_outlined, subtitle: latestPayroll == null ? 'Aucune fiche' : '${latestPayroll['month'] ?? '-'}'),
                    StatCard(title: 'Formations', value: '${data.trainings.length}', icon: Icons.school_outlined, subtitle: 'Parcours inscrit'),
                    StatCard(title: 'Conges approuves', value: '$approvedLeaves', icon: Icons.check_circle_outline, subtitle: 'Historique personnel'),
                    StatCard(title: 'Evaluations', value: '${data.reviews.length}', icon: Icons.grade_outlined, subtitle: latestReview == null ? 'Aucune evaluation' : 'Dernier score: ${latestReview['score'] ?? '-'} / 5'),
                    StatCard(title: 'Derniere presence', value: lastAttendance == null ? '-' : '${lastAttendance['totalHours'] ?? 0}h', icon: Icons.today_outlined, subtitle: lastAttendance == null ? 'Aucun historique' : '${lastAttendance['date'] ?? '-'}'),
                    StatCard(title: 'Contrat', value: '${profile['contractType'] ?? '-'}', icon: Icons.badge_outlined, subtitle: 'Matricule ${profile['employeeNumber'] ?? '-'}'),
                  ],
                );
              },
            ),
            const SizedBox(height: 22),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth > 900;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(width: wide ? 430 : double.infinity, child: _EmployeeActionCard(title: 'Demander un conge', subtitle: 'Creer et suivre vos demandes', icon: Icons.add_circle_outline, route: '/leaves')),
                    SizedBox(width: wide ? 430 : double.infinity, child: _EmployeeActionCard(title: 'Pointer ma presence', subtitle: 'Entree, sortie et historique', icon: Icons.login, route: '/attendance')),
                    SizedBox(width: wide ? 430 : double.infinity, child: _EmployeeActionCard(title: 'Voir mes fiches de paie', subtitle: 'Consulter le net a payer', icon: Icons.receipt_long_outlined, route: '/payroll')),
                    SizedBox(width: wide ? 430 : double.infinity, child: _EmployeeActionCard(title: 'Mettre a jour mon profil', subtitle: 'Telephone et adresse', icon: Icons.manage_accounts_outlined, route: '/profile')),
                  ],
                );
              },
            ),
            const SizedBox(height: 22),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dernieres demandes de conge', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  if (data.leaves.isEmpty)
                    const Text('Aucune demande de conge pour le moment.')
                  else
                    ...data.leaves.take(3).map((leave) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Expanded(child: Text('${leave['type'] ?? '-'} - ${leave['startDate'] ?? '-'} -> ${leave['endDate'] ?? '-'}')),
                              StatusBadge(leave['status']?.toString()),
                            ],
                          ),
                        )),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String _statusLabel(dynamic status) {
    final value = status?.toString();
    if (value == null || value.isEmpty) return '-';
    return value.replaceAll('_', ' ');
  }
}

class _EmployeeActionCard extends StatelessWidget {
  const _EmployeeActionCard({required this.title, required this.subtitle, required this.icon, required this.route});

  final String title;
  final String subtitle;
  final IconData icon;
  final String route;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: InkWell(
        onTap: () => context.go(route),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(icon, size: 32),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(color: Colors.grey.shade700)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
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

class _EmployeeDashboardData {
  _EmployeeDashboardData({
    required this.profile,
    required this.leaves,
    required this.todayAttendance,
    required this.attendanceHistory,
    required this.payrolls,
    required this.trainings,
    required this.reviews,
  });

  final Map<String, dynamic> profile;
  final List<Map<String, dynamic>> leaves;
  final Map<String, dynamic> todayAttendance;
  final List<Map<String, dynamic>> attendanceHistory;
  final List<Map<String, dynamic>> payrolls;
  final List<Map<String, dynamic>> trainings;
  final List<Map<String, dynamic>> reviews;
}
