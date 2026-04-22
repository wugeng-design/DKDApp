import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF0D0D0D);
  static const Color accentColor = Color(0xFFC6A86E);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFF7F7F7);
  static const Color textColor = Color(0xFF0D0D0D);
  static const Color textSecondaryColor = Color(0xFF666666);

  static const double borderRadius = 16.0;
  static const double cardPadding = 16.0;

  static const TextStyle titleStyle = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    color: primaryColor,
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    color: primaryColor,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16.0,
    color: textColor,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 13.0,
    color: textSecondaryColor,
  );

  static final ThemeData themeData = ThemeData(
    primaryColor: primaryColor,
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: MaterialColor(
        primaryColor.value,
        <int, Color>{
          50: primaryColor.withOpacity(0.1),
          100: primaryColor.withOpacity(0.2),
          200: primaryColor.withOpacity(0.3),
          300: primaryColor.withOpacity(0.4),
          400: primaryColor.withOpacity(0.5),
          500: primaryColor,
          600: primaryColor.withOpacity(0.7),
          700: primaryColor.withOpacity(0.8),
          800: primaryColor.withOpacity(0.9),
          900: primaryColor.withOpacity(0.95),
        },
      ),
    ).copyWith(
      secondary: accentColor,
      background: backgroundColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    cardColor: cardColor,
    textTheme: TextTheme(
      titleLarge: titleStyle,
      titleMedium: subtitleStyle,
      bodyLarge: bodyStyle,
      bodyMedium: bodyStyle,
      bodySmall: captionStyle,
      labelSmall: captionStyle,
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: accentColor,
      textTheme: ButtonTextTheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor,
        foregroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 24.0,
          vertical: 12.0,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: accentColor, width: 2.0),
      ),
    ),
  );
}