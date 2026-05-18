part of 'patient_directory_bloc.dart';
abstract class PatientDirEvent extends Equatable { const PatientDirEvent(); @override List<Object?> get props => []; }
class PatientDirStarted extends PatientDirEvent { final String centerId; const PatientDirStarted(this.centerId); @override List<Object?> get props => [centerId]; }
class PatientDirSearched extends PatientDirEvent { final String query; const PatientDirSearched(this.query); @override List<Object?> get props => [query]; }
class PatientDirFiltered extends PatientDirEvent { final DateTime? from, to; const PatientDirFiltered({this.from, this.to}); @override List<Object?> get props => [from, to]; }
class PatientDirPageChanged extends PatientDirEvent { final int page; const PatientDirPageChanged(this.page); @override List<Object?> get props => [page]; }
class PatientDirRefreshed extends PatientDirEvent { const PatientDirRefreshed(); }
