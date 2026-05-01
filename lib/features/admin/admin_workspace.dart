import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/shell/workspace_shell.dart';

class AdminWorkspace extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AdminWorkspace({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return WorkspaceShell(
      branding: WorkspaceBranding.admin,
      navigationShell: navigationShell,
    );
  }
}
