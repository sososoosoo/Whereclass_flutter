import 'package:flutter/material.dart';

final ThemeData appTheme = _buildAppTheme();

ThemeData _buildAppTheme() {
// Colors tuned to your mocks
  const primary = Color(0xFF00AEFF); // bright blue - matching selected button color
  const onPrimary = Colors.white;
  const bg = Color(0xFFF5F7FA); // page gray
  const surface = Colors.white; // cards/sheets
  const textColor = Color(0xFF333D4B);
  const subText = Color(0xFF6B7280); // placeholders, secondary
  const outline = Color(0xFFE5E7EB); // hairline borders
  const focusRing = Color(0xFFDDE7FF); // subtle focus

  final scheme = ColorScheme.light(
    primary: primary,
    secondary: primary,
    surface: surface,
    background: bg,
    onPrimary: onPrimary,
    onSecondary: onPrimary,
    onSurface: textColor,
    onBackground: textColor,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: bg,

// Page background -> light gray

    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textColor, fontSize: 18),
      bodyMedium: TextStyle(color: textColor, fontSize: 16),
      bodySmall: TextStyle(color: textColor, fontSize: 14),
      titleLarge: TextStyle(
          color: textColor, fontSize: 20, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(
          color: textColor, fontSize: 18, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(
          color: textColor, fontSize: 16, fontWeight: FontWeight.w600),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: surface,
      foregroundColor: textColor,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: textColor),
      titleTextStyle: TextStyle(
        color: textColor,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),

// Search/Input look: subtle gray borders, blue focus
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      filled: true,
      fillColor: surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      hintStyle: const TextStyle(color: subText),
      floatingLabelStyle: const TextStyle(color: subText),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4.0),
        borderSide: BorderSide(color: outline), // outline gray
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4.0),
        borderSide: BorderSide(color: outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4.0),
        borderSide: BorderSide(color: primary, width: 1.5), // blue focus
      ),
      hoverColor: focusRing,
      labelStyle: TextStyle(color: subText), // secondary text gray
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        padding: WidgetStatePropertyAll<EdgeInsets>(
          EdgeInsets.symmetric(vertical: 16),
        ),
        backgroundColor: const WidgetStatePropertyAll<Color>(primary),
        foregroundColor: const WidgetStatePropertyAll<Color>(onPrimary),
        shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        textStyle: const WidgetStatePropertyAll<TextStyle>(
          TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        padding: WidgetStatePropertyAll<EdgeInsets>(
          EdgeInsets.symmetric(vertical: 16),
        ),
        foregroundColor: const WidgetStatePropertyAll<Color>(primary),
        overlayColor: WidgetStatePropertyAll<Color>(primary.withOpacity(0.1)),
        shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        textStyle: const WidgetStatePropertyAll<TextStyle>(
          TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: const WidgetStatePropertyAll<Color>(primary),
        side: const WidgetStatePropertyAll<BorderSide>(
          BorderSide(color: primary),
        ),
        overlayColor: WidgetStatePropertyAll<Color>(
          primary.withOpacity(0.1),
        ),
        textStyle: const WidgetStatePropertyAll<TextStyle>(
          TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      indicatorColor: Colors.transparent,
      labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            color: Color(0xFF00AEFF),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          );
        }
        return TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
          fontWeight: FontWeight.w500,
        );
      }),
    ),

// App-wide icon default -> dark gray/black (not blue)
    iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
  );
}
