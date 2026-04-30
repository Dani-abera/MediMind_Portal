import '../../domain/entities/auth_tokens.dart';

class AuthTokensModel extends AuthTokens {
  const AuthTokensModel({
    required super.accessToken,
    required super.refreshToken,
    required super.expiresAt,
  });

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) {
    final exp = json['expiresAt'];
    final expiresAt = exp != null
        ? DateTime.tryParse(exp.toString()) ??
            DateTime.now().add(const Duration(hours: 1))
        : DateTime.now().add(const Duration(hours: 1));

    return AuthTokensModel(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresAt: expiresAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'expiresAt': expiresAt.toIso8601String(),
      };

  static AuthTokensModel fromEntity(AuthTokens entity) => AuthTokensModel(
        accessToken: entity.accessToken,
        refreshToken: entity.refreshToken,
        expiresAt: entity.expiresAt,
      );
}
