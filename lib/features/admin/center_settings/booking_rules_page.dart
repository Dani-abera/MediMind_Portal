import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/network/user_context.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/shell/page_header.dart';
import '../domain/entities/booking_rules.dart';
import '../presentation/bloc/booking_rules/booking_rules_bloc.dart';

class BookingRulesPage extends StatelessWidget {
  const BookingRulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BookingRulesBloc>()
        ..add(BookingRulesStarted(UserContext().centerId ?? '')),
      child: const _BookingRulesView(),
    );
  }
}

class _BookingRulesView extends StatelessWidget {
  const _BookingRulesView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingRulesBloc, BookingRulesState>(
      listener: (ctx, state) {
        if (state is BookingRulesSaved) {
          if (state.warningMessage != null) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text(state.warningMessage!),
                backgroundColor: Colors.amber.shade700,
              ),
            );
          } else {
            ScaffoldMessenger.of(ctx).showSnackBar(
              const SnackBar(content: Text('Booking rules saved successfully')),
            );
          }
        }
        if (state is BookingRulesError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.danger),
          );
        }
      },
      child: BlocBuilder<BookingRulesBloc, BookingRulesState>(
        builder: (ctx, state) {
          final rules = state is BookingRulesLoaded ? state.rules : const BookingRules();
          final isLoading = state is BookingRulesLoading;
          final isSaving = state is BookingRulesSaving;

          return Column(
            children: [
              const PageHeader(
                title: 'Center Settings',
                subtitle: 'Booking Rules',
              ),
              if (isLoading)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      children: [
                        _ruleCard(
                          title: 'Slot Duration',
                          child: Wrap(
                            spacing: AppSpacing.sm,
                            children: [15, 30, 45, 60].map((min) {
                              return ChoiceChip(
                                label: Text('$min min'),
                                selected: rules.slotDurationMinutes == min,
                                onSelected: (_) => ctx.read<BookingRulesBloc>().add(
                                      BookingRulesChanged(rules.copyWith(slotDurationMinutes: min)),
                                    ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.base),
                        _ruleCard(
                          title: 'Advance Booking Window',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Slider(
                                value: rules.advanceBookingDays.toDouble(),
                                min: 1,
                                max: 90,
                                divisions: 89,
                                onChanged: (v) => ctx.read<BookingRulesBloc>().add(
                                      BookingRulesChanged(rules.copyWith(advanceBookingDays: v.round())),
                                    ),
                              ),
                              Text(
                                '${rules.advanceBookingDays} days',
                                style: AppTypography.bodySmall.copyWith(color: AppColors.neutral600),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.base),
                        _ruleCard(
                          title: 'Cancellation Policy',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Slider(
                                value: rules.cancellationHoursMin.toDouble(),
                                min: 0,
                                max: 72,
                                divisions: 72,
                                onChanged: (v) => ctx.read<BookingRulesBloc>().add(
                                      BookingRulesChanged(rules.copyWith(cancellationHoursMin: v.round())),
                                    ),
                              ),
                              Text(
                                'Minimum ${rules.cancellationHoursMin} hours before appointment',
                                style: AppTypography.bodySmall.copyWith(color: AppColors.neutral600),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.base),
                        _ruleCard(
                          title: 'Auto-Approval',
                          child: RadioGroup<String>(
                            groupValue: rules.autoApproveAll
                                ? 'all'
                                : rules.autoApproveKnownPatients
                                    ? 'known'
                                    : 'none',
                            onChanged: (v) {
                              ctx.read<BookingRulesBloc>().add(
                                    BookingRulesChanged(rules.copyWith(
                                      autoApproveAll: v == 'all',
                                      autoApproveKnownPatients: v == 'known',
                                    )),
                                  );
                            },
                            child: const Column(
                              children: [
                                RadioListTile<String>(
                                  title: Text('None'),
                                  value: 'none',
                                ),
                                RadioListTile<String>(
                                  title: Text('All'),
                                  value: 'all',
                                ),
                                RadioListTile<String>(
                                  title: Text('Known patients only (≥1 prior appointment)'),
                                  value: 'known',
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.base),
                        _ruleCard(
                          title: 'Reminders',
                          child: Column(
                            children: [
                              SwitchListTile(
                                title: const Text('24h reminder'),
                                value: rules.reminder24h,
                                onChanged: (v) => ctx.read<BookingRulesBloc>().add(
                                      BookingRulesChanged(rules.copyWith(reminder24h: v)),
                                    ),
                              ),
                              SwitchListTile(
                                title: const Text('2h reminder'),
                                value: rules.reminder2h,
                                onChanged: (v) => ctx.read<BookingRulesBloc>().add(
                                      BookingRulesChanged(rules.copyWith(reminder2h: v)),
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton(
                            onPressed: isSaving
                                ? null
                                : () => ctx.read<BookingRulesBloc>().add(const BookingRulesSubmitted()),
                            child: isSaving
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('Save Booking Rules'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _ruleCard({required String title, required Widget child}) => Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.h3),
              const SizedBox(height: AppSpacing.sm),
              child,
            ],
          ),
        ),
      );
}
