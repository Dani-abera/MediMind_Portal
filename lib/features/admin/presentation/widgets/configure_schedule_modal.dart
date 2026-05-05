import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../domain/entities/doctor_at_center.dart';

class ConfigureScheduleModal extends StatefulWidget {
  final DoctorScheduleConfig? config;
  final void Function(DoctorScheduleConfig) onSave;

  const ConfigureScheduleModal._({required this.config, required this.onSave});

  static Future<void> show(
    BuildContext context, {
    DoctorScheduleConfig? config,
    required void Function(DoctorScheduleConfig) onSave,
  }) {
    return showDialog(
      context: context,
      builder: (_) => ConfigureScheduleModal._(config: config, onSave: onSave),
    );
  }

  @override
  State<ConfigureScheduleModal> createState() => _ConfigureScheduleModalState();
}

class _ConfigureScheduleModalState extends State<ConfigureScheduleModal> {
  final _formKey = GlobalKey<FormState>();
  late Set<int> _workingDays;
  late TextEditingController _startTimeCtrl;
  late TextEditingController _endTimeCtrl;
  late TextEditingController _slotDurationCtrl;
  late List<_BreakEntry> _breaks;

  static const _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    final c = widget.config;
    _workingDays = c != null ? Set.from(c.workingDays) : {1, 2, 3, 4, 5};
    _startTimeCtrl = TextEditingController(text: c?.startTime ?? '08:00');
    _endTimeCtrl = TextEditingController(text: c?.endTime ?? '17:00');
    _slotDurationCtrl = TextEditingController(text: '${c?.slotDurationMinutes ?? 30}');
    _breaks = c?.breaks.map((b) => _BreakEntry(
      startCtrl: TextEditingController(text: b.startTime),
      endCtrl: TextEditingController(text: b.endTime),
    )).toList() ?? [];
  }

  @override
  void dispose() {
    _startTimeCtrl.dispose();
    _endTimeCtrl.dispose();
    _slotDurationCtrl.dispose();
    for (final b in _breaks) {
      b.startCtrl.dispose();
      b.endCtrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Configure Schedule'),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _sectionLabel('Working Days'),
                const SizedBox(height: AppSpacing.sm),
                _workingDaysSelector(),
                const SizedBox(height: AppSpacing.base),
                _sectionLabel('Working Hours'),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(child: _timeField('Start Time', _startTimeCtrl)),
                    const SizedBox(width: AppSpacing.base),
                    Expanded(child: _timeField('End Time', _endTimeCtrl)),
                  ],
                ),
                const SizedBox(height: AppSpacing.base),
                _sectionLabel('Slot Duration (minutes)'),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: 120,
                  child: TextFormField(
                    controller: _slotDurationCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(hintText: '30'),
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      if (n == null || n < 5 || n > 120) return '5–120';
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.base),
                Row(
                  children: [
                    _sectionLabel('Breaks'),
                    const Spacer(),
                    TextButton.icon(
                      icon: const Icon(Icons.add, size: 14),
                      label: const Text('Add Break'),
                      onPressed: () => setState(() => _breaks.add(_BreakEntry(
                        startCtrl: TextEditingController(text: '12:00'),
                        endCtrl: TextEditingController(text: '13:00'),
                      ))),
                    ),
                  ],
                ),
                ..._breaks.asMap().entries.map((entry) => _breakRow(entry.key, entry.value)),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        AppButton.primary(
          label: widget.config != null ? 'Update Schedule' : 'Save Schedule',
          onPressed: _save,
        ),
      ],
    );
  }

  Widget _workingDaysSelector() {
    return Row(
      children: List.generate(7, (i) {
        final day = i + 1;
        final selected = _workingDays.contains(day);
        return Padding(
          padding: const EdgeInsets.only(right: 6),
          child: GestureDetector(
            onTap: () => setState(() {
              if (selected) {
                _workingDays.remove(day);
              } else {
                _workingDays.add(day);
              }
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.neutral100,
                borderRadius: AppRadius.radiusMd,
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.neutral200,
                ),
              ),
              child: Center(
                child: Text(
                  _dayNames[i],
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : AppColors.neutral500,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _timeField(String label, TextEditingController ctrl) {
    return TextFormField(
      controller: ctrl,
      decoration: InputDecoration(labelText: label, hintText: 'HH:MM'),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Required';
        final parts = v.split(':');
        if (parts.length != 2) return 'HH:MM';
        final h = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        if (h == null || m == null || h > 23 || m > 59) return 'Invalid time';
        return null;
      },
    );
  }

  Widget _breakRow(int index, _BreakEntry entry) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(child: _timeField('Start', entry.startCtrl)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: _timeField('End', entry.endCtrl)),
          IconButton(
            icon: const Icon(Icons.close, size: 16, color: AppColors.danger),
            onPressed: () => setState(() => _breaks.removeAt(index)),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(label, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.neutral700));
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_workingDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one working day')),
      );
      return;
    }

    final config = DoctorScheduleConfig(
      id: widget.config?.id,
      doctorId: widget.config?.doctorId ?? '',
      centerId: widget.config?.centerId ?? '',
      workingDays: _workingDays.toList()..sort(),
      startTime: _startTimeCtrl.text.trim(),
      endTime: _endTimeCtrl.text.trim(),
      slotDurationMinutes: int.parse(_slotDurationCtrl.text.trim()),
      breaks: _breaks.map((b) => ScheduleBreakConfig(
        startTime: b.startCtrl.text.trim(),
        endTime: b.endCtrl.text.trim(),
      )).toList(),
    );

    widget.onSave(config);
    Navigator.of(context).pop();
  }
}

class _BreakEntry {
  final TextEditingController startCtrl;
  final TextEditingController endCtrl;
  _BreakEntry({required this.startCtrl, required this.endCtrl});
}
