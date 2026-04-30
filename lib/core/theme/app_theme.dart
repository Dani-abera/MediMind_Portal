import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_radius.dart';
import 'app_elevation.dart';

abstract class AppTheme {
  static ThemeData get light => _buildTheme(isDark: false);
  static ThemeData get dark => _buildTheme(isDark: true);

  static ThemeData _buildTheme({required bool isDark}) {
    final Color primary = isDark ? AppColors.primaryDark : AppColors.primary;
    final Color primaryLight =
        isDark ? AppColors.primaryLightDark : AppColors.primaryLight;
    final Color danger = isDark ? AppColors.dangerDark : AppColors.danger;
    final Color surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final Color background =
        isDark ? AppColors.backgroundDark : AppColors.background;
    final Color neutral900 =
        isDark ? AppColors.neutral900Dark : AppColors.neutral900;
    final Color neutral800 =
        isDark ? AppColors.neutral800Dark : AppColors.neutral800;
    final Color neutral700 =
        isDark ? AppColors.neutral700Dark : AppColors.neutral700;
    final Color neutral600 =
        isDark ? AppColors.neutral600Dark : AppColors.neutral600;
    final Color neutral500 =
        isDark ? AppColors.neutral500Dark : AppColors.neutral500;
    final Color neutral400 =
        isDark ? AppColors.neutral400Dark : AppColors.neutral400;
    final Color neutral300 =
        isDark ? AppColors.neutral300Dark : AppColors.neutral300;
    final Color neutral200 =
        isDark ? AppColors.neutral200Dark : AppColors.neutral200;
    final Color neutral100 =
        isDark ? AppColors.neutral100Dark : AppColors.neutral100;

    final colorScheme = ColorScheme(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: primaryLight,
      onPrimaryContainer: primary,
      secondary: AppColors.accent,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.accent.withAlpha(30),
      onSecondaryContainer: AppColors.accent,
      error: danger,
      onError: Colors.white,
      errorContainer: danger.withAlpha(20),
      onErrorContainer: danger,
      surface: surface,
      onSurface: neutral900,
      surfaceContainerHighest: neutral100,
      onSurfaceVariant: neutral600,
      outline: neutral300,
      outlineVariant: neutral200,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      visualDensity: const VisualDensity(horizontal: -1, vertical: -1),
      fontFamily: 'Inter',
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: neutral900,
        elevation: AppElevation.none,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTypography.h2.copyWith(color: neutral900),
      ),
      cardTheme: CardThemeData(
        elevation: AppElevation.none,
        color: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusBase,
          side: BorderSide(color: neutral300, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 36),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          textStyle:
              AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
          shape:
              const RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
          elevation: AppElevation.none,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(0, 36),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          textStyle:
              AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
          shape:
              const RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
          side: BorderSide(color: primary),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(0, 36),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          textStyle:
              AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w500),
          shape:
              const RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        constraints: const BoxConstraints(minHeight: 36, maxHeight: 36),
        border: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: BorderSide(color: neutral300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: BorderSide(color: neutral300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: BorderSide(color: danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: BorderSide(color: danger, width: 1.5),
        ),
        hintStyle:
            AppTypography.bodySmall.copyWith(color: neutral400),
        labelStyle:
            AppTypography.bodySmall.copyWith(color: neutral600),
        errorStyle: AppTypography.caption.copyWith(color: danger),
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(neutral100),
        dataRowMinHeight: 40,
        dataRowMaxHeight: 48,
        headingRowHeight: 40,
        columnSpacing: 16,
        horizontalMargin: 16,
        dividerThickness: 1,
        headingTextStyle: AppTypography.caption.copyWith(
          fontWeight: FontWeight.w600,
          color: neutral600,
        ),
        dataTextStyle:
            AppTypography.bodySmall.copyWith(color: neutral800),
        decoration: BoxDecoration(
          color: surface,
          border: Border.all(color: neutral200),
          borderRadius: AppRadius.radiusBase,
        ),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbVisibility: WidgetStateProperty.all(true),
        trackVisibility: WidgetStateProperty.all(true),
        thickness: WidgetStateProperty.all(6),
        radius: const Radius.circular(3),
        thumbColor: WidgetStateProperty.all(neutral300),
        trackColor: WidgetStateProperty.all(Colors.transparent),
      ),
      dividerTheme: DividerThemeData(
        color: neutral200,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: neutral100,
        selectedColor: primaryLight,
        labelStyle: AppTypography.caption.copyWith(color: neutral700),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        shape:
            const RoundedRectangleBorder(borderRadius: AppRadius.radiusFull),
        side: BorderSide.none,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: AppElevation.modal,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.radiusXl),
        titleTextStyle:
            AppTypography.h2.copyWith(color: neutral900),
        contentTextStyle:
            AppTypography.body.copyWith(color: neutral700),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: neutral800,
          borderRadius: AppRadius.radiusSm,
        ),
        textStyle: AppTypography.caption.copyWith(color: Colors.white),
        preferBelow: false,
        waitDuration: const Duration(milliseconds: 600),
      ),
      listTileTheme: ListTileThemeData(
        dense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        minVerticalPadding: 4,
        visualDensity: const VisualDensity(horizontal: -1, vertical: -2),
        titleTextStyle:
            AppTypography.bodySmall.copyWith(color: neutral800),
        subtitleTextStyle:
            AppTypography.caption.copyWith(color: neutral500),
      ),
      tabBarTheme: TabBarThemeData(
        indicatorColor: primary,
        labelColor: primary,
        unselectedLabelColor: neutral500,
        labelStyle:
            AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppTypography.bodySmall,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: neutral200,
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.display,
        headlineLarge: AppTypography.h1,
        headlineMedium: AppTypography.h2,
        headlineSmall: AppTypography.h3,
        bodyLarge: AppTypography.body,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
        labelSmall: AppTypography.caption,
      ),
    );
  }
}
