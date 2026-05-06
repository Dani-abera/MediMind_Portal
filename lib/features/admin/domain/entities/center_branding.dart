import 'package:equatable/equatable.dart';

class CenterBranding extends Equatable {
  final String centerId;
  final String? logoUrl;
  final String? coverUrl;
  final String description;

  const CenterBranding({
    this.centerId = '',
    this.logoUrl,
    this.coverUrl,
    this.description = '',
  });

  CenterBranding copyWith({
    String? centerId,
    String? logoUrl,
    String? coverUrl,
    String? description,
  }) =>
      CenterBranding(
        centerId: centerId ?? this.centerId,
        logoUrl: logoUrl ?? this.logoUrl,
        coverUrl: coverUrl ?? this.coverUrl,
        description: description ?? this.description,
      );

  @override
  List<Object?> get props => [centerId, logoUrl, coverUrl, description];
}
