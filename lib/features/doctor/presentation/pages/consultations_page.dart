import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medimind_portal/core/utils/fa_compat.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/feedback/app_loading.dart';
import '../../../../core/widgets/shell/page_header.dart';
import '../../../../core/widgets/status_badges/status_badge.dart';
import '../../domain/entities/video_consultation.dart';
import '../bloc/consultation/consultation_bloc.dart';

class ConsultationsPage extends StatelessWidget {
  const ConsultationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<ConsultationBloc>()..add(const ConsultationStarted()),
      child: BlocListener<ConsultationBloc, ConsultationState>(
        listener: (ctx, state) {
          if (state is ConsultationInitiateSuccess) {
            context.push(
              '/doctor/video-call/${state.consultation.id}',
            );
          }
        },
        child: const _ConsultationsView(),
      ),
    );
  }
}

class _ConsultationsView extends StatefulWidget {
  const _ConsultationsView();

  @override
  State<_ConsultationsView> createState() => _ConsultationsViewState();
}

class _ConsultationsViewState extends State<_ConsultationsView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        context
            .read<ConsultationBloc>()
            .add(ConsultationTabChanged(_tabController.index));
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              const PageHeader(title: 'Consultations'),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Active'),
                  Tab(text: 'Today'),
                  Tab(text: 'Past'),
                ],
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.neutral500,
                indicatorColor: AppColors.primary,
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: BlocBuilder<ConsultationBloc, ConsultationState>(
            builder: (ctx, state) {
              if (state is ConsultationLoading || state is ConsultationInitial) {
                return const Center(child: AppLoadingSpinner());
              }
              if (state is ConsultationError) {
                return AppErrorState(
                  message: state.message,
                  onRetry: () =>
                      ctx.read<ConsultationBloc>().add(const ConsultationStarted()),
                );
              }
              if (state is ConsultationLoaded) {
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _ConsultationList(
                      consultations: state.active,
                      emptyMessage: 'No active consultations',
                      showJoinButton: true,
                    ),
                    _ConsultationList(
                      consultations: state.today,
                      emptyMessage: 'No consultations today',
                    ),
                    _ConsultationList(
                      consultations: state.past,
                      emptyMessage: 'No past consultations',
                      hasMore: state.hasMorePast,
                      onLoadMore: () =>
                          ctx.read<ConsultationBloc>().add(const ConsultationNextPage()),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}

class _ConsultationList extends StatelessWidget {
  final List<VideoConsultation> consultations;
  final String emptyMessage;
  final bool showJoinButton;
  final bool hasMore;
  final VoidCallback? onLoadMore;

  const _ConsultationList({
    required this.consultations,
    required this.emptyMessage,
    this.showJoinButton = false,
    this.hasMore = false,
    this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    if (consultations.isEmpty) {
      return AppEmptyState(
        message: emptyMessage,
        icon: Icons.video_call_outlined,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.xl),
      itemCount: consultations.length + (hasMore ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) {
        if (i == consultations.length) {
          return Center(
            child: TextButton(
              onPressed: onLoadMore,
              child: const Text('Load more'),
            ),
          );
        }
        return _ConsultationCard(
          consultation: consultations[i],
          showJoinButton: showJoinButton,
        );
      },
    );
  }
}

class _ConsultationCard extends StatelessWidget {
  final VideoConsultation consultation;
  final bool showJoinButton;

  const _ConsultationCard({
    required this.consultation,
    required this.showJoinButton,
  });

  @override
  Widget build(BuildContext context) {
    final c = consultation;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: c.status == ConsultationStatus.active
              ? AppColors.info.withAlpha(100)
              : AppColors.neutral200,
          width: c.status == ConsultationStatus.active ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _statusColor(c.status).withAlpha(15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(FontAwesomeIcons.video,
                  size: 18, color: _statusColor(c.status)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.patientName, style: AppTypography.bodyMedium),
                const SizedBox(height: 4),
                if (c.startedAt != null)
                  Text(
                    DateFormat('MMM d, y HH:mm').format(c.startedAt!),
                    style: AppTypography.caption
                        .copyWith(color: AppColors.neutral500),
                  ),
                if (c.duration != null)
                  Text(
                    _formatDuration(c.duration!),
                    style: AppTypography.caption
                        .copyWith(color: AppColors.neutral400),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StatusBadge(
                label: c.status.name,
                status: c.status == ConsultationStatus.active
                    ? BadgeStatus.active
                    : c.status == ConsultationStatus.ended
                        ? BadgeStatus.completed
                        : BadgeStatus.pending,
              ),
              if (showJoinButton && c.status == ConsultationStatus.active) ...[
                const SizedBox(height: 8),
                FilledButton.icon(
                  icon: const Icon(FontAwesomeIcons.video, size: 12),
                  label: const Text('Join'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.info,
                    minimumSize: const Size(80, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onPressed: () =>
                      context.push('/doctor/video-call/${c.id}'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(ConsultationStatus s) => switch (s) {
        ConsultationStatus.active => AppColors.info,
        ConsultationStatus.ended => AppColors.success,
        ConsultationStatus.pending => AppColors.warning,
      };

  String _formatDuration(Duration d) {
    if (d.inHours > 0) {
      return '${d.inHours}h ${d.inMinutes % 60}min';
    }
    return '${d.inMinutes}min';
  }
}
