import 'package:flutter/material.dart';
import '../widgets/drawers/side_drawer.dart';
import '../widgets/command_palette/command_palette.dart';
import '../widgets/dialogs/confirm_dialog.dart';

extension AppContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  Future<T?> showSideDrawer<T>({
    required String title,
    required Widget child,
    List<Widget>? footerActions,
    double? width,
  }) {
    return SideDrawer.show<T>(
      this,
      title: title,
      body: child,
      footerActions: footerActions,
      width: width ?? 480,
    );
  }

  void showCommandPalette() => CommandPalette.show(this);

  Future<bool> showConfirm({
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    bool isDangerous = false,
  }) {
    return ConfirmDialog.show(
      this,
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      isDangerous: isDangerous,
    );
  }

  Future<T?> showFormDialog<T>(Widget child) {
    return showDialog<T>(
      context: this,
      builder: (_) => Dialog(child: child),
    );
  }
}
