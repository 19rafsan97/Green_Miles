import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Core palette
  static const Color mint = Color(0xFFF1F8EE);
  static const Color forest = Color(0xFF1B5E20);
  static const Color leaf = Color(0xFF4CAF50);
  static const Color lime = Color(0xFF7ED957);
  static const Color charcoal = Color(0xFF0F1A13);
  static const Color mist = Color(0xCCFFFFFF);
  static const Color shadowColor = Color(0x1A1B5E20);

  static const Color primaryColor = forest;
  static const Color secondaryColor = leaf;
  static const Color accentColor = lime;
  static const Color backgroundColor = mint;
  static const Color surfaceColor = Colors.white;
  static const Color textColor = charcoal;
  static const Color subtitleTextColor = Color(0xFF5B6E60);
  static const Color successColor = Color(0xFF1FA464);

  // Soft shadows & radii
  static final List<BoxShadow> softShadow = [
    BoxShadow(
      color: forest.withValues(alpha: 0.08),
      blurRadius: 30,
      spreadRadius: 0,
      offset: const Offset(0, 12),
    ),
  ];

  static final List<BoxShadow> glowShadow = [
    BoxShadow(
      color: leaf.withValues(alpha: 0.18),
      blurRadius: 36,
      spreadRadius: 2,
      offset: const Offset(0, 10),
    ),
  ];

  static const double radiusL = 24;
  static const double radiusM = 18;
  static const double radiusXL = 30;
  static const double radiusXXL = 40;

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient mintGlass = LinearGradient(
    colors: [Color(0xB3FFFFFF), Color(0x99FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Typography
  static TextTheme textTheme = TextTheme(
    displayLarge: GoogleFonts.poppins(fontSize: 56, fontWeight: FontWeight.w800, color: textColor),
    displayMedium: GoogleFonts.poppins(fontSize: 46, fontWeight: FontWeight.w800, color: textColor),
    displaySmall: GoogleFonts.poppins(fontSize: 38, fontWeight: FontWeight.w700, color: textColor),
    headlineLarge: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w700, color: textColor),
    headlineMedium: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700, color: textColor),
    headlineSmall: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600, color: textColor.withValues(alpha: 0.92)),
    titleLarge: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: textColor),
    titleMedium: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.2, color: subtitleTextColor),
    titleSmall: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.2, color: subtitleTextColor),
    bodyLarge: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: subtitleTextColor.withValues(alpha: 0.9)),
    bodyMedium: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: subtitleTextColor.withValues(alpha: 0.9)),
    bodySmall: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: subtitleTextColor.withValues(alpha: 0.8)),
    labelLarge: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
    labelMedium: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
    labelSmall: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white70),
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: backgroundColor,
    primaryColor: primaryColor,
    fontFamily: GoogleFonts.poppins().fontFamily,
    textTheme: textTheme,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0, foregroundColor: textColor),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: BorderSide(color: subtitleTextColor.withValues(alpha: 0.16)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: BorderSide(color: subtitleTextColor.withValues(alpha: 0.16)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: const BorderSide(color: primaryColor, width: 1.4),
      ),
      labelStyle: textTheme.bodyMedium,
    ),
    cardTheme: CardThemeData(
      color: surfaceColor,
      shadowColor: forest.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusL)),
      elevation: 0,
      margin: EdgeInsets.zero,
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: primaryColor.withValues(alpha: 0.5)),
        foregroundColor: primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusXL)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusXXL)),
        foregroundColor: Colors.white,
        backgroundColor: primaryColor,
        textStyle: textTheme.labelLarge,
        shadowColor: leaf.withValues(alpha: 0.15),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: primaryColor.withValues(alpha: 0.12),
      elevation: 0,
      height: 68,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final isSelected = states.contains(WidgetState.selected);
        return textTheme.labelMedium?.copyWith(
          color: isSelected ? primaryColor : subtitleTextColor,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final isSelected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: isSelected ? primaryColor : subtitleTextColor,
          size: 24,
        );
      }),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white,
      selectedColor: primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      side: BorderSide(color: subtitleTextColor.withValues(alpha: 0.2)),
      labelStyle: textTheme.bodyMedium ?? const TextStyle(),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: secondaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: accentColor,
      circularTrackColor: Color(0xFFE6F2E5),
    ),
    dividerColor: subtitleTextColor.withValues(alpha: 0.12),
  );
}

