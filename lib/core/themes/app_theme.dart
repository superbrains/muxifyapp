import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';
import 'package:muxify/core/constants/app_sizes.dart';
import 'package:muxify/core/constants/app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.buttonColor,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.buttonColor,
      secondary: AppColors.blue,
      surface: AppColors.darkGreen,
      error: AppColors.buttonColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.text,
      onError: Colors.white,
    ),

    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: AppColors.darkGreen,
      foregroundColor: AppColors.text,
      iconTheme: const IconThemeData(color: AppColors.text),
      titleTextStyle: TextStyle(
        color: AppColors.text,
        fontSize: 18.font,
        fontWeight: FontWeight.w600,
      ),
    ),

    cardTheme: CardThemeData(
      elevation: 2.elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.radius),
      ),
      color: AppColors.darkGreen,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: AppColors.buttonColor,
        foregroundColor: Colors.white,
        minimumSize: Size(double.infinity, 48.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.radius),
        ),
        textStyle: TextStyle(fontSize: 16.font, fontWeight: FontWeight.w600),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.buttonColor,
        textStyle: TextStyle(fontSize: 16.font, fontWeight: FontWeight.w600),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.buttonColor,
        minimumSize: Size(double.infinity, 48.buttonHeight),
        side: BorderSide(color: AppColors.buttonColor, width: 1.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.radius),
        ),
        textStyle: TextStyle(fontSize: 16.font, fontWeight: FontWeight.w600),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkGreen,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.radius),
        borderSide: const BorderSide(color: AppColors.text),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.radius),
        borderSide: const BorderSide(color: AppColors.text),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.radius),
        borderSide: const BorderSide(color: AppColors.buttonColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.radius),
        borderSide: const BorderSide(color: AppColors.buttonColor),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16.padding,
        vertical: 16.padding,
      ),
    ),

    textTheme: const TextTheme(
      displayLarge: AppTextStyles.heading1,
      displayMedium: AppTextStyles.heading2,
      displaySmall: AppTextStyles.buttonText,
      headlineLarge: AppTextStyles.heading1,
      headlineMedium: AppTextStyles.heading2,
      headlineSmall: AppTextStyles.buttonText,
      titleLarge: AppTextStyles.mediumText,
      titleMedium: AppTextStyles.bodyLarge,
      titleSmall: AppTextStyles.bodyMedium,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodyMedium,
      bodySmall: AppTextStyles.bodySmall,
      labelLarge: AppTextStyles.buttonText,
      labelMedium: AppTextStyles.bodyMedium,
      labelSmall: AppTextStyles.bodySmall,
    ),

    iconTheme: IconThemeData(color: AppColors.text, size: 24.icon),

    dividerTheme: DividerThemeData(color: AppColors.text, thickness: 1.border),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.buttonColor,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.buttonColor,
      secondary: AppColors.blue,
      surface: AppColors.darkGreen,
      error: AppColors.buttonColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.text,
      onError: Colors.white,
    ),

    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: AppColors.darkGreen,
      foregroundColor: AppColors.text,
      iconTheme: const IconThemeData(color: AppColors.text),
      titleTextStyle: TextStyle(
        color: AppColors.text,
        fontSize: 18.font,
        fontWeight: FontWeight.w600,
      ),
    ),

    cardTheme: CardThemeData(
      elevation: 2.elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.radius),
      ),
      color: AppColors.darkGreen,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: AppColors.buttonColor,
        foregroundColor: Colors.white,
        minimumSize: Size(double.infinity, 48.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.radius),
        ),
        textStyle: TextStyle(fontSize: 16.font, fontWeight: FontWeight.w600),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.buttonColor,
        textStyle: TextStyle(fontSize: 16.font, fontWeight: FontWeight.w600),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.buttonColor,
        minimumSize: Size(double.infinity, 48.buttonHeight),
        side: BorderSide(color: AppColors.buttonColor, width: 1.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.radius),
        ),
        textStyle: TextStyle(fontSize: 16.font, fontWeight: FontWeight.w600),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkGreen,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.radius),
        borderSide: const BorderSide(color: AppColors.text),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.radius),
        borderSide: const BorderSide(color: AppColors.text),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.radius),
        borderSide: const BorderSide(color: AppColors.buttonColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.radius),
        borderSide: const BorderSide(color: AppColors.buttonColor),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16.padding,
        vertical: 16.padding,
      ),
    ),

    textTheme: const TextTheme(
      displayLarge: AppTextStyles.heading1,
      displayMedium: AppTextStyles.heading2,
      displaySmall: AppTextStyles.buttonText,
      headlineLarge: AppTextStyles.heading1,
      headlineMedium: AppTextStyles.heading2,
      headlineSmall: AppTextStyles.buttonText,
      titleLarge: AppTextStyles.mediumText,
      titleMedium: AppTextStyles.bodyLarge,
      titleSmall: AppTextStyles.bodyMedium,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodyMedium,
      bodySmall: AppTextStyles.bodySmall,
      labelLarge: AppTextStyles.buttonText,
      labelMedium: AppTextStyles.bodyMedium,
      labelSmall: AppTextStyles.bodySmall,
    ),

    iconTheme: IconThemeData(color: AppColors.text, size: 24.icon),

    dividerTheme: DividerThemeData(color: AppColors.text, thickness: 1.border),
  );
}
