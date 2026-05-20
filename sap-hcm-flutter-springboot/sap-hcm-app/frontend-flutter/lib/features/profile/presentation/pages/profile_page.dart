import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/section_title.dart';
import '../../data/services/employee_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, dynamic>> _future;
  final _phone = TextEditingController();
  final _address = TextEditingController();
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future = _load();
  }

  Future<Map<String, dynamic>> _load() => EmployeeService(context.read<ApiClient>()).me();

  Future<void> _save(Map<String, dynamic> profile) async {
    final id = (profile['id'] as num).toInt();
    final payload = Map<String, dynamic>.from(profile);
    payload['phone'] = _phone.text;
    payload['address'] = _address.text;
    await EmployeeService(context.read<ApiClient>()).update(id, payload);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil mis a jour')));
    setState(() {
      _initialized = false;
      _future = _load();
    });
  }

  @override
  void dispose() {
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) return const LoadingWidget();
        if (snapshot.hasError) return ErrorView(message: snapshot.error.toString(), onRetry: () => setState(() => _future = _load()));
        final p = snapshot.data!;
        if (!_initialized) {
          _phone.text = p['phone']?.toString() ?? '';
          _address.text = p['address']?.toString() ?? '';
          _initialized = true;
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle('Profil employe', subtitle: 'Informations personnelles modifiables et informations professionnelles en lecture seule.'),
            const SizedBox(height: 18),
            AppCard(
              child: Row(
                children: [
                  CircleAvatar(radius: 42, backgroundImage: NetworkImage(p['avatarUrl']?.toString() ?? 'https://ui-avatars.com/api/?name=RH')),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p['fullName']?.toString() ?? '-', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        Text('${p['jobTitle'] ?? '-'} • ${p['departmentName'] ?? '-'}'),
                        Text('Matricule: ${p['employeeNumber'] ?? '-'}'),
                      ],
                    ),
                  ),
                  Chip(label: Text((p['active'] == true) ? 'Actif' : 'Inactif')),
                ],
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(builder: (context, constraints) {
              final wide = constraints.maxWidth > 900;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(width: wide ? 520 : double.infinity, child: _InfoCard(title: 'Informations professionnelles', data: {
                    'Email': p['email'],
                    'Departement': p['departmentName'],
                    'Manager': p['managerName'],
                    'Date embauche': p['hireDate'],
                    'Contrat': p['contractType'],
                    'Solde annuel': '${p['annualLeaveBalance']} jours',
                  })),
                  SizedBox(
                    width: wide ? 520 : double.infinity,
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Informations personnelles', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                          const SizedBox(height: 16),
                          TextField(controller: _phone, decoration: const InputDecoration(labelText: 'Telephone')),
                          const SizedBox(height: 12),
                          TextField(controller: _address, decoration: const InputDecoration(labelText: 'Adresse'), maxLines: 2),
                          const SizedBox(height: 16),
                          AppButton(label: 'Enregistrer', icon: Icons.save, onPressed: () => _save(p)),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.data});
  final String title;
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          ...data.entries.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    SizedBox(width: 150, child: Text(e.key, style: TextStyle(color: Colors.grey.shade700))),
                    Expanded(child: Text('${e.value ?? '-'}', style: const TextStyle(fontWeight: FontWeight.w600))),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
