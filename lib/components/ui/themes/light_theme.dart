import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_academy/models/models.dart';

// Modern Color Palette
Color primaryColor = const Color(0xFF6366F1); // Indigo-500
Color primaryVariant = const Color(0xFF4F46E5); // Indigo-600
Color secondaryColor = const Color(0xFF10B981); // Emerald-500
Color secondaryVariant = const Color(0xFF059669); // Emerald-600
Color surfaceColor = const Color(0xFFFAFAFA); // Neutral-50
Color backgroundColor = const Color(0xFFFFFFFF); // White
Color headerBackgroundColor = const Color(0xFFFFFFFF); // White
const errorColor = Color(0xFFEF4444); // Red-500
const warningColor = Color(0xFFF59E0B); // Amber-500
const successColor = Color(0xFF10B981); // Emerald-500
const infoColor = Color(0xFF3B82F6); // Blue-500

// Dark colors for contrast
const darkColor = Color(0xFF1F2937); // Gray-800
const darkVariant = Color(0xFF111827); // Gray-900
const onSurfaceColor = Color(0xFF374151); // Gray-700
const onSurfaceVariant = Color(0xFF6B7280); // Gray-500

Color _parseHexColor(String? value, Color fallback) {
  if (value == null || value.trim().isEmpty) {
    return fallback;
  }

  final hex = value.replaceAll('#', '').trim();
  if (hex.length != 6 && hex.length != 8) {
    return fallback;
  }

  final normalized = hex.length == 6 ? 'FF$hex' : hex;
  final colorValue = int.tryParse(normalized, radix: 16);
  if (colorValue == null) {
    return fallback;
  }
  return Color(colorValue);
}

Color _darken(Color color, [double amount = 0.15]) {
  final hsl = HSLColor.fromColor(color);
  final adjusted = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
  return adjusted.toColor();
}

void applyDynamicPalette(AppBranding? appBranding) {
  if (appBranding == null) {
    return;
  }

  primaryColor = _parseHexColor(appBranding.primaryColor, primaryColor);
  secondaryColor = _parseHexColor(appBranding.secondaryColor, secondaryColor);
  backgroundColor = _parseHexColor(appBranding.backgroundColor, backgroundColor);
  surfaceColor = _parseHexColor(appBranding.surfaceColor, surfaceColor);
  headerBackgroundColor = _parseHexColor(
    appBranding.headerBackgroundColor,
    headerBackgroundColor,
  );
  primaryVariant = _darken(primaryColor);
  secondaryVariant = _darken(secondaryColor);
}

ThemeData lightTheme(BuildContext context) {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Color Scheme
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      primaryContainer: primaryColor.withOpacity(0.1),
      secondary: secondaryColor,
      secondaryContainer: secondaryColor.withOpacity(0.1),
      surface: surfaceColor,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: onSurfaceColor,
      onSurfaceVariant: onSurfaceVariant,
      onError: Colors.white,
      outline: onSurfaceVariant.withOpacity(0.3),
      shadow: darkColor.withOpacity(0.1),
    ),

    // Typography
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: darkColor,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: darkColor,
        letterSpacing: -0.25,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: darkColor,
      ),
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: darkColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: darkColor,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: darkColor,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: darkColor,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: darkColor,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: darkColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: onSurfaceColor,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: onSurfaceColor,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: onSurfaceVariant,
        height: 1.4,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: onSurfaceColor,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: onSurfaceColor,
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: onSurfaceVariant,
        letterSpacing: 0.5,
      ),
    ),

    scaffoldBackgroundColor: backgroundColor,

    // App Bar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: headerBackgroundColor,
      foregroundColor: darkColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: darkColor,
      ),
      iconTheme: IconThemeData(color: darkColor),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: onSurfaceVariant.withOpacity(0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: onSurfaceVariant.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: errorColor, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: errorColor, width: 2),
      ),
      labelStyle: TextStyle(
        color: onSurfaceVariant,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: TextStyle(
        color: onSurfaceVariant.withOpacity(0.7),
        fontWeight: FontWeight.w400,
      ),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shadowColor: primaryColor.withOpacity(0.3),
        elevation: 2,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.25,
        ),
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.25,
        ),
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: BorderSide(color: primaryColor, width: 1.5),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.25,
        ),
      ),
    ),

    // Icon Button Theme
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: onSurfaceColor,
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: backgroundColor,
      shadowColor: darkColor.withOpacity(0.05),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.zero,
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: backgroundColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: onSurfaceVariant,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),

    // Tab Bar Theme
    tabBarTheme: TabBarThemeData(
      labelColor: primaryColor,
      unselectedLabelColor: onSurfaceVariant,
      indicatorColor: primaryColor,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),

    // Floating Action Button Theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    // List Tile Theme
    listTileTheme: ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titleTextStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: darkColor,
      ),
      subtitleTextStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: onSurfaceVariant,
      ),
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: surfaceColor,
      deleteIconColor: onSurfaceVariant,
      disabledColor: onSurfaceVariant.withOpacity(0.12),
      selectedColor: primaryColor.withOpacity(0.12),
      secondarySelectedColor: secondaryColor.withOpacity(0.12),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: onSurfaceColor,
      ),
      secondaryLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: onSurfaceColor,
      ),
      brightness: Brightness.light,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    // Divider Theme
    dividerTheme: DividerThemeData(
      color: onSurfaceVariant.withOpacity(0.12),
      thickness: 1,
      space: 1,
    ),

    // Progress Indicator Theme
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: primaryColor,
      linearTrackColor: primaryColor.withOpacity(0.2),
      circularTrackColor: primaryColor.withOpacity(0.2),
    ),
  );
}
