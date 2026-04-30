import 'package:go_router/go_router.dart';
import '../network/user_context.dart';
import 'route_names.dart';

String? requireAuth(GoRouterState state, UserContext ctx) {
  if (!ctx.isAuthenticated) return RouteNames.login;
  return null;
}

String? requireRole(
  GoRouterState state,
  UserContext ctx,
  List<UserType> allowed,
) {
  if (!ctx.isAuthenticated) return RouteNames.login;
  if (!allowed.contains(ctx.userType)) return _homeForUser(ctx.userType);
  return null;
}

String? requireCenterContext(GoRouterState state, UserContext ctx) {
  if (!ctx.isAuthenticated) return RouteNames.login;
  if (ctx.centerId == null || ctx.centerId!.isEmpty) {
    return RouteNames.adminDashboard;
  }
  return null;
}

String _homeForUser(UserType type) => switch (type) {
      UserType.doctor => RouteNames.doctorDashboard,
      UserType.admin => RouteNames.adminDashboard,
      UserType.superAdmin => RouteNames.superAdminDashboard,
      UserType.unknown => RouteNames.login,
    };
