part of 'revenue_bloc.dart';

abstract class RevenueState extends Equatable {
  const RevenueState();
  @override List<Object?> get props => [];
}

class RevenueInitial extends RevenueState { const RevenueInitial(); }
class RevenueLoading extends RevenueState { const RevenueLoading(); }

class RevenueLoaded extends RevenueState {
  final RevenueSummary data;
  final DateRangeSelection range;
  final RevenueGroupBy groupBy;
  final bool comparePeriod;
  const RevenueLoaded({
    required this.data,
    required this.range,
    required this.groupBy,
    this.comparePeriod = false,
  });
  @override List<Object?> get props => [data, range, groupBy, comparePeriod];
}

class RevenueError extends RevenueState {
  final String message;
  const RevenueError(this.message);
  @override List<Object?> get props => [message];
}

class RevenueExporting extends RevenueState { const RevenueExporting(); }
class RevenueExportDone extends RevenueState { const RevenueExportDone(); }
