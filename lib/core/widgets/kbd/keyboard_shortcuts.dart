import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../command_palette/command_palette.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class GlobalShortcutsWidget extends StatelessWidget {
  final Widget child;
  const GlobalShortcutsWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyK):
            const _OpenCommandPaletteIntent(),
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyK):
            const _OpenCommandPaletteIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.slash):
            const _ShowShortcutsHelpIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.shift,
                LogicalKeyboardKey.keyL):
            const _ToggleThemeIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyB):
            const _ToggleSidebarIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.comma):
            const _OpenSettingsIntent(),
      },
      child: Actions(
        actions: {
          _OpenCommandPaletteIntent: CallbackAction<_OpenCommandPaletteIntent>(
            onInvoke: (_) => CommandPalette.show(context),
          ),
          _ShowShortcutsHelpIntent: CallbackAction<_ShowShortcutsHelpIntent>(
            onInvoke: (_) => _showShortcutsDialog(context),
          ),
          _ToggleThemeIntent: CallbackAction<_ToggleThemeIntent>(
            onInvoke: (_) => null,
          ),
          _ToggleSidebarIntent: CallbackAction<_ToggleSidebarIntent>(
            onInvoke: (_) => null,
          ),
          _OpenSettingsIntent: CallbackAction<_OpenSettingsIntent>(
            onInvoke: (_) => null,
          ),
        },
        child: child,
      ),
    );
  }

  void _showShortcutsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const _ShortcutsHelpDialog(),
    );
  }
}

class _ShortcutsHelpDialog extends StatelessWidget {
  const _ShortcutsHelpDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.keyboard, size: 20),
                  const SizedBox(width: 8),
                  Text('Keyboard Shortcuts',
                      style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ShortcutSection('Global', [
                        ('Ctrl+K', 'Open command palette'),
                        ('Ctrl+/', 'Show keyboard shortcuts'),
                        ('Ctrl+Shift+L', 'Toggle light/dark theme'),
                        ('Esc', 'Close dialog or drawer'),
                      ]),
                      _ShortcutSection('Navigation', [
                        ('Ctrl+B', 'Toggle sidebar'),
                        ('Ctrl+,', 'Open settings'),
                        ('Ctrl+1–9', 'Jump to sidebar tab'),
                        ('Alt+Left', 'Navigate back'),
                        ('Alt+Right', 'Navigate forward'),
                      ]),
                      _ShortcutSection('Tables', [
                        ('Ctrl+A', 'Select all rows'),
                        ('Shift+Click', 'Range select rows'),
                        ('Delete', 'Remove selected rows'),
                        ('Ctrl+F', 'Focus search/filter'),
                        ('Enter', 'Open selected row detail'),
                      ]),
                      _ShortcutSection('Forms', [
                        ('Ctrl+Enter', 'Submit form'),
                        ('Ctrl+Z', 'Undo last change'),
                        ('Tab', 'Move to next field'),
                        ('Shift+Tab', 'Move to previous field'),
                      ]),
                      _ShortcutSection('Queue (Admin)', [
                        ('Space', 'Call next patient'),
                        ('Ctrl+N', 'New walk-in'),
                      ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShortcutSection extends StatelessWidget {
  final String title;
  final List<(String, String)> items;

  const _ShortcutSection(this.title, this.items);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: Theme.of(context).colorScheme.primary)),
          const SizedBox(height: 8),
          ...items.map((item) => _ShortcutRow(item.$1, item.$2)),
        ],
      ),
    );
  }
}

class _ShortcutRow extends StatelessWidget {
  final String keys;
  final String description;
  const _ShortcutRow(this.keys, this.description);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.neutral300),
            ),
            child: Text(keys,
                style: AppTypography.mono.copyWith(fontSize: 12)),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Text(description, style: AppTypography.bodySmall)),
        ],
      ),
    );
  }
}

class _OpenCommandPaletteIntent extends Intent {
  const _OpenCommandPaletteIntent();
}

class _ShowShortcutsHelpIntent extends Intent {
  const _ShowShortcutsHelpIntent();
}

class _ToggleThemeIntent extends Intent {
  const _ToggleThemeIntent();
}

class _ToggleSidebarIntent extends Intent {
  const _ToggleSidebarIntent();
}

class _OpenSettingsIntent extends Intent {
  const _OpenSettingsIntent();
}
