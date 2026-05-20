import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/section_title.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/services/admin_service.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  late Future<List<Map<String, dynamic>>> _future;
  String _role = 'TOUS';
  final _search = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future = AdminService(context.read<ApiClient>()).users();
  }

  void _refresh() => setState(() => _future = AdminService(context.read<ApiClient>()).users());

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) return const LoadingWidget();
        if (snapshot.hasError) return ErrorView(message: snapshot.error.toString(), onRetry: _refresh);
        final isAdmin = context.watch<AuthProvider>().hasRole('ADMIN');
        final users = (snapshot.data ?? []).where((u) {
          final roles = List<String>.from(u['roles'] ?? const []);
          final matchesRole = _role == 'TOUS' || roles.contains(_role);
          final text = '${u['email']} ${u['employeeName']} ${u['department']}'.toLowerCase();
          return matchesRole && text.contains(_search.text.toLowerCase());
        }).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle('Administration RH', subtitle: 'Gestion des comptes, roles et statuts utilisateur.'),
            const SizedBox(height: 18),
            AppCard(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(width: 320, child: TextField(controller: _search, onChanged: (_) => setState(() {}), decoration: const InputDecoration(labelText: 'Rechercher un utilisateur'))),
                  SizedBox(
                    width: 220,
                    child: DropdownButtonFormField<String>(
                      value: _role,
                      decoration: const InputDecoration(labelText: 'Filtrer par role'),
                      items: ['TOUS', 'EMPLOYEE', 'MANAGER', 'HR', 'ADMIN'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                      onChanged: (v) => setState(() => _role = v ?? 'TOUS'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (users.isEmpty)
              const EmptyStateWidget(title: 'Aucun utilisateur')
            else
              ...users.map((u) => AppCard(
                    child: Row(
                      children: [
                        const Icon(Icons.admin_panel_settings_outlined),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(u['email']?.toString() ?? '-', style: const TextStyle(fontWeight: FontWeight.w800)),
                            Text('${u['employeeName'] ?? '-'} • ${u['department'] ?? '-'} • cree le ${u['createdAt'] ?? '-'}'),
                          ]),
                        ),
                        ...List<String>.from(u['roles'] ?? const []).map((r) => Padding(padding: const EdgeInsets.only(right: 6), child: Chip(label: Text(r)))),
                        if (isAdmin) PopupMenuButton<String>(
                          tooltip: 'Changer role',
                          icon: const Icon(Icons.manage_accounts_outlined),
                          onSelected: (role) async {
                            await AdminService(context.read<ApiClient>()).updateRole((u['id'] as num).toInt(), role);
                            _refresh();
                          },
                          itemBuilder: (_) => ['EMPLOYEE', 'MANAGER', 'HR', 'ADMIN'].map((r) => PopupMenuItem(value: r, child: Text(r))).toList(),
                        ),
                        StatusBadge((u['enabled'] == true) ? 'ACTIF' : 'INACTIF'),
                        Switch(
                          value: u['enabled'] == true,
                          onChanged: (value) async {
                            await AdminService(context.read<ApiClient>()).updateStatus((u['id'] as num).toInt(), value);
                            _refresh();
                          },
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
