import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/service_locator.dart';
import 'core/network/user_context.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'core/widgets/kbd/keyboard_shortcuts.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

class MediMindPortalApp extends StatefulWidget {
  const MediMindPortalApp({super.key});

  @override
  State<MediMindPortalApp> createState() => _MediMindPortalAppState();
}

class _MediMindPortalAppState extends State<MediMindPortalApp> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter(sl<UserContext>());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<AuthBloc>()),
        BlocProvider.value(value: sl<ThemeCubit>()),
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
            builder: (_, child) => child ?? const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
