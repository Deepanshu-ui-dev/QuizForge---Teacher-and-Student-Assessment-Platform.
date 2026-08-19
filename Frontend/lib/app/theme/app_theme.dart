import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_radii.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final colorScheme = ColorScheme.light(
      primary: AppColors.ink,
      onPrimary: AppColors.pureWhite,
      secondary: AppColors.accentIndigo,
      onSecondary: AppColors.pureWhite,
      surface: AppColors.pureWhite,
      onSurface: AppColors.charcoal,
      error: AppColors.error,
      onError: AppColors.pureWhite,
      outline: AppColors.grey300,
      outlineVariant: AppColors.grey100,
    );

    return _base(colorScheme, scaffoldBg: AppColors.paper, isDark: false);
  }

  static ThemeData get dark {
    final colorScheme = ColorScheme.dark(
      primary: AppColors.pureWhite,
      onPrimary: AppColors.ink,
      secondary: AppColors.accentIndigoDark,
      onSecondary: AppColors.ink,
      surface: AppColors.elevatedCardDark,
      onSurface: AppColors.pureWhite,
      error: AppColors.errorDark,
      onError: AppColors.ink,
      outline: AppColors.borderDark,
      outlineVariant: AppColors.borderDark,
    );

    return _base(colorScheme, scaffoldBg: AppColors.surfaceDark, isDark: true);
  }

  static ThemeData _base(
    ColorScheme colorScheme, {
    required Color scaffoldBg,
    required bool isDark,
  }) {
    final onSurface = colorScheme.onSurface;
    final secondaryText = isDark ? AppColors.grey700 : AppColors.grey500;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBg,
      brightness: colorScheme.brightness,
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLg(onSurface),
        displayMedium: AppTextStyles.displayMd(onSurface),
        displaySmall: AppTextStyles.displaySm(onSurface),
        bodyLarge: AppTextStyles.bodyLg(onSurface),
        bodyMedium: AppTextStyles.bodyMd(onSurface),
        bodySmall: AppTextStyles.bodySm(secondaryText),
        labelLarge: AppTextStyles.label(onSurface),
        labelSmall: AppTextStyles.caption(secondaryText),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: onSurface,
        titleTextStyle: AppTextStyles.displaySm(onSurface),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.lgRadius,
          side: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.outline,
          textStyle: AppTextStyles.button(colorScheme.onPrimary),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.mdRadius),
          elevation: 0,
          shadowColor: Colors.transparent,
        ).copyWith(
          overlayColor: WidgetStateProperty.all(
            colorScheme.onPrimary.withValues(alpha: 0.08),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: onSurface,
          side: BorderSide(color: colorScheme.outline),
          textStyle: AppTextStyles.button(onSurface),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.mdRadius),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.secondary,
          textStyle: AppTextStyles.button(colorScheme.secondary),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.elevatedCardDark : AppColors.pureWhite,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: AppRadii.mdRadius,
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.mdRadius,
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.mdRadius,
          borderSide: BorderSide(color: colorScheme.secondary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadii.mdRadius,
          borderSide: BorderSide(color: colorScheme.error),
        ),
        hintStyle: AppTextStyles.bodyMd(secondaryText),
        labelStyle: AppTextStyles.bodyMd(secondaryText),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.secondary.withValues(alpha: 0.12),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.secondary, size: 24);
          }
          return IconThemeData(color: secondaryText, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.caption(colorScheme.secondary)
                .copyWith(fontWeight: FontWeight.w600);
          }
          return AppTextStyles.caption(secondaryText);
        }),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.secondary,
        linearTrackColor: colorScheme.outlineVariant,
        circularTrackColor: colorScheme.outlineVariant,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.mdRadius),
        backgroundColor: isDark ? AppColors.elevatedCardDark : AppColors.ink,
        contentTextStyle: AppTextStyles.bodyMd(AppColors.pureWhite),
      ),
      splashFactory: InkSparkle.splashFactory,
      highlightColor: colorScheme.secondary.withValues(alpha: 0.06),
      hoverColor: colorScheme.secondary.withValues(alpha: 0.04),
    );
  }
}
