enum UserType { doctor, admin, superAdmin, unknown }

class UserContext {
  static final UserContext _instance = UserContext._();
  factory UserContext() => _instance;
  UserContext._();

  String? accessToken;
  String? refreshToken;
  UserType userType = UserType.unknown;
  String? centerId;
  String? userId;

  void clear() {
    accessToken = null;
    refreshToken = null;
    userType = UserType.unknown;
    centerId = null;
    userId = null;
  }

  bool get isAuthenticated => accessToken != null && accessToken!.isNotEmpty;

  static UserType parseUserType(String? raw) {
    switch (raw?.toLowerCase()) {
      case 'doctor':
        return UserType.doctor;
      case 'admin':
      case 'healthcenteradmin':
        return UserType.admin;
      case 'superadmin':
        return UserType.superAdmin;
      default:
        return UserType.unknown;
    }
  }
}
