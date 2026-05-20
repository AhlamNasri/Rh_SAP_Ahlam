import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/presentation/pages/admin_page.dart';
import '../../features/attendance/presentation/pages/attendance_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/leaves/presentation/pages/leaves_page.dart';
import '../../features/organization/presentation/pages/organization_page.dart';
import '../../features/payroll/presentation/pages/payroll_page.dart';
import '../../features/performance/presentation/pages/performance_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/recruitment/presentation/pages/recruitment_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/training/presentation/pages/training_page.dart';
import '../widgets/main_layout.dart';

class AppRouter {
  static GoRouter create(AuthProvider auth) {
    return GoRouter(
      refreshListenable: auth,
      initialLocation: '/dashboard',
      redirect: (context, state) {
        final isLogin = state.matchedLocation == '/login';
        if (auth.isLoading) return null;
        if (!auth.isAuthenticated) return isLogin ? null : '/login';
        if (isLogin) return '/dashboard';
        return null;
      },
      routes: [
        GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
        _appRoute('/dashboard', 'Dashboard RH', const DashboardPage()),
        _appRoute('/profile', 'Profil Employe', const ProfilePage()),
        _appRoute('/leaves', 'Gestion des Conges', const LeavesPage()),
        _appRoute('/attendance', 'Pointage / Presences', const AttendancePage()),
        _appRoute('/payroll', 'Gestion de la Paie', const PayrollPage()),
        _appRoute('/recruitment', 'Recrutement', const RecruitmentPage()),
        _appRoute('/admin', 'Administration RH', const AdminPage()),
        _appRoute('/performance', 'Evaluation des Performances', const PerformancePage()),
        _appRoute('/training', 'Suivi des Formations', const TrainingPage()),
        _appRoute('/organization', 'Organigramme', const OrganizationPage()),
        _appRoute('/reports', 'Rapports RH / Export', const ReportsPage()),
      ],
      errorBuilder: (context, state) => MainLayout(
        title: 'Page introuvable',
        child: Center(child: Text(state.error.toString())),
      ),
    );
  }

  static GoRoute _appRoute(String path, String title, Widget page) {
    return GoRoute(
      path: path,
      builder: (context, state) => MainLayout(title: title, child: page),
    );
  }
}
