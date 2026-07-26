import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: false,
    primaryColor: AppColors.main,
    scaffoldBackgroundColor: AppColors.second,
    colorScheme: const ColorScheme.light(
      primary: AppColors.main,
      secondary: AppColors.third,
      background: AppColors.second,
      error: AppColors.danger,
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.main;
        return null;
      }),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.main,
        foregroundColor: AppColors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        minimumSize: const Size.fromHeight(32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        textStyle: GoogleFonts.quicksand(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.main,
        side: const BorderSide(color: AppColors.main),
        backgroundColor: AppColors.second,
        elevation: 0,
        minimumSize: const Size.fromHeight(32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        textStyle: GoogleFonts.quicksand(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.main),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.main),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.main, width: 1.5),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Colors.black.withOpacity(0.15)),
      ),
      hintStyle: GoogleFonts.quicksand(
        color: AppColors.fourth,
        fontSize: 16,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );

  return base.copyWith(
    textTheme: GoogleFonts.quicksandTextTheme(base.textTheme).apply(
      bodyColor: AppColors.main,
      displayColor: AppColors.main,
    ),
  );
}
