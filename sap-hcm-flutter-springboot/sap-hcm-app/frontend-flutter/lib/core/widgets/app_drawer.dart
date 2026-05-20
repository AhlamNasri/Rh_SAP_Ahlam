import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../theme/app_theme.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final menu = _menu.where((item) => item.allowed(auth.roles)).toList();
    final location = GoRouterState.of(context).matchedLocation;
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(color: AppTheme.sapBlue, borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.business_center, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Application RH', style: TextStyle(fontWeight: FontWeight.w800)),
                        Text('SAP HCM', style: TextStyle(color: Colors.grey.shade700)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: menu
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: ListTile(
                          selected: location == item.route,
                          selectedTileColor: AppTheme.sapBlue.withOpacity(.10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          leading: Icon(item.icon),
                          title: Text(item.label),
                          onTap: () {
                            Navigator.of(context).maybePop();
                            context.go(item.route);
                          },
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(auth.user?.fullName ?? auth.user?.email ?? '-'),
              subtitle: Text(auth.roles.join(', ')),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => auth.logout(),
                  icon: const Icon(Icons.logout),
                  label: const Text('Deconnexion'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  _MenuItem(this.label, this.route, this.icon, this.roles);
  final String label;
  final String route;
  final IconData icon;
  final List<String> roles;
  bool allowed(List<String> userRoles) => roles.isEmpty || roles.any(userRoles.contains);
}

final _menu = [
  _MenuItem('Dashboard RH', '/dashboard', Icons.dashboard_outlined, []),
  _MenuItem('Profil Employe', '/profile', Icons.badge_outlined, []),
  _MenuItem('Gestion des Conges', '/leaves', Icons.beach_access_outlined, []),
  _MenuItem('Pointage / Presences', '/attendance', Icons.access_time, []),
  _MenuItem('Gestion de la Paie', '/payroll', Icons.payments_outlined, ['EMPLOYEE', 'HR', 'ADMIN']),
  _MenuItem('Recrutement', '/recruitment', Icons.work_outline, ['HR', 'ADMIN']),
  _MenuItem('Administration RH', '/admin', Icons.admin_panel_settings_outlined, ['HR', 'ADMIN']),
  _MenuItem('Evaluations', '/performance', Icons.grade_outlined, []),
  _MenuItem('Formations', '/training', Icons.school_outlined, []),
  _MenuItem('Organigramme', '/organization', Icons.account_tree_outlined, []),
  _MenuItem('Rapports RH', '/reports', Icons.summarize_outlined, ['HR', 'ADMIN']),
];
