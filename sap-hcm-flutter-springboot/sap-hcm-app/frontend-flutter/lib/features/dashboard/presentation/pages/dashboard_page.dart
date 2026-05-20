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
  static const _palette = [
    Color(0xFF0A6ED1),
    Color(0xFF00A884),
    Color(0xFFF59E0B),
    Color(0xFF7C3AED),
    Color(0xFFE11D48),
    Color(0xFF0891B2),
  ];

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
        if (snapshot.connectionState != ConnectionState.done) {
          return const LoadingWidget();
        }
        if (snapshot.hasError) {
          return ErrorView(
              message: snapshot.error.toString(), onRetry: _refresh);
        }
        final data = snapshot.data!;
        final stats = data.stats;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle('Vue globale RH',
                subtitle:
                    'Indicateurs simules et prepares pour integration SAP Business Accelerator Hub.'),
            const SizedBox(height: 18),
            _DashboardHero(stats: stats),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth > 1000
                    ? 4
                    : constraints.maxWidth > 650
                        ? 2
                        : 1;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: columns,
                  childAspectRatio: columns == 1 ? 3.2 : 2.15,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  children: [
                    _AdminMetricCard(
                        title: 'Employes',
                        value: '${stats['totalEmployees'] ?? 0}',
                        subtitle: 'Effectif global',
                        icon: Icons.people_outline,
                        color: _palette[0]),
                    _AdminMetricCard(
                        title: 'Presents aujourd hui',
                        value: '${stats['presentToday'] ?? 0}',
                        subtitle: 'Presence en temps reel',
                        icon: Icons.access_time,
                        color: _palette[1]),
                    _AdminMetricCard(
                        title: 'Conges en attente',
                        value: '${stats['pendingLeaves'] ?? 0}',
                        subtitle: 'A traiter',
                        icon: Icons.beach_access_outlined,
                        color: _palette[2]),
                    _AdminMetricCard(
                        title: 'Masse salariale',
                        value: '${stats['simulatedPayrollMass'] ?? 0} MAD',
                        subtitle: 'Simulation mensuelle',
                        icon: Icons.payments_outlined,
                        color: _palette[3]),
                    _AdminMetricCard(
                        title: 'Conges approuves',
                        value: '${stats['approvedLeaves'] ?? 0}',
                        subtitle: 'Demandes validees',
                        icon: Icons.check_circle_outline,
                        color: _palette[1]),
                    _AdminMetricCard(
                        title: 'Candidats',
                        value: '${stats['recruitmentCandidates'] ?? 0}',
                        subtitle: 'Pipeline recrutement',
                        icon: Icons.work_outline,
                        color: _palette[5]),
                    _AdminMetricCard(
                        title: 'Formations actives',
                        value: '${stats['activeTrainings'] ?? 0}',
                        subtitle: 'Parcours ouverts',
                        icon: Icons.school_outlined,
                        color: _palette[0]),
                    _AdminMetricCard(
                        title: 'Evaluations a faire',
                        value: '${stats['pendingReviews'] ?? 0}',
                        subtitle: 'Suivi performance',
                        icon: Icons.grade_outlined,
                        color: _palette[4]),
                  ],
                );
              },
            ),
            const SizedBox(height: 22),
            LayoutBuilder(builder: (context, constraints) {
              final wide = constraints.maxWidth > 1120;
              final chartWidth =
                  wide ? (constraints.maxWidth - 18) / 2 : constraints.maxWidth;
              return Wrap(
                spacing: 18,
                runSpacing: 18,
                children: [
                  SizedBox(
                      width: chartWidth,
                      child: _BarChartCard(
                          title: 'Employes par departement',
                          data: data.departments,
                          labelKey: 'label',
                          valueKey: 'value',
                          colors: _palette)),
                  SizedBox(
                      width: chartWidth, child: _DonutChartCard(stats: stats)),
                  SizedBox(
                      width: chartWidth,
                      child: _BarChartCard(
                          title: 'Conges par mois',
                          data: data.leaves,
                          labelKey: 'month',
                          valueKey: 'count',
                          colors: [_palette[2], _palette[4], _palette[3]])),
                  SizedBox(
                      width: chartWidth,
                      child: _LineChartCard(
                          title: 'Evolution des presences',
                          data: data.attendance,
                          labelKey: 'date',
                          valueKey: 'count')),
                ],
              );
            }),
          ],
        );
      },
    );
  }
}

class _DashboardHero extends StatelessWidget {
  const _DashboardHero({required this.stats});

  final Map<String, dynamic> stats;

  @override
  Widget build(BuildContext context) {
    final employees = (stats['totalEmployees'] ?? 0) as num;
    final present = (stats['presentToday'] ?? 0) as num;
    final rate = employees == 0 ? 0.0 : (present / employees).clamp(0.0, 1.0);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1F3A),
        borderRadius: BorderRadius.circular(18),
      ),
      child: LayoutBuilder(builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;
        final overview = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text('Administration RH',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 14),
            Text(
              'Pilotage RH en temps reel',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              'Suivi des effectifs, presences, conges, paie et performance depuis un seul tableau de bord.',
              style: TextStyle(color: Colors.white.withValues(alpha: .76)),
            ),
          ],
        );
        final indicators = Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: compact ? WrapAlignment.start : WrapAlignment.end,
          children: [
            _HeroIndicator(
                label: 'Taux presence',
                value: '${(rate * 100).round()}%',
                icon: Icons.trending_up,
                color: const Color(0xFF00A884)),
            _HeroIndicator(
                label: 'Paie simulee',
                value: '${stats['simulatedPayrollMass'] ?? 0} MAD',
                icon: Icons.payments_outlined,
                color: const Color(0xFFF59E0B)),
            _HeroIndicator(
                label: 'Actions RH',
                value:
                    '${((stats['pendingLeaves'] ?? 0) as num) + ((stats['pendingReviews'] ?? 0) as num)}',
                icon: Icons.task_alt,
                color: const Color(0xFF7C3AED)),
          ],
        );
        if (compact) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [overview, const SizedBox(height: 18), indicators]);
        }
        return Row(
          children: [
            Expanded(child: overview),
            const SizedBox(width: 22),
            indicators,
          ],
        );
      }),
    );
  }
}

class _HeroIndicator extends StatelessWidget {
  const _HeroIndicator(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: .10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 20)),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(color: Colors.white.withValues(alpha: .70))),
        ],
      ),
    );
  }
}

class _AdminMetricCard extends StatelessWidget {
  const _AdminMetricCard(
      {required this.title,
      required this.value,
      required this.subtitle,
      required this.icon,
      required this.color});

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Stack(
        children: [
          Positioned(
            right: -18,
            top: -22,
            child: Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: color.withValues(alpha: .10)),
            ),
          ),
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text(value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w700,
                            fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
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
        if (snapshot.connectionState != ConnectionState.done) {
          return const LoadingWidget();
        }
        if (snapshot.hasError) {
          return ErrorView(
              message: snapshot.error.toString(), onRetry: _refresh);
        }
        final data = snapshot.data!;
        final profile = data.profile;
        final pendingLeaves = data.leaves
            .where((leave) => leave['status'] == 'EN_ATTENTE')
            .length;
        final approvedLeaves =
            data.leaves.where((leave) => leave['status'] == 'APPROUVE').length;
        final latestPayroll =
            data.payrolls.isEmpty ? null : data.payrolls.first;
        final latestReview = data.reviews.isEmpty ? null : data.reviews.first;
        final lastAttendance = data.attendanceHistory.isEmpty
            ? null
            : data.attendanceHistory.first;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionTitle(
              'Tableau de bord employe',
              subtitle:
                  'Bienvenue ${profile['firstName'] ?? profile['fullName'] ?? ''}. Vos informations RH personnelles en un coup d oeil.',
            ),
            const SizedBox(height: 18),
            AppCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundImage: NetworkImage(
                        profile['avatarUrl']?.toString() ??
                            'https://ui-avatars.com/api/?name=EMP'),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(profile['fullName']?.toString() ?? '-',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        Text(
                            '${profile['jobTitle'] ?? '-'} - ${profile['departmentName'] ?? '-'}'),
                        Text('Manager: ${profile['managerName'] ?? '-'}'),
                      ],
                    ),
                  ),
                  StatusBadge(
                      (profile['active'] == true) ? 'ACTIF' : 'INACTIF'),
                ],
              ),
            ),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth > 1000
                    ? 4
                    : constraints.maxWidth > 650
                        ? 2
                        : 1;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: columns,
                  childAspectRatio: columns == 1 ? 3.2 : 2.1,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  children: [
                    StatCard(
                        title: 'Solde conges',
                        value: '${profile['annualLeaveBalance'] ?? 0} j',
                        icon: Icons.beach_access_outlined,
                        subtitle: '$pendingLeaves demande(s) en attente'),
                    StatCard(
                        title: 'Pointage du jour',
                        value: _statusLabel(data.todayAttendance['status']),
                        icon: Icons.access_time,
                        subtitle:
                            'Entree ${data.todayAttendance['checkInTime'] ?? '-'} / Sortie ${data.todayAttendance['checkOutTime'] ?? '-'}'),
                    StatCard(
                        title: 'Derniere paie',
                        value: latestPayroll == null
                            ? '-'
                            : '${latestPayroll['netSalary']} MAD',
                        icon: Icons.payments_outlined,
                        subtitle: latestPayroll == null
                            ? 'Aucune fiche'
                            : '${latestPayroll['month'] ?? '-'}'),
                    StatCard(
                        title: 'Formations',
                        value: '${data.trainings.length}',
                        icon: Icons.school_outlined,
                        subtitle: 'Parcours inscrit'),
                    StatCard(
                        title: 'Conges approuves',
                        value: '$approvedLeaves',
                        icon: Icons.check_circle_outline,
                        subtitle: 'Historique personnel'),
                    StatCard(
                        title: 'Evaluations',
                        value: '${data.reviews.length}',
                        icon: Icons.grade_outlined,
                        subtitle: latestReview == null
                            ? 'Aucune evaluation'
                            : 'Dernier score: ${latestReview['score'] ?? '-'} / 5'),
                    StatCard(
                        title: 'Derniere presence',
                        value: lastAttendance == null
                            ? '-'
                            : '${lastAttendance['totalHours'] ?? 0}h',
                        icon: Icons.today_outlined,
                        subtitle: lastAttendance == null
                            ? 'Aucun historique'
                            : '${lastAttendance['date'] ?? '-'}'),
                    StatCard(
                        title: 'Contrat',
                        value: '${profile['contractType'] ?? '-'}',
                        icon: Icons.badge_outlined,
                        subtitle:
                            'Matricule ${profile['employeeNumber'] ?? '-'}'),
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
                    SizedBox(
                        width: wide ? 430 : double.infinity,
                        child: _EmployeeActionCard(
                            title: 'Demander un conge',
                            subtitle: 'Creer et suivre vos demandes',
                            icon: Icons.add_circle_outline,
                            route: '/leaves')),
                    SizedBox(
                        width: wide ? 430 : double.infinity,
                        child: _EmployeeActionCard(
                            title: 'Pointer ma presence',
                            subtitle: 'Entree, sortie et historique',
                            icon: Icons.login,
                            route: '/attendance')),
                    SizedBox(
                        width: wide ? 430 : double.infinity,
                        child: _EmployeeActionCard(
                            title: 'Voir mes fiches de paie',
                            subtitle: 'Consulter le net a payer',
                            icon: Icons.receipt_long_outlined,
                            route: '/payroll')),
                    SizedBox(
                        width: wide ? 430 : double.infinity,
                        child: _EmployeeActionCard(
                            title: 'Mettre a jour mon profil',
                            subtitle: 'Telephone et adresse',
                            icon: Icons.manage_accounts_outlined,
                            route: '/profile')),
                  ],
                );
              },
            ),
            const SizedBox(height: 22),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dernieres demandes de conge',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  if (data.leaves.isEmpty)
                    const Text('Aucune demande de conge pour le moment.')
                  else
                    ...data.leaves.take(3).map((leave) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Expanded(
                                  child: Text(
                                      '${leave['type'] ?? '-'} - ${leave['startDate'] ?? '-'} -> ${leave['endDate'] ?? '-'}')),
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
  const _EmployeeActionCard(
      {required this.title,
      required this.subtitle,
      required this.icon,
      required this.route});

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
                    Text(title,
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: TextStyle(color: Colors.grey.shade700)),
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
  const _BarChartCard(
      {required this.title,
      required this.data,
      required this.labelKey,
      required this.valueKey,
      required this.colors});

  final String title;
  final List<Map<String, dynamic>> data;
  final String labelKey;
  final String valueKey;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    final items = data.take(8).toList();
    final maxValue = items.fold<double>(0, (max, item) {
      final value = ((item[valueKey] ?? 0) as num).toDouble();
      return value > max ? value : max;
    });
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ChartHeader(
              title: title,
              subtitle: '${items.length} segment(s)',
              icon: Icons.bar_chart),
          const SizedBox(height: 18),
          SizedBox(
            height: 300,
            child: items.isEmpty
                ? const Center(child: Text('Aucune donnee'))
                : BarChart(
                    BarChartData(
                      maxY: maxValue <= 0 ? 1 : maxValue + 1,
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) =>
                            FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                      ),
                      barGroups: [
                        for (var i = 0; i < items.length; i++)
                          BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: ((items[i][valueKey] ?? 0) as num)
                                    .toDouble(),
                                width: 18,
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(8)),
                                color: colors[i % colors.length],
                              ),
                            ],
                          ),
                      ],
                      barTouchData: BarTouchData(enabled: true),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            reservedSize: 34,
                            showTitles: true,
                            getTitlesWidget: (value, meta) => Text(
                                value.toInt().toString(),
                                style: TextStyle(
                                    color: Colors.grey.shade600, fontSize: 11)),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 42,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= items.length) {
                                return const SizedBox.shrink();
                              }
                              final label = '${items[index][labelKey]}';
                              return Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                    label.length > 9
                                        ? label.substring(0, 9)
                                        : label,
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.w600)),
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

class _LineChartCard extends StatelessWidget {
  const _LineChartCard(
      {required this.title,
      required this.data,
      required this.labelKey,
      required this.valueKey});

  final String title;
  final List<Map<String, dynamic>> data;
  final String labelKey;
  final String valueKey;

  @override
  Widget build(BuildContext context) {
    final items = data.take(10).toList();
    final spots = [
      for (var i = 0; i < items.length; i++)
        FlSpot(i.toDouble(), ((items[i][valueKey] ?? 0) as num).toDouble()),
    ];
    final maxValue =
        spots.fold<double>(0, (max, spot) => spot.y > max ? spot.y : max);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ChartHeader(
              title: title,
              subtitle: 'Tendance recente',
              icon: Icons.show_chart),
          const SizedBox(height: 18),
          SizedBox(
            height: 300,
            child: spots.isEmpty
                ? const Center(child: Text('Aucune donnee'))
                : LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: maxValue <= 0 ? 1 : maxValue + 1,
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) =>
                            FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                      ),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            reservedSize: 34,
                            showTitles: true,
                            getTitlesWidget: (value, meta) => Text(
                                value.toInt().toString(),
                                style: TextStyle(
                                    color: Colors.grey.shade600, fontSize: 11)),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 42,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= items.length) {
                                return const SizedBox.shrink();
                              }
                              final label = '${items[index][labelKey]}';
                              return Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                    label.length > 8
                                        ? label.substring(5)
                                        : label,
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.w600)),
                              );
                            },
                          ),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: const Color(0xFF00A884),
                          barWidth: 4,
                          isStrokeCapRound: true,
                          belowBarData: BarAreaData(
                              show: true,
                              color: const Color(0xFF00A884)
                                  .withValues(alpha: .12)),
                          dotData: FlDotData(
                            getDotPainter: (spot, percent, bar, index) =>
                                FlDotCirclePainter(
                              radius: 4,
                              color: Colors.white,
                              strokeWidth: 3,
                              strokeColor: const Color(0xFF00A884),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _DonutChartCard extends StatelessWidget {
  const _DonutChartCard({required this.stats});

  final Map<String, dynamic> stats;

  @override
  Widget build(BuildContext context) {
    final pending = ((stats['pendingLeaves'] ?? 0) as num).toDouble();
    final approved = ((stats['approvedLeaves'] ?? 0) as num).toDouble();
    final total = pending + approved;
    final sections = [
      _DonutSlice('Approuves', approved, const Color(0xFF00A884)),
      _DonutSlice('En attente', pending, const Color(0xFFF59E0B)),
      if (total == 0) _DonutSlice('Aucune donnee', 1, Colors.grey.shade300),
    ];
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ChartHeader(
              title: 'Etat des conges',
              subtitle: 'Validation des demandes',
              icon: Icons.donut_large),
          const SizedBox(height: 18),
          SizedBox(
            height: 300,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      centerSpaceRadius: 58,
                      sectionsSpace: 4,
                      sections: [
                        for (final slice in sections)
                          PieChartSectionData(
                            value: slice.value,
                            color: slice.color,
                            radius: 34,
                            showTitle: false,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                SizedBox(
                  width: 170,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${total.toInt()}',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w900)),
                      Text('demandes suivies',
                          style: TextStyle(color: Colors.grey.shade700)),
                      const SizedBox(height: 18),
                      for (final slice
                          in sections.where((s) => s.label != 'Aucune donnee'))
                        _LegendItem(
                            label: slice.label,
                            value: slice.value.toInt().toString(),
                            color: slice.color),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartHeader extends StatelessWidget {
  const _ChartHeader(
      {required this.title, required this.subtitle, required this.icon});

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
              color: const Color(0xFF0A6ED1).withValues(alpha: .10),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: const Color(0xFF0A6ED1), size: 21),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w900)),
              Text(subtitle,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem(
      {required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(
              child:
                  Text(label, style: TextStyle(color: Colors.grey.shade700))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _DonutSlice {
  _DonutSlice(this.label, this.value, this.color);

  final String label;
  final double value;
  final Color color;
}

class _DashboardData {
  _DashboardData(
      {required this.stats,
      required this.departments,
      required this.leaves,
      required this.attendance});
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
