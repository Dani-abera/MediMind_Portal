import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/service_locator.dart';
import 'core/network/user_context.dart';
import 'core/routing/app_router.dart';
import 'core/services/app_update_service.dart';
import 'core/services/connectivity_cubit.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'core/widgets/connectivity/offline_banner.dart';
import 'core/widgets/kbd/keyboard_shortcuts.dart';
import 'core/widgets/update/update_banner.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

class MediMindPortalApp extends StatefulWidget {
  const MediMindPortalApp({super.key});

  @override
  State<MediMindPortalApp> createState() => _MediMindPortalAppState();
}

class _MediMindPortalAppState extends State<MediMindPortalApp>
    with WidgetsBindingObserver {
  late final AppRouter _appRouter;
  AppVersionInfo? _updateInfo;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _appRouter = AppRouter(sl<UserContext>());
    _checkForUpdate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Clear stale keyboard state that accumulates when the app loses focus
      // on macOS, which causes duplicate KeyDownEvent assertions in Flutter.
      // ignore: invalid_use_of_visible_for_testing_member
      HardwareKeyboard.instance.clearState();
    }
  }

  Future<void> _checkForUpdate() async {
    final info = await sl<AppUpdateService>().checkForUpdate();
    if (info != null && mounted) {
      setState(() => _updateInfo = info);
    }
  }

  @override
  Widget build(BuildContext context) {
    final updateInfo = _updateInfo;

    // Block entirely if force update required
    if (updateInfo != null && updateInfo.status == UpdateStatus.forceUpdate) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ForceUpdateScreen(info: updateInfo),
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<AuthBloc>()),
        BlocProvider.value(value: sl<ThemeCubit>()),
        BlocProvider.value(value: sl<ConnectivityCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (_, themeMode) => GlobalShortcutsWidget(
          child: MaterialApp.router(
            title: 'MediMind Portal',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            routerConfig: _appRouter.router,
            debugShowCheckedModeBanner: false,
            builder: (_, child) {
              return Column(
                children: [
                  if (updateInfo != null &&
                      updateInfo.status == UpdateStatus.updateAvailable)
                    UpdateBanner(info: updateInfo),
                  Expanded(
                    child: OfflineBanner(child: child ?? const SizedBox.shrink()),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
