import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_borders.dart';
import 'app_colors.dart';
import 'app_input_styles.dart';
import 'app_typography.dart';

/// Smart Learn Theme Configuration
/// Bridges design tokens into Flutter's ThemeData
class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: GoogleFonts.quicksand().fontFamily,

        // ─── Color Scheme ───
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          onPrimary: AppColors.primaryForeground,
          secondary: AppColors.secondary,
          onSecondary: AppColors.secondaryForeground,
          tertiary: AppColors.accent,
          onTertiary: AppColors.accentForeground,
          error: AppColors.destructive,
          onError: AppColors.destructiveForeground,
          surface: AppColors.card,
          onSurface: AppColors.foreground,
          surfaceContainerHighest: AppColors.muted,
          outline: AppColors.border,
          outlineVariant: AppColors.input,
        ),

        // ─── Scaffold ───
        scaffoldBackgroundColor: AppColors.background,

        // ─── AppBar ───
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.card,
          foregroundColor: AppColors.foreground,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: AppTypography.h4.copyWith(
            color: AppColors.foreground,
          ),
        ),

        // ─── Text Theme ───
        textTheme: TextTheme(
          displayLarge: AppTypography.h1,
          displayMedium: AppTypography.h2,
          displaySmall: AppTypography.h3,
          headlineMedium: AppTypography.h4,
          titleLarge: AppTypography.h3,
          titleMedium: AppTypography.labelLarge,
          titleSmall: AppTypography.labelMedium,
          bodyLarge: AppTypography.bodyLarge,
          bodyMedium: AppTypography.bodyMedium,
          bodySmall: AppTypography.bodySmall,
          labelLarge: AppTypography.labelLarge,
          labelMedium: AppTypography.labelMedium,
          labelSmall: AppTypography.labelSmall,
        ),

        // ─── Card ───
        cardTheme: CardThemeData(
          color: AppColors.card,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppBorders.borderRadiusLg,
            side: const BorderSide(
              color: AppColors.border,
              width: AppBorders.widthThin,
            ),
          ),
          margin: EdgeInsets.zero,
        ),

        // ─── Elevated Button ───
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.primaryForeground,
            textStyle: AppTypography.buttonLarge,
            minimumSize: const Size(0, 44),
            shape: AppBorders.shapeSm,
            elevation: 0,
          ),
        ),

        // ─── Outlined Button ───
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.foreground,
            textStyle: AppTypography.buttonLarge,
            minimumSize: const Size(0, 44),
            shape: AppBorders.shapeSm,
            side: const BorderSide(
              color: AppColors.border,
              width: AppBorders.widthThin,
            ),
          ),
        ),

        // ─── Text Button ───
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: AppTypography.buttonMedium,
            minimumSize: const Size(0, 36),
            shape: AppBorders.shapeSm,
          ),
        ),

        // ─── Input ───
        inputDecorationTheme: AppInputStyles.theme,

        // ─── Divider ───
        dividerTheme: const DividerThemeData(
          color: AppColors.border,
          thickness: AppBorders.widthThin,
          space: 0,
        ),

        // ─── Bottom Navigation ───
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.card,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.mutedForeground,
        ),

        // ─── Chip ───
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.muted,
          labelStyle: AppTypography.labelSmall,
          shape: AppBorders.shapeFull,
          side: BorderSide.none,
        ),

        // ─── Tab Bar ───
        tabBarTheme: TabBarThemeData(
          labelColor: AppColors.primaryForeground,
          unselectedLabelColor: AppColors.mutedForeground,
          labelStyle: AppTypography.labelMedium,
          unselectedLabelStyle: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
          indicator: BoxDecoration(
            color: AppColors.primary,
            borderRadius: AppBorders.borderRadiusLg,
          ),
        ),
      );
}
