import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController(text: 'employee@test.com');
  final _password = TextEditingController(text: 'password');
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await context.read<AuthProvider>().login(_email.text.trim(), _password.text);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<AuthProvider>().error ?? 'Identifiants invalides')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.darkBlue, AppTheme.sapBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: LayoutBuilder(builder: (context, constraints) {
                final narrow = constraints.maxWidth < 760;
                final hero = _HeroPanel(narrow: narrow);
                final form = _LoginCard(
                  formKey: _formKey,
                  email: _email,
                  password: _password,
                  obscure: _obscure,
                  onToggle: () => setState(() => _obscure = !_obscure),
                  onSubmit: auth.isLoading ? null : _submit,
                  isLoading: auth.isLoading,
                );
                return narrow
                    ? Column(children: [hero, const SizedBox(height: 24), form])
                    : Row(children: [Expanded(child: hero), const SizedBox(width: 32), Expanded(child: form)]);
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.narrow});
  final bool narrow;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: narrow ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        const Icon(Icons.business_center, color: Colors.white, size: 64),
        const SizedBox(height: 24),
        Text(
          'Application RH — SAP HCM',
          textAlign: narrow ? TextAlign.center : TextAlign.left,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        Text(
          'Demo professionnelle: JWT, roles, conges, pointage, paie, recrutement, formations et reporting RH.',
          textAlign: narrow ? TextAlign.center : TextAlign.left,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white.withOpacity(.85)),
        ),
      ],
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.formKey,
    required this.email,
    required this.password,
    required this.obscure,
    required this.onToggle,
    required this.onSubmit,
    required this.isLoading,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController email;
  final TextEditingController password;
  final bool obscure;
  final VoidCallback onToggle;
  final VoidCallback? onSubmit;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Connexion', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text('Connectez-vous avec un compte de test.', style: TextStyle(color: Colors.grey.shade700)),
              const SizedBox(height: 24),
              AppTextField(
                controller: email,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v == null || !v.contains('@') ? 'Email invalide' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: password,
                obscureText: obscure,
                validator: (v) => v == null || v.length < 6 ? 'Mot de passe requis' : null,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(onPressed: onToggle, icon: Icon(obscure ? Icons.visibility : Icons.visibility_off)),
                ),
              ),
              Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () {}, child: const Text('Mot de passe oublie ?'))),
              const SizedBox(height: 8),
              AppButton(label: isLoading ? 'Connexion...' : 'Se connecter', icon: Icons.login, onPressed: onSubmit),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  _AccountChip('EMPLOYEE', 'employee@test.com'),
                  _AccountChip('MANAGER', 'manager@test.com'),
                  _AccountChip('HR', 'hr@test.com'),
                  _AccountChip('ADMIN', 'admin@test.com'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountChip extends StatelessWidget {
  const _AccountChip(this.role, this.email);
  final String role;
  final String email;

  @override
  Widget build(BuildContext context) => Chip(label: Text('$role: $email'));
}
