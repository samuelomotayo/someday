import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _slate = Color(0xFF1C2B3A);
const _amber = Color(0xFFC97D3A);
const _ash = Color(0xFFF0EDE8);
const _sage = Color(0xFF7A8C7E);

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: _amber,
      onPrimary: Colors.white,
      secondary: _sage,
      onSecondary: Colors.white,
      surface: _ash,
      onSurface: _slate,
      surfaceContainerHighest: const Color(0xFFE8E4DE),
      outline: const Color(0xFFBDB8B0),
    ),
    scaffoldBackgroundColor: _ash,
  );

  final fraunces = GoogleFonts.fraunces;
  final dmSans = GoogleFonts.dmSans;

  final textTheme = TextTheme(
    displayLarge: fraunces(fontSize: 57, fontWeight: FontWeight.w400, color: _slate),
    displayMedium: fraunces(fontSize: 45, fontWeight: FontWeight.w400, color: _slate),
    displaySmall: fraunces(fontSize: 36, fontWeight: FontWeight.w400, color: _slate),
    headlineLarge: fraunces(fontSize: 32, fontWeight: FontWeight.w400, color: _slate),
    headlineMedium: fraunces(fontSize: 28, fontWeight: FontWeight.w400, color: _slate),
    headlineSmall: fraunces(fontSize: 24, fontWeight: FontWeight.w400, color: _slate),
    titleLarge: dmSans(fontSize: 22, fontWeight: FontWeight.w500, color: _slate),
    titleMedium: dmSans(fontSize: 16, fontWeight: FontWeight.w500, color: _slate),
    titleSmall: dmSans(fontSize: 14, fontWeight: FontWeight.w500, color: _slate),
    bodyLarge: dmSans(fontSize: 16, color: _slate),
    bodyMedium: dmSans(fontSize: 14, color: _slate),
    bodySmall: dmSans(fontSize: 12, color: _slate.withValues(alpha: 0.7)),
    labelLarge: dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
    labelMedium: dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: _slate),
    labelSmall: dmSans(fontSize: 11, fontWeight: FontWeight.w500, color: _slate),
  );

  return base.copyWith(
    textTheme: textTheme,
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: const Color(0xFFE0DBD4), width: 1),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _amber,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: dmSans(fontSize: 16, fontWeight: FontWeight.w600),
        elevation: 0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0DBD4)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0DBD4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _amber, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: _ash,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: fraunces(fontSize: 22, fontWeight: FontWeight.w400, color: _slate),
      iconTheme: const IconThemeData(color: _slate),
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFFE0DBD4), thickness: 1),
  );
}
