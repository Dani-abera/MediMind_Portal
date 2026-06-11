import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medimind_portal/core/utils/fa_compat.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/feedback/app_loading.dart';
import '../../../../core/widgets/shell/page_header.dart';
import '../../domain/entities/prescription_template.dart';
import '../bloc/prescription_templates/prescription_templates_bloc.dart';

class PrescriptionTemplatesPage extends StatelessWidget {
  const PrescriptionTemplatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PrescriptionTemplatesBloc>()
        ..add(const PrescriptionTemplatesStarted()),
      child: const _TemplatesView(),
    );
  }
}

class _TemplatesView extends StatelessWidget {
  const _TemplatesView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const PageHeader(
          title: 'Prescription Templates',
          subtitle: 'Reusable prescription blueprints',
        ),
        Expanded(
          child: BlocBuilder<PrescriptionTemplatesBloc,
              PrescriptionTemplatesState>(
            builder: (ctx, state) {
              if (state is PrescriptionTemplatesLoading ||
                  state is PrescriptionTemplatesInitial) {
                return const Center(child: AppLoadingSpinner());
              }
              if (state is PrescriptionTemplatesError) {
                return AppErrorState(
                  message: state.message,
                  onRetry: () => ctx
                      .read<PrescriptionTemplatesBloc>()
                      .add(const PrescriptionTemplatesStarted()),
                );
              }
              if (state is PrescriptionTemplatesLoaded) {
                if (state.templates.isEmpty) {
                  return const AppEmptyState(
                    message: 'No templates yet',
                    description:
                        'Create reusable prescription templates to save time.',
                    icon: Icons.description_outlined,
                  );
                }
                return _TemplateGrid(templates: state.templates);
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}

class _TemplateGrid extends StatelessWidget {
  final List<PrescriptionTemplate> templates;
  const _TemplateGrid({required this.templates});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.xl),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 340,
        childAspectRatio: 1.3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: templates.length,
      itemBuilder: (ctx, i) => _TemplateCard(template: templates[i]),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final PrescriptionTemplate template;
  const _TemplateCard({required this.template});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.neutral200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withAlpha(80),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(FontAwesomeIcons.prescription,
                      size: 16, color: AppColors.primary),
                ),
              ),
              const Spacer(),
              Text(
                'Used ${template.useCount}×',
                style: AppTypography.caption
                    .copyWith(color: AppColors.neutral400),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            template.name,
            style: AppTypography.h3,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (template.description != null) ...[
            const SizedBox(height: 4),
            Text(
              template.description!,
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.neutral500),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const Spacer(),
          Text(
            '${template.medications.length} medication(s)',
            style: AppTypography.caption.copyWith(color: AppColors.neutral400),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact),
                  child: const Text('Use'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(FontAwesomeIcons.trash,
                    size: 13, color: AppColors.danger),
                onPressed: () => context
                    .read<PrescriptionTemplatesBloc>()
                    .add(PrescriptionTemplateDeleted(template.id)),
                visualDensity: VisualDensity.compact,
                tooltip: 'Delete',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
