import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class _PaletteAction {
  final String label;
  final String? description;
  final IconData icon;
  final VoidCallback action;

  const _PaletteAction({
    required this.label,
    required this.description,
    required this.icon,
    required this.action,
  });
}

class CommandPalette extends StatefulWidget {
  const CommandPalette({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => const CommandPalette(),
    );
  }

  @override
  State<CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends State<CommandPalette> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  int _selectedIndex = 0;
  String _query = '';

  final List<_PaletteAction> _allActions = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<_PaletteAction> get _filtered {
    if (_query.isEmpty) return _allActions;
    final q = _query.toLowerCase();
    return _allActions
        .where((a) =>
            a.label.toLowerCase().contains(q) ||
            (a.description?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  void _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    final filtered = _filtered;
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() =>
          _selectedIndex = (_selectedIndex + 1) % filtered.length.clamp(1, 999));
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() =>
          _selectedIndex = (_selectedIndex - 1 + filtered.length).remainder(filtered.length.clamp(1, 999)));
    } else if (event.logicalKey == LogicalKeyboardKey.enter) {
      if (_selectedIndex < filtered.length) {
        filtered[_selectedIndex].action();
        Navigator.of(context).pop();
      }
    } else if (event.logicalKey == LogicalKeyboardKey.escape) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: _handleKey,
        child: Container(
          width: 560,
          constraints: const BoxConstraints(maxHeight: 480),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.neutral200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(40),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSearchInput(),
              if (filtered.isNotEmpty) const Divider(height: 1),
              if (filtered.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    _query.isEmpty
                        ? 'Type to search...'
                        : 'No results for "$_query"',
                    style: AppTypography.bodySmall.copyWith(
                        color: AppColors.neutral400),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) =>
                        _buildActionTile(filtered[i], i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const FaIcon(FontAwesomeIcons.magnifyingGlass,
              size: 16, color: AppColors.neutral400),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: const InputDecoration(
                hintText: 'Search pages, actions...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: AppTypography.body,
              onChanged: (v) => setState(() {
                _query = v;
                _selectedIndex = 0;
              }),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text('Esc',
                style: AppTypography.caption.copyWith(
                    color: AppColors.neutral400)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(_PaletteAction action, int index) {
    final isSelected = index == _selectedIndex;
    return MouseRegion(
      onEnter: (_) => setState(() => _selectedIndex = index),
      child: GestureDetector(
        onTap: () {
          action.action();
          Navigator.of(context).pop();
        },
        child: Container(
          color: isSelected ? AppColors.primaryLight.withAlpha(80) : null,
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                    child: FaIcon(action.icon,
                        size: 12, color: AppColors.neutral500)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(action.label, style: AppTypography.bodySmall),
                    if (action.description != null)
                      Text(action.description!,
                          style: AppTypography.caption
                              .copyWith(color: AppColors.neutral400)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
