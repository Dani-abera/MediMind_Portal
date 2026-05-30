import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/shell/page_header.dart';
import '../../domain/entities/medication.dart';
import '../../domain/repositories/prescription_repository.dart';
import '../bloc/create_prescription/create_prescription_bloc.dart';

class CreatePrescriptionPage extends StatelessWidget {
  final String? patientId;
  const CreatePrescriptionPage({super.key, this.patientId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CreatePrescriptionBloc>(),
      child: BlocListener<CreatePrescriptionBloc, CreatePrescriptionState>(
        listener: (ctx, state) {
          if (state is CreatePrescriptionSuccess) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              const SnackBar(
                  content: Text('Prescription created successfully')),
            );
            ctx.pop();
          } else if (state is CreatePrescriptionFailure) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.danger),
            );
          }
        },
        child: _CreatePrescriptionForm(patientId: patientId),
      ),
    );
  }
}

class _MedicationEntry {
  String name = '';
  String dosage = '';
  MedicationFrequency frequency = MedicationFrequency.onceDaily;
  String duration = '';
  String? instructions;
}

class _CreatePrescriptionForm extends StatefulWidget {
  final String? patientId;
  const _CreatePrescriptionForm({this.patientId});

  @override
  State<_CreatePrescriptionForm> createState() =>
      _CreatePrescriptionFormState();
}

class _CreatePrescriptionFormState extends State<_CreatePrescriptionForm> {
  final _patientIdCtrl = TextEditingController();
  final _diagnosisCtrl = TextEditingController();
  final _followUpCtrl = TextEditingController();
  final _specialCtrl = TextEditingController();
  final _labTestCtrl = TextEditingController();
  final _medications = <_MedicationEntry>[_MedicationEntry()];
  final _labTests = <String>[];
  DateTime? _expiresAt;

  @override
  void initState() {
    super.initState();
    if (widget.patientId != null) {
      _patientIdCtrl.text = widget.patientId!;
    }
  }

  @override
  void dispose() {
    _patientIdCtrl.dispose();
    _diagnosisCtrl.dispose();
    _followUpCtrl.dispose();
    _specialCtrl.dispose();
    _labTestCtrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext ctx) {
    final meds = _medications
        .where((m) => m.name.isNotEmpty && m.dosage.isNotEmpty)
        .map((m) => Medication(
              name: m.name,
              dosage: m.dosage,
              frequency: m.frequency,
              duration: m.duration.isNotEmpty ? m.duration : '7 days',
              instructions: m.instructions,
            ))
        .toList();

    if (_patientIdCtrl.text.isEmpty || _diagnosisCtrl.text.isEmpty || meds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill patient, diagnosis and at least one medication')),
      );
      return;
    }

    ctx.read<CreatePrescriptionBloc>().add(
          CreatePrescriptionSubmitted(
            CreatePrescriptionParams(
              patientId: _patientIdCtrl.text.trim(),
              diagnosis: _diagnosisCtrl.text.trim(),
              medications: meds,
              labTests: _labTests,
              followUpInstructions: _followUpCtrl.text.trim().isEmpty
                  ? null
                  : _followUpCtrl.text.trim(),
              specialInstructions: _specialCtrl.text.trim().isEmpty
                  ? null
                  : _specialCtrl.text.trim(),
              expiresAt: _expiresAt,
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PageHeader(
          title: 'New Prescription',
          leading: BackButton(onPressed: () => context.pop()),
          actions: [
            BlocBuilder<CreatePrescriptionBloc, CreatePrescriptionState>(
              builder: (ctx, state) => FilledButton.icon(
                icon: state is CreatePrescriptionInProgress
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const FaIcon(FontAwesomeIcons.fileCircleCheck, size: 13),
                label: const Text('Issue Prescription'),
                onPressed: state is CreatePrescriptionInProgress
                    ? null
                    : () => _submit(ctx),
              ),
            ),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection('Patient', _buildPatientSection()),
                  _buildSection('Diagnosis', _buildDiagnosisSection()),
                  _buildSection('Medications', _buildMedicationsSection()),
                  _buildSection('Lab Tests', _buildLabTestsSection()),
                  _buildSection('Instructions', _buildInstructionsSection()),
                  _buildSection('Expiry', _buildExpirySection()),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.h3),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildPatientSection() {
    return TextField(
      controller: _patientIdCtrl,
      decoration: const InputDecoration(
        hintText: 'Patient ID or search by name...',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.search, size: 18),
        isDense: true,
      ),
    );
  }

  Widget _buildDiagnosisSection() {
    return TextField(
      controller: _diagnosisCtrl,
      decoration: const InputDecoration(
        hintText: 'Primary diagnosis',
        border: OutlineInputBorder(),
        isDense: true,
      ),
    );
  }

  Widget _buildMedicationsSection() {
    return Column(
      children: [
        ..._medications.asMap().entries.map((e) =>
            _MedicationRow(
              index: e.key,
              entry: e.value,
              onRemove: _medications.length > 1
                  ? () => setState(() => _medications.removeAt(e.key))
                  : null,
              onChanged: () => setState(() {}),
            )),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Add Medication'),
          onPressed: () =>
              setState(() => _medications.add(_MedicationEntry())),
        ),
      ],
    );
  }

  Widget _buildLabTestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _labTestCtrl,
                decoration: const InputDecoration(
                  hintText: 'Add lab test (press Enter)',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onSubmitted: (v) {
                  if (v.trim().isEmpty) return;
                  setState(() {
                    _labTests.add(v.trim());
                    _labTestCtrl.clear();
                  });
                },
              ),
            ),
          ],
        ),
        if (_labTests.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _labTests
                .asMap()
                .entries
                .map((e) => Chip(
                      label: Text(e.value),
                      deleteIcon: const Icon(Icons.close, size: 14),
                      onDeleted: () =>
                          setState(() => _labTests.removeAt(e.key)),
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildInstructionsSection() {
    return Column(
      children: [
        TextField(
          controller: _followUpCtrl,
          decoration: const InputDecoration(
            labelText: 'Follow-up instructions',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _specialCtrl,
          decoration: const InputDecoration(
            labelText: 'Special instructions',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildExpirySection() {
    return Row(
      children: [
        Text(
          _expiresAt != null
              ? 'Expires: ${DateFormat('MMM d, y').format(_expiresAt!)}'
              : 'No expiry set (defaults to 30 days)',
          style: AppTypography.bodySmall,
        ),
        const SizedBox(width: 12),
        TextButton.icon(
          icon: const Icon(Icons.calendar_today, size: 14),
          label: const Text('Set Expiry'),
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now().add(const Duration(days: 30)),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) setState(() => _expiresAt = picked);
          },
        ),
      ],
    );
  }
}

class _MedicationRow extends StatelessWidget {
  final int index;
  final _MedicationEntry entry;
  final VoidCallback? onRemove;
  final VoidCallback onChanged;

  const _MedicationRow({
    required this.index,
    required this.entry,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.neutral200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  initialValue: entry.name,
                  decoration: const InputDecoration(
                    labelText: 'Medication name',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (v) {
                    entry.name = v;
                    onChanged();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  initialValue: entry.dosage,
                  decoration: const InputDecoration(
                    labelText: 'Dosage',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (v) {
                    entry.dosage = v;
                    onChanged();
                  },
                ),
              ),
              if (onRemove != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.close, size: 16, color: AppColors.danger),
                  onPressed: onRemove,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<MedicationFrequency>(
                  initialValue: entry.frequency,
                  isDense: true,
                  decoration: const InputDecoration(
                    labelText: 'Frequency',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: MedicationFrequency.values
                      .map((f) => DropdownMenuItem(
                            value: f,
                            child: Text(f.label, style: const TextStyle(fontSize: 13)),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      entry.frequency = v;
                      onChanged();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  initialValue: entry.duration,
                  decoration: const InputDecoration(
                    labelText: 'Duration',
                    hintText: '7 days',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (v) {
                    entry.duration = v;
                    onChanged();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
