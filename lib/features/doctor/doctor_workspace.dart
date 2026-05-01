import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/shell/workspace_shell.dart';

class DoctorWorkspace extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const DoctorWorkspace({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return WorkspaceShell(
      branding: WorkspaceBranding.doctor,
      navigationShell: navigationShell,
    );
  }
}
