part of 'centers_bloc.dart';

abstract class CentersState extends Equatable {
  const CentersState();
  @override
  List<Object?> get props => [];
}

class CentersInitial extends CentersState {
  const CentersInitial();
}

class CentersLoading extends CentersState {
  const CentersLoading();
}

class CentersLoaded extends CentersState {
  final List<PlatformCenter> centers;
  final int total;
  final int page;
  const CentersLoaded({required this.centers, required this.total, this.page = 1});
  @override
  List<Object?> get props => [centers, total, page];
}

class CentersActionSuccess extends CentersState {
  final String message;
  const CentersActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class CentersActionError extends CentersState {
  final String message;
  const CentersActionError(this.message);
  @override
  List<Object?> get props => [message];
}

class CentersError extends CentersState {
  final String message;
  const CentersError(this.message);
  @override
  List<Object?> get props => [message];
}
