import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';

class ChipInputField extends StatefulWidget {
  final String label;
  final String hint;
  final List<String> values;
  final ValueChanged<List<String>> onChanged;

  const ChipInputField({
    super.key,
    required this.label,
    required this.hint,
    required this.values,
    required this.onChanged,
  });

  @override
  State<ChipInputField> createState() => _ChipInputFieldState();
}

class _ChipInputFieldState extends State<ChipInputField> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _addChip(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || widget.values.contains(trimmed)) {
      _ctrl.clear();
      return;
    }
    widget.onChanged([...widget.values, trimmed]);
    _ctrl.clear();
  }

  void _removeChip(String value) {
    widget.onChanged(widget.values.where((v) => v != value).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.neutral300),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.values.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: widget.values.map((v) {
                    return Chip(
                      label: Text(v, style: AppTypography.caption),
                      deleteIcon: const Icon(Icons.close, size: 14),
                      onDeleted: () => _removeChip(v),
                      backgroundColor: AppColors.primaryLight.withAlpha(80),
                      side: BorderSide.none,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
              if (widget.values.isNotEmpty) const SizedBox(height: 6),
              KeyboardListener(
                focusNode: FocusNode(),
                onKeyEvent: (event) {
                  if (event is KeyDownEvent &&
                      event.logicalKey == LogicalKeyboardKey.enter) {
                    _addChip(_ctrl.text);
                  }
                },
                child: TextField(
                  controller: _ctrl,
                  focusNode: _focus,
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: AppTypography.caption.copyWith(color: AppColors.neutral400),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.add, size: 16),
                      onPressed: () => _addChip(_ctrl.text),
                      tooltip: 'Add',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  style: AppTypography.bodySmall,
                  onSubmitted: _addChip,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
