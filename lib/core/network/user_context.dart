enum UserType { doctor, admin, superAdmin, unknown }

class UserContext {
  static final UserContext _instance = UserContext._();
  factory UserContext() => _instance;
  UserContext._();

  String? accessToken;
  String? refreshToken;
  UserType userType = UserType.unknown;
  String? centerId;
  String? centerStatus;
  String? userId;

  void clear() {
    accessToken = null;
    refreshToken = null;
    userType = UserType.unknown;
    centerId = null;
    centerStatus = null;
    userId = null;
  }

  bool get isAuthenticated => accessToken != null && accessToken!.isNotEmpty;

  static UserType parseUserType(String? raw) {
    if (raw == null) return UserType.unknown;
    final normalized = raw.toLowerCase().replaceAll(' ', '').replaceAll('_', '');
    switch (normalized) {
      case 'doctor':
        return UserType.doctor;
      case 'admin':
      case 'healthcenteradmin':
      case 'centeradmin':
        return UserType.admin;
      case 'superadmin':
      case 'systemadmin':
      case 'platformadmin':
        return UserType.superAdmin;
      default:
        return UserType.unknown;
    }
  }
}
