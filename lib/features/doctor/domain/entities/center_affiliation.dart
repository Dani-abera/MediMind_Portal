import 'package:equatable/equatable.dart';

class CenterAffiliation extends Equatable {
  final String centerId;
  final String centerName;
  final String? centerAddress;
  final double consultationFee;
  final DateTime joinedAt;
  final bool isActive;

  const CenterAffiliation({
    required this.centerId,
    required this.centerName,
    this.centerAddress,
    required this.consultationFee,
    required this.joinedAt,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [centerId, centerName, centerAddress, consultationFee, joinedAt, isActive];
}
