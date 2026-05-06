import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/shell/page_header.dart';
import '../../bloc/centers/centers_bloc.dart';
import '../../bloc/platform_audit/platform_audit_bloc.dart';
import '../../../domain/entities/platform_center.dart';
import '../../../domain/usecases/get_platform_center_detail_usecase.dart';

class CenterDetailPage extends StatelessWidget {
  final String centerId;
  const CenterDetailPage({super.key, required this.centerId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<CentersBloc>()..add(CentersStarted())),
        BlocProvider(
          create: (_) => sl<PlatformAuditBloc>()..add(PlatformAuditStarted(centerId: centerId)),
        ),
      ],
      child: _CenterDetailView(centerId: centerId),
    );
  }
}

class _CenterDetailView extends StatefulWidget {
  final String centerId;
  const _CenterDetailView({required this.centerId});

  @override
  State<_CenterDetailView> createState() => _CenterDetailViewState();
}

class _CenterDetailViewState extends State<_CenterDetailView> {
  PlatformCenter? _center;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    final useCase = sl<GetPlatformCenterDetailUseCase>();
    final result = await useCase(widget.centerId);
    if (mounted) {
      setState(() {
        _loading = false;
        result.fold(
          (f) => _error = f.message,
          (c) => _center = c,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(body: Center(child: Text(_error!, style: TextStyle(color: AppColors.danger))));
    }

    final center = _center!;
    final etb = NumberFormat('#,###.0');

    return Column(
      children: [
        PageHeader(
          title: center.name,
          subtitle: '${center.type} · ${center.city}, ${center.region}',
        ),
        Expanded(
          child: DefaultTabController(
            length: 3,
            child: Column(
              children: [
                const TabBar(tabs: [
                  Tab(text: 'Overview'),
                  Tab(text: 'Subscription'),
                  Tab(text: 'Audit'),
                ]),
                Expanded(
                  child: TabBarView(children: [
                    _OverviewTab(center: center, etb: etb),
                    _SubscriptionTab(center: center),
                    _AuditTab(centerId: widget.centerId),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final PlatformCenter center;
  final NumberFormat etb;
  const _OverviewTab({required this.center, required this.etb});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Basic Info', style: AppTypography.h3),
                  const SizedBox(height: AppSpacing.base),
                  _row('Admin', '${center.adminName} (${center.adminEmail})'),
                  _row('License', center.licenseNumber),
                  _row('License Verified', center.licenseVerified ? 'Yes' : 'No'),
                  _row('Doctors', '${center.doctorCount}'),
                  _row('Patients', '${center.patientCount}'),
                  _row('Created', DateFormat('MMM d, yyyy').format(center.createdAt)),
                  if (center.lastActivityAt != null)
                    _row('Last Activity', DateFormat('MMM d, yyyy HH:mm').format(center.lastActivityAt!)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Row(
          children: [
            SizedBox(width: 140, child: Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.neutral500))),
            Expanded(child: Text(value, style: AppTypography.bodySmall)),
          ],
        ),
      );
}

class _SubscriptionTab extends StatelessWidget {
  final PlatformCenter center;
  const _SubscriptionTab({required this.center});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Subscription', style: AppTypography.h3),
              const SizedBox(height: AppSpacing.base),
              _row('Plan', center.subscriptionStatus),
              _row('Status', center.status.name),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Row(
          children: [
            SizedBox(width: 140, child: Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.neutral500))),
            Expanded(child: Text(value, style: AppTypography.bodySmall)),
          ],
        ),
      );
}

class _AuditTab extends StatelessWidget {
  final String centerId;
  const _AuditTab({required this.centerId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlatformAuditBloc, PlatformAuditState>(
      builder: (ctx, state) {
        if (state is PlatformAuditLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is PlatformAuditError) {
          return Center(child: Text(state.message, style: TextStyle(color: AppColors.danger)));
        }
        if (state is PlatformAuditLoaded) {
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.base),
            itemCount: state.entries.length,
            itemBuilder: (_, i) {
              final entry = state.entries[i];
              return ListTile(
                title: Text(entry.action, style: AppTypography.bodySmall),
                subtitle: Text(
                  '${entry.userName} · ${DateFormat('MMM d HH:mm').format(entry.timestamp)}',
                  style: AppTypography.caption.copyWith(color: AppColors.neutral400),
                ),
                dense: true,
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
