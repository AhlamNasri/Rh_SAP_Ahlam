import 'package:flutter/material.dart';

import 'app_drawer.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({super.key, required this.title, required this.child, this.actions});

  final String title;
  final Widget child;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final showSidebar = width >= 1100;
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      drawer: showSidebar ? null : const AppDrawer(),
      body: Row(
        children: [
          if (showSidebar) const SizedBox(width: 300, child: AppDrawer()),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(width < 700 ? 16 : 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1400),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
