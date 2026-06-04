import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFFA5B4FC);
  static const Color accent = Color(0xFFF59E0B);
  static const Color accentDark = Color(0xFFD97706);
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
}

extension ThemeColors on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get background => isDark ? const Color(0xFF0F1117) : const Color(0xFFF3F4F6);
  Color get surface => isDark ? const Color(0xFF1F2937) : const Color(0xFFFFFFFF);
  Color get surfaceLight => isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB);
  Color get textPrimary => isDark ? const Color(0xFFF9FAFB) : const Color(0xFF111827);
  Color get textSecondary => isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
  Color get textMuted => isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF);

  Gradient get heroGradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      isDark ? const Color(0xCC0F1117) : const Color(0xCCF3F4F6),
    ],
  );

  Gradient get cardGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      isDark ? const Color(0xFF1F2937) : const Color(0xFFFFFFFF),
      isDark ? const Color(0xFF111827) : const Color(0xFFF3F4F6),
    ],
  );
}

class AppTheme {
  static ThemeData get lightTheme => _buildTheme(Brightness.light);
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colors = isDark
        ? _DarkColors()
        : _LightColors();

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: brightness,
        surface: colors.surface,
        background: colors.background,
      ),
      scaffoldBackgroundColor: colors.background,
      textTheme: GoogleFonts.interTextTheme(
        isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
      ).copyWith(
        displayLarge: GoogleFonts.inter(fontSize: 48, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.bold),
        displaySmall: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600),
        headlineLarge: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600),
        headlineMedium: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        headlineSmall: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.normal),
        bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.normal),
        bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.normal),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: colors.surface,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: colors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
      ),
    );
  }
}

class _DarkColors {
  final Color background = const Color(0xFF0F1117);
  final Color surface = const Color(0xFF1F2937);
  final Color surfaceLight = const Color(0xFF374151);
  final Color textPrimary = const Color(0xFFF9FAFB);
  final Color textSecondary = const Color(0xFF9CA3AF);
  final Color textMuted = const Color(0xFF6B7280);
}

class _LightColors {
  final Color background = const Color(0xFFF3F4F6);
  final Color surface = const Color(0xFFFFFFFF);
  final Color surfaceLight = const Color(0xFFE5E7EB);
  final Color textPrimary = const Color(0xFF111827);
  final Color textSecondary = const Color(0xFF6B7280);
  final Color textMuted = const Color(0xFF9CA3AF);
}
