import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/feedback/app_loading.dart';
import '../../../../core/widgets/shell/page_header.dart';
import '../../domain/entities/health_record.dart';
import '../../domain/entities/patient.dart';
import '../../domain/entities/prediction.dart';
import '../bloc/patient_detail/patient_detail_bloc.dart';

class PatientDetailPage extends StatelessWidget {
  final String patientId;
  const PatientDetailPage({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<PatientDetailBloc>()..add(PatientDetailStarted(patientId)),
      child: const _PatientDetailView(),
    );
  }
}

class _PatientDetailView extends StatefulWidget {
  const _PatientDetailView();

  @override
  State<_PatientDetailView> createState() => _PatientDetailViewState();
}

class _PatientDetailViewState extends State<_PatientDetailView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  static const _tabs = [
    'Overview',
    'Health Records',
    'Predictions',
    'Medications',
    'Appointments',
    'Prescriptions',
    'Notes',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientDetailBloc, PatientDetailState>(
      builder: (ctx, state) {
        final patientName = state is PatientDetailLoaded
            ? state.patient.fullName
            : 'Patient';

        return Column(
          children: [
            PageHeader(
              title: patientName,
              leading: BackButton(
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh, size: 18),
                  onPressed: () => ctx
                      .read<PatientDetailBloc>()
                      .add(const PatientDetailRefreshed()),
                ),
              ],
            ),
            if (state is PatientDetailLoaded) ...[
              Container(
                color: Theme.of(context).colorScheme.surface,
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: _tabs.map((t) => Tab(text: t)).toList(),
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.neutral500,
                  indicatorColor: AppColors.primary,
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _OverviewTab(patient: state.patient),
                    _HealthRecordsTab(records: state.records),
                    _PredictionsTab(prediction: state.latestPrediction),
                    _MedicationsTab(medications: state.patient.currentMedications),
                    const _PlaceholderTab(label: 'Appointments'),
                    const _PlaceholderTab(label: 'Prescriptions'),
                    const _PlaceholderTab(label: 'Notes'),
                  ],
                ),
              ),
            ] else if (state is PatientDetailLoading ||
                state is PatientDetailInitial)
              const Expanded(child: Center(child: AppLoadingSpinner()))
            else if (state is PatientDetailError)
              Expanded(
                  child: AppErrorState(
                      message: state.message,
                      onRetry: () => ctx
                          .read<PatientDetailBloc>()
                          .add(const PatientDetailRefreshed())))
            else
              const Expanded(child: SizedBox.shrink()),
          ],
        );
      },
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final Patient patient;
  const _OverviewTab({required this.patient});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildDemographicsCard(context)),
          const SizedBox(width: 24),
          Expanded(child: _buildMedicalCard(context)),
        ],
      ),
    );
  }

  Widget _buildDemographicsCard(BuildContext context) {
    return _card(
      context,
      title: 'Demographics',
      icon: FontAwesomeIcons.user,
      children: [
        _row('Full Name', patient.fullName),
        _row('Gender', patient.gender.label),
        if (patient.age != null) _row('Age', '${patient.age} years'),
        if (patient.dateOfBirth != null)
          _row('Date of Birth',
              DateFormat('MMM d, y').format(patient.dateOfBirth!)),
        _row('Phone', patient.phone),
        if (patient.email != null) _row('Email', patient.email!),
        if (patient.bloodType != null) _row('Blood Type', patient.bloodType!),
        if (patient.address != null) _row('Address', patient.address!),
        if (patient.emergencyContact != null) ...[
          const Divider(height: 20),
          Text('Emergency Contact',
              style: AppTypography.bodyMedium),
          const SizedBox(height: 8),
          _row('Name', patient.emergencyContact!.name),
          _row('Phone', patient.emergencyContact!.phone),
          if (patient.emergencyContact!.relationship != null)
            _row('Relationship', patient.emergencyContact!.relationship!),
        ],
      ],
    );
  }

  Widget _buildMedicalCard(BuildContext context) {
    return _card(
      context,
      title: 'Medical Info',
      icon: FontAwesomeIcons.heartPulse,
      children: [
        if (patient.chronicConditions.isNotEmpty) ...[
          Text('Chronic Conditions',
              style: AppTypography.bodyMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: patient.chronicConditions
                .map((c) => Chip(
                      label: Text(c, style: const TextStyle(fontSize: 12)),
                      backgroundColor: AppColors.danger.withAlpha(10),
                      side: BorderSide(color: AppColors.danger.withAlpha(40)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
        ],
        if (patient.allergies.isNotEmpty) ...[
          Text('Allergies', style: AppTypography.bodyMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: patient.allergies
                .map((a) => Chip(
                      label: Text(a, style: const TextStyle(fontSize: 12)),
                      backgroundColor: AppColors.warning.withAlpha(10),
                      side: BorderSide(color: AppColors.warning.withAlpha(40)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
        ],
        if (patient.chronicConditions.isEmpty && patient.allergies.isEmpty)
          Text('No chronic conditions or allergies recorded.',
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.neutral400)),
      ],
    );
  }

  Widget _card(BuildContext context,
      {required String title,
      required IconData icon,
      required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(icon, size: 14, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(title, style: AppTypography.h3),
            ],
          ),
          const Divider(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.neutral500)),
          ),
          Expanded(child: Text(value, style: AppTypography.body)),
        ],
      ),
    );
  }
}

class _HealthRecordsTab extends StatelessWidget {
  final List<HealthRecord> records;
  const _HealthRecordsTab({required this.records});

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const AppEmptyState(
        message: 'No health records',
        icon: Icons.monitor_heart_outlined,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.xl),
      itemCount: records.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) => _HealthRecordCard(record: records[i]),
    );
  }
}

class _HealthRecordCard extends StatelessWidget {
  final HealthRecord record;
  const _HealthRecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('MMM d, y — HH:mm').format(record.recordedAt),
            style:
                AppTypography.bodySmall.copyWith(color: AppColors.neutral500),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              if (record.bloodPressureFormatted != null)
                _vital('BP', record.bloodPressureFormatted!,
                    FontAwesomeIcons.heartPulse),
              if (record.heartRate != null)
                _vital('HR', '${record.heartRate} bpm',
                    FontAwesomeIcons.heart),
              if (record.glucoseLevel != null)
                _vital('Glucose',
                    '${record.glucoseLevel!.toStringAsFixed(1)} mg/dL',
                    FontAwesomeIcons.droplet),
              if (record.temperature != null)
                _vital('Temp',
                    '${record.temperature!.toStringAsFixed(1)}°C',
                    FontAwesomeIcons.temperatureHalf),
              if (record.oxygenSaturation != null)
                _vital('SpO₂',
                    '${record.oxygenSaturation!.toStringAsFixed(0)}%',
                    FontAwesomeIcons.lungs),
              if (record.weight != null)
                _vital('Weight',
                    '${record.weight!.toStringAsFixed(1)} kg',
                    FontAwesomeIcons.weightScale),
            ],
          ),
        ],
      ),
    );
  }

  Widget _vital(String label, String value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FaIcon(icon, size: 12, color: AppColors.neutral400),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: AppTypography.caption
                    .copyWith(color: AppColors.neutral500, fontSize: 10)),
            Text(value, style: AppTypography.bodySmall),
          ],
        ),
      ],
    );
  }
}

class _PredictionsTab extends StatelessWidget {
  final Prediction? prediction;
  const _PredictionsTab({required this.prediction});

  @override
  Widget build(BuildContext context) {
    if (prediction == null) {
      return const AppEmptyState(
        message: 'No predictions available',
        description: 'AI predictions require sufficient health data.',
        icon: Icons.analytics_outlined,
      );
    }
    final pred = prediction!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RiskLevelCard(riskLevel: pred.riskLevel, score: pred.riskScore),
          const SizedBox(height: 24),
          Text('Condition Probabilities', style: AppTypography.h3),
          const SizedBox(height: 16),
          ...pred.conditionProbabilities.entries
              .map((e) => _ProbabilityBar(label: e.key, value: e.value)),
        ],
      ),
    );
  }
}

class _RiskLevelCard extends StatelessWidget {
  final RiskLevel riskLevel;
  final double score;
  const _RiskLevelCard({required this.riskLevel, required this.score});

  @override
  Widget build(BuildContext context) {
    final color = switch (riskLevel) {
      RiskLevel.critical => AppColors.danger,
      RiskLevel.high => AppColors.warning,
      RiskLevel.moderate => AppColors.info,
      RiskLevel.low => AppColors.success,
    };
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: color.withAlpha(10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        children: [
          FaIcon(FontAwesomeIcons.triangleExclamation,
              size: 32, color: color),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Risk Level', style: AppTypography.bodySmall),
              Text(riskLevel.name.toUpperCase(),
                  style: AppTypography.h1.copyWith(color: color)),
            ],
          ),
          const Spacer(),
          Text(
            '${(score * 100).toStringAsFixed(0)}%',
            style: AppTypography.display.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _ProbabilityBar extends StatelessWidget {
  final String label;
  final double value;
  const _ProbabilityBar({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: AppTypography.bodySmall)),
              Text('${(value * 100).toStringAsFixed(1)}%',
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.neutral500)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: AppColors.neutral200,
              valueColor: AlwaysStoppedAnimation(
                value >= 0.7 ? AppColors.danger : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicationsTab extends StatelessWidget {
  final List<String> medications;
  const _MedicationsTab({required this.medications});

  @override
  Widget build(BuildContext context) {
    if (medications.isEmpty) {
      return const AppEmptyState(
        message: 'No current medications',
        icon: Icons.medication_outlined,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.xl),
      itemCount: medications.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) => ListTile(
        leading: const FaIcon(FontAwesomeIcons.pills,
            size: 16, color: AppColors.primary),
        title: Text(medications[i], style: AppTypography.body),
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  final String label;
  const _PlaceholderTab({required this.label});

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      message: '$label — Coming Soon',
      description: 'This tab will show $label data.',
      icon: Icons.hourglass_empty,
    );
  }
}
