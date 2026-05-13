import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';

class WorkingHoursForm extends StatefulWidget {
  final Map<String, String?> initialValues;
  final ValueChanged<Map<String, String?>> onChanged;

  const WorkingHoursForm({
    super.key,
    required this.initialValues,
    required this.onChanged,
  });

  @override
  State<WorkingHoursForm> createState() => _WorkingHoursFormState();
}

class _WorkingHoursFormState extends State<WorkingHoursForm> {
  static const _days = [
    'monday', 'tuesday', 'wednesday', 'thursday',
    'friday', 'saturday', 'sunday',
  ];
  static const _dayLabels = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday',
  ];

  late Map<String, bool> _open;
  late Map<String, TimeOfDay> _start;
  late Map<String, TimeOfDay> _end;

  @override
  void initState() {
    super.initState();
    _open = {};
    _start = {};
    _end = {};
    for (final day in _days) {
      final val = widget.initialValues[day];
      if (val != null && val.contains('-')) {
        _open[day] = true;
        final parts = val.split('-');
        _start[day] = _parseTime(parts[0]);
        _end[day] = _parseTime(parts[1]);
      } else {
        _open[day] = false;
        _start[day] = const TimeOfDay(hour: 8, minute: 0);
        _end[day] = const TimeOfDay(hour: 17, minute: 0);
      }
    }
  }

  TimeOfDay _parseTime(String s) {
    final parts = s.trim().split(':');
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 8,
      minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
    );
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  void _notify() {
    final result = <String, String?>{};
    for (final day in _days) {
      result[day] = _open[day] == true
          ? '${_formatTime(_start[day]!)}-${_formatTime(_end[day]!)}'
          : null;
    }
    widget.onChanged(result);
  }

  Future<void> _pickTime(
      BuildContext context, String day, bool isStart) async {
    final initial = isStart ? _start[day]! : _end[day]!;
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _start[day] = picked;
      } else {
        _end[day] = picked;
      }
    });
    _notify();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Working Hours',
            style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.neutral200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: List.generate(_days.length, (i) {
              final day = _days[i];
              final label = _dayLabels[i];
              final isLast = i == _days.length - 1;
              final isOn = _open[day] ?? false;
              return Container(
                decoration: BoxDecoration(
                  border: isLast
                      ? null
                      : Border(
                          bottom: BorderSide(color: AppColors.neutral100)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 90,
                      child: Text(label,
                          style: AppTypography.bodySmall.copyWith(
                            color: isOn
                                ? AppColors.neutral800
                                : AppColors.neutral400,
                          )),
                    ),
                    Switch(
                      value: isOn,
                      onChanged: (v) {
                        setState(() => _open[day] = v);
                        _notify();
                      },
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    if (isOn) ...[
                      const SizedBox(width: 12),
                      _TimeButton(
                        label: _formatTime(_start[day]!),
                        onTap: () => _pickTime(context, day, true),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text('–',
                            style: AppTypography.bodySmall
                                .copyWith(color: AppColors.neutral400)),
                      ),
                      _TimeButton(
                        label: _formatTime(_end[day]!),
                        onTap: () => _pickTime(context, day, false),
                      ),
                    ] else
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Text('Closed',
                            style: AppTypography.caption
                                .copyWith(color: AppColors.neutral400)),
                      ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _TimeButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _TimeButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.neutral300),
          borderRadius: BorderRadius.circular(6),
          color: AppColors.neutral50,
        ),
        child: Text(label,
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.neutral800,
            )),
      ),
    );
  }
}
