import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

class SideDrawer extends StatefulWidget {
  final String title;
  final Widget body;
  final List<Widget>? footerActions;
  final double width;

  const SideDrawer({
    super.key,
    required this.title,
    required this.body,
    this.footerActions,
    this.width = AppSpacing.drawerWidth,
  });

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required Widget body,
    List<Widget>? footerActions,
    double width = AppSpacing.drawerWidth,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close drawer',
      barrierColor: Colors.black38,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (ctx, anim, _) => SideDrawer(
        title: title,
        body: body,
        footerActions: footerActions,
        width: width,
      ),
      transitionBuilder: (ctx, anim, _, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
    );
  }

  @override
  State<SideDrawer> createState() => _SideDrawerState();
}

class _SideDrawerState extends State<SideDrawer> {
  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          Navigator.of(context).pop();
        }
      },
      child: Align(
        alignment: Alignment.centerRight,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: widget.width,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                  left: BorderSide(color: AppColors.neutral200)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(30),
                  blurRadius: 24,
                  offset: const Offset(-4, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildHeader(context),
                const Divider(height: 1),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: widget.body,
                  ),
                ),
                if (widget.footerActions != null) ...[
                  const Divider(height: 1),
                  _buildFooter(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(widget.title,
                style: AppTypography.h2.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                )),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () => Navigator.of(context).pop(),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: widget.footerActions!
            .expand((w) => [w, const SizedBox(width: 8)])
            .toList()
          ..removeLast(),
      ),
    );
  }
}
