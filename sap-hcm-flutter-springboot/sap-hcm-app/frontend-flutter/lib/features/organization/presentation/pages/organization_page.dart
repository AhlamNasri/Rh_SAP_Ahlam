import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/section_title.dart';
import '../../data/services/organization_service.dart';

class OrganizationPage extends StatefulWidget {
  const OrganizationPage({super.key});

  @override
  State<OrganizationPage> createState() => _OrganizationPageState();
}

class _OrganizationPageState extends State<OrganizationPage> {
  late Future<Map<String, dynamic>> _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future = OrganizationService(context.read<ApiClient>()).tree();
  }

  void _refresh() => setState(() => _future = OrganizationService(context.read<ApiClient>()).tree());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) return const LoadingWidget();
        if (snapshot.hasError) return ErrorView(message: snapshot.error.toString(), onRetry: _refresh);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle('Organigramme', subtitle: 'Vue hierarchique Direction → Departements → Managers → Employes.'),
            const SizedBox(height: 18),
            _OrgNode(node: snapshot.data!, depth: 0),
          ],
        );
      },
    );
  }
}

class _OrgNode extends StatelessWidget {
  const _OrgNode({required this.node, required this.depth});
  final Map<String, dynamic> node;
  final int depth;

  @override
  Widget build(BuildContext context) {
    final children = List<Map<String, dynamic>>.from((node['children'] ?? const []).map((e) => Map<String, dynamic>.from(e)));
    return Padding(
      padding: EdgeInsets.only(left: depth * 22.0, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCard(
            child: Row(children: [
              Icon(node['type'] == 'DEPARTMENT' ? Icons.apartment : node['type'] == 'EMPLOYEE' ? Icons.person : Icons.account_tree_outlined),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${node['label']}', style: const TextStyle(fontWeight: FontWeight.w800)),
                  if (node['jobTitle'] != null) Text('${node['jobTitle']}'),
                ]),
              ),
              if (node['type'] == 'EMPLOYEE') TextButton(onPressed: () => context.go('/profile'), child: const Text('Voir profil')),
            ]),
          ),
          ...children.map((child) => _OrgNode(node: child, depth: depth + 1)),
        ],
      ),
    );
  }
}
