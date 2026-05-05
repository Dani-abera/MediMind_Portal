part of 'revenue_bloc.dart';

abstract class RevenueEvent extends Equatable {
  const RevenueEvent();
  @override List<Object?> get props => [];
}

class RevenueStarted extends RevenueEvent {
  final String centerId;
  const RevenueStarted(this.centerId);
  @override List<Object?> get props => [centerId];
}

class RevenueDateRangeChanged extends RevenueEvent {
  final DateRangePreset preset;
  final DateTime? customFrom;
  final DateTime? customTo;
  const RevenueDateRangeChanged(this.preset, {this.customFrom, this.customTo});
  @override List<Object?> get props => [preset, customFrom, customTo];
}

class RevenueGroupByChanged extends RevenueEvent {
  final RevenueGroupBy groupBy;
  const RevenueGroupByChanged(this.groupBy);
  @override List<Object?> get props => [groupBy];
}

class RevenueComparePeriodToggled extends RevenueEvent {
  final bool enabled;
  const RevenueComparePeriodToggled(this.enabled);
  @override List<Object?> get props => [enabled];
}

class RevenueExportRequested extends RevenueEvent {
  const RevenueExportRequested();
}

class RevenueRefreshed extends RevenueEvent {
  const RevenueRefreshed();
}
