import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

class AppTheme {
  static ThemeData lightTheme({Color primaryColor = AppColors.primaryColor}) {
    final baseTextTheme = GoogleFonts.quicksandTextTheme().apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: AppColors.secondaryColor,
      surface: AppColors.surfaceColor,
      error: AppColors.errorColor,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: const Color(0xFFFFFAF3),
      splashColor: primaryColor.withValues(alpha: 0.08),
      highlightColor: primaryColor.withValues(alpha: 0.04),
      textTheme: _textTheme(baseTextTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: baseTextTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFFFFFEFC),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius + 8),
          side: const BorderSide(color: Color(0xFFF8EEDB)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        contentTextStyle:
            baseTextTheme.bodyMedium?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius + 10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          textStyle:
              baseTextTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: Color(0xFFE5D9E1)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius + 6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFFFF4E8),
        selectedColor: primaryColor.withValues(alpha: 0.18),
        labelStyle: baseTextTheme.labelLarge!,
        secondaryLabelStyle: baseTextTheme.labelLarge!,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        side: BorderSide.none,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius + 8),
          borderSide: const BorderSide(color: Color(0xFFECE1E8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius + 8),
          borderSide: const BorderSide(color: Color(0xFFECE1E8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius + 8),
          borderSide: BorderSide(color: primaryColor, width: 1.8),
        ),
        hintStyle:
            baseTextTheme.bodyMedium?.copyWith(color: AppColors.textHint),
        labelStyle:
            baseTextTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFF0E6ED),
        thickness: 1,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFFFFFDF9),
        height: 74,
        indicatorColor: primaryColor.withValues(alpha: 0.2),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected)
                ? primaryColor
                : AppColors.textSecondary,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return baseTextTheme.labelMedium!.copyWith(
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w900
                : FontWeight.w600,
            color: states.contains(WidgetState.selected)
                ? primaryColor
                : AppColors.textSecondary,
          );
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? primaryColor
              : Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? primaryColor.withValues(alpha: 0.35)
              : AppColors.lightGrey;
        }),
      ),
    );
  }

  static ThemeData darkTheme({Color primaryColor = AppColors.primaryColor}) {
    final baseTextTheme = GoogleFonts.quicksandTextTheme().apply(
      bodyColor: const Color(0xFFF6EEF4),
      displayColor: const Color(0xFFF6EEF4),
    );

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      primary: primaryColor,
      secondary: AppColors.secondaryColor,
      surface: const Color(0xFF231C29),
      error: AppColors.errorColor,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: const Color(0xFF161219),
      textTheme: _textTheme(baseTextTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFFF6EEF4),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: baseTextTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: const Color(0xFFF6EEF4),
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF231C29),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius + 4),
          side: const BorderSide(color: Color(0xFF312737)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFFF6EEF4),
        contentTextStyle:
            baseTextTheme.bodyMedium?.copyWith(color: const Color(0xFF161219)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius + 6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          textStyle:
              baseTextTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFF6EEF4),
          side: const BorderSide(color: Color(0xFF3A313F)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius + 6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF2C2433),
        selectedColor: primaryColor.withValues(alpha: 0.25),
        labelStyle: baseTextTheme.labelLarge!,
        secondaryLabelStyle: baseTextTheme.labelLarge!,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF231C29),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius + 8),
          borderSide: const BorderSide(color: Color(0xFF352C3A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius + 8),
          borderSide: const BorderSide(color: Color(0xFF352C3A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius + 8),
          borderSide: BorderSide(color: primaryColor, width: 1.8),
        ),
        hintStyle:
            baseTextTheme.bodyMedium?.copyWith(color: const Color(0xFFA99FB0)),
        labelStyle:
            baseTextTheme.bodyMedium?.copyWith(color: const Color(0xFFA99FB0)),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF302733),
        thickness: 1,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF1D1722),
        height: 72,
        indicatorColor: primaryColor.withValues(alpha: 0.22),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected)
                ? primaryColor
                : const Color(0xFFA99FB0),
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return baseTextTheme.labelMedium!.copyWith(
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w800
                : FontWeight.w600,
            color: states.contains(WidgetState.selected)
                ? primaryColor
                : const Color(0xFFA99FB0),
          );
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? primaryColor
              : const Color(0xFFF6EEF4);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? primaryColor.withValues(alpha: 0.35)
              : const Color(0xFF3A313F);
        }),
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base) {
    return base.copyWith(
      headlineLarge: base.headlineLarge
          ?.copyWith(fontWeight: FontWeight.w900, fontSize: 30),
      headlineMedium: base.headlineMedium
          ?.copyWith(fontWeight: FontWeight.w800, fontSize: 24),
      titleLarge:
          base.titleLarge?.copyWith(fontWeight: FontWeight.w800, fontSize: 20),
      titleMedium:
          base.titleMedium?.copyWith(fontWeight: FontWeight.w800, fontSize: 16),
      bodyLarge: base.bodyLarge?.copyWith(fontSize: 16, height: 1.3),
      bodyMedium: base.bodyMedium?.copyWith(fontSize: 14, height: 1.35),
      labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}
