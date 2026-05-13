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
          create: (_) =>
              sl<PlatformAuditBloc>()..add(PlatformAuditStarted(centerId: centerId)),
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
        result.fold((f) => _error = f.message, (c) => _center = c);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
          body: Center(
              child: Text(_error!,
                  style: TextStyle(color: AppColors.danger))));
    }

    final center = _center!;

    return BlocListener<CentersBloc, CentersState>(
      listener: (ctx, state) {
        if (state is CentersActionSuccess) {
          ScaffoldMessenger.of(ctx)
              .showSnackBar(SnackBar(content: Text(state.message)));
          _loadDetail();
        }
        if (state is CentersActionError) {
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: AppColors.danger,
          ));
        }
      },
      child: Column(
        children: [
          PageHeader(
            title: center.name,
            subtitle: '${center.type} · ${center.city}, ${center.region}',
            actions: [_ActionButtons(center: center)],
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
                      _OverviewTab(center: center),
                      _SubscriptionTab(center: center),
                      _AuditTab(centerId: widget.centerId),
                    ]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Action buttons in page header
// ─────────────────────────────────────────────────────────────
class _ActionButtons extends StatelessWidget {
  final PlatformCenter center;
  const _ActionButtons({required this.center});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (center.status == CenterStatus.pending) ...[
          FilledButton.icon(
            icon: const Icon(Icons.check, size: 16),
            label: const Text('Approve'),
            onPressed: () => _showApproveDialog(context),
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.success,
                visualDensity: VisualDensity.compact),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.close, size: 16),
            label: const Text('Reject'),
            onPressed: () => _showRejectDialog(context),
            style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.danger),
                visualDensity: VisualDensity.compact),
          ),
        ],
        if (center.status == CenterStatus.active) ...[
          OutlinedButton.icon(
            icon: const Icon(Icons.pause_circle_outline, size: 16),
            label: const Text('Suspend'),
            onPressed: () => _showSuspendDialog(context),
            style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.warning,
                side: const BorderSide(color: AppColors.warning),
                visualDensity: VisualDensity.compact),
          ),
        ],
        if (center.status == CenterStatus.suspended) ...[
          FilledButton.icon(
            icon: const Icon(Icons.play_circle_outline, size: 16),
            label: const Text('Reactivate'),
            onPressed: () => context
                .read<CentersBloc>()
                .add(CenterReactivateRequested(center.id)),
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                visualDensity: VisualDensity.compact),
          ),
        ],
      ],
    );
  }

  Future<void> _showApproveDialog(BuildContext context) async {
    final notesCtrl = TextEditingController();
    final bloc = context.read<CentersBloc>();
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => _ApproveDialog(notesCtrl: notesCtrl),
    );
    if (result == true) {
      bloc.add(CenterApproveRequested(
        center.id,
        DateTime.now().add(const Duration(days: 30)),
        notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
      ));
    }
  }

  Future<void> _showRejectDialog(BuildContext context) async {
    final reasonCtrl = TextEditingController();
    final bloc = context.read<CentersBloc>();
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => _RejectDialog(reasonCtrl: reasonCtrl),
    );
    if (result == true && reasonCtrl.text.trim().isNotEmpty) {
      bloc.add(CenterRejectRequested(center.id, reasonCtrl.text.trim()));
    }
  }

  Future<void> _showSuspendDialog(BuildContext context) async {
    final reasonCtrl = TextEditingController();
    final bloc = context.read<CentersBloc>();
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => _SuspendDialog(reasonCtrl: reasonCtrl),
    );
    if (result == true && reasonCtrl.text.trim().isNotEmpty) {
      bloc.add(CenterSuspendRequested(center.id, reasonCtrl.text.trim()));
    }
  }
}

// ─────────────────────────────────────────────────────────────
// Dialogs
// ─────────────────────────────────────────────────────────────
class _ApproveDialog extends StatelessWidget {
  final TextEditingController notesCtrl;
  const _ApproveDialog({required this.notesCtrl});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Approve Center'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Approving this center will start a 30-day free trial. '
              'The admin will be notified.',
              style: AppTypography.body.copyWith(color: AppColors.neutral600),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'Add any notes for the center admin...',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: FilledButton.styleFrom(backgroundColor: AppColors.success),
          child: const Text('Approve & Start Trial'),
        ),
      ],
    );
  }
}

class _RejectDialog extends StatefulWidget {
  final TextEditingController reasonCtrl;
  const _RejectDialog({required this.reasonCtrl});

  @override
  State<_RejectDialog> createState() => _RejectDialogState();
}

class _RejectDialogState extends State<_RejectDialog> {
  bool _isEmpty = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reject Registration'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please provide a reason for rejection. '
              'The admin will see this message.',
              style: AppTypography.body.copyWith(color: AppColors.neutral600),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: widget.reasonCtrl,
              maxLines: 3,
              autofocus: true,
              onChanged: (v) =>
                  setState(() => _isEmpty = v.trim().isEmpty),
              decoration: InputDecoration(
                labelText: 'Rejection Reason *',
                hintText:
                    'e.g. Invalid license number, missing documentation...',
                errorText: _isEmpty ? null : null,
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.danger),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isEmpty
              ? null
              : () => Navigator.pop(context, true),
          style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
          child: const Text('Reject'),
        ),
      ],
    );
  }
}

class _SuspendDialog extends StatefulWidget {
  final TextEditingController reasonCtrl;
  const _SuspendDialog({required this.reasonCtrl});

  @override
  State<_SuspendDialog> createState() => _SuspendDialogState();
}

class _SuspendDialogState extends State<_SuspendDialog> {
  bool _isEmpty = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Suspend Center'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This will immediately disable all access for this center.',
              style: AppTypography.body.copyWith(color: AppColors.neutral600),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: widget.reasonCtrl,
              maxLines: 3,
              autofocus: true,
              onChanged: (v) =>
                  setState(() => _isEmpty = v.trim().isEmpty),
              decoration: const InputDecoration(
                labelText: 'Suspension Reason *',
                hintText: 'e.g. Payment overdue, policy violation...',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isEmpty ? null : () => Navigator.pop(context, true),
          style: FilledButton.styleFrom(backgroundColor: AppColors.warning),
          child: const Text('Suspend'),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Overview Tab
// ─────────────────────────────────────────────────────────────
class _OverviewTab extends StatelessWidget {
  final PlatformCenter center;
  const _OverviewTab({required this.center});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          _InfoCard(
            title: 'Basic Information',
            rows: [
              ('Admin', '${center.adminName} (${center.adminEmail})'),
              ('License No.', center.licenseNumber),
              ('License Verified', center.licenseVerified ? 'Yes ✓' : 'Pending'),
              ('Doctors', '${center.doctorCount}'),
              ('Patients', '${center.patientCount}'),
              ('Registered', DateFormat('MMM d, yyyy').format(center.createdAt)),
              if (center.lastActivityAt != null)
                ('Last Activity',
                    DateFormat('MMM d, yyyy HH:mm').format(center.lastActivityAt!)),
            ],
          ),
          const SizedBox(height: 16),
          _InfoCard(
            title: 'Status',
            rows: [
              ('Center Status', center.status.name.toUpperCase()),
              ('Subscription', center.subscriptionStatus),
            ],
            statusHighlight: center.status,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Subscription Tab
// ─────────────────────────────────────────────────────────────
class _SubscriptionTab extends StatelessWidget {
  final PlatformCenter center;
  const _SubscriptionTab({required this.center});

  @override
  Widget build(BuildContext context) {
    final (statusColor, statusLabel) = switch (center.status) {
      CenterStatus.active => (AppColors.success, 'Active'),
      CenterStatus.pending => (AppColors.warning, 'Pending Approval'),
      CenterStatus.suspended => (AppColors.danger, 'Suspended'),
      CenterStatus.rejected => (AppColors.neutral400, 'Rejected'),
    };

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
                  Row(
                    children: [
                      Text('Subscription Details',
                          style: AppTypography.h3),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withAlpha(20),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                              fontSize: 12,
                              color: statusColor,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.base),
                  _row('Plan', center.subscriptionStatus),
                  _row('Center Status', center.status.name),
                  _row('Doctors', '${center.doctorCount} registered'),
                  _row('Patients', '${center.patientCount} registered'),
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
            SizedBox(
                width: 140,
                child: Text(label,
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.neutral500))),
            Expanded(
                child: Text(value, style: AppTypography.bodySmall)),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────
// Audit Tab
// ─────────────────────────────────────────────────────────────
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
          return Center(
              child: Text(state.message,
                  style: TextStyle(color: AppColors.danger)));
        }
        if (state is PlatformAuditLoaded) {
          if (state.entries.isEmpty) {
            return Center(
              child: Text('No audit entries',
                  style: AppTypography.body
                      .copyWith(color: AppColors.neutral400)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.base),
            itemCount: state.entries.length,
            itemBuilder: (_, i) {
              final entry = state.entries[i];
              return ListTile(
                leading: const Icon(Icons.history,
                    size: 18, color: AppColors.neutral400),
                title:
                    Text(entry.action, style: AppTypography.bodySmall),
                subtitle: Text(
                  '${entry.userName} · ${DateFormat('MMM d HH:mm').format(entry.timestamp)}',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.neutral400),
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

// ─────────────────────────────────────────────────────────────
// Shared info card
// ─────────────────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final String title;
  final List<(String, String)> rows;
  final CenterStatus? statusHighlight;

  const _InfoCard({
    required this.title,
    required this.rows,
    this.statusHighlight,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.h3),
            const SizedBox(height: AppSpacing.base),
            ...rows.map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    SizedBox(
                      width: 140,
                      child: Text(r.$1,
                          style: AppTypography.bodySmall
                              .copyWith(color: AppColors.neutral500)),
                    ),
                    Expanded(
                      child: Text(r.$2,
                          style: AppTypography.bodySmall),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
