import 'package:flutter/material.dart';
import 'package:muxify/core/constants/app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String _manrope = 'Manrope';
  static const String _poppins = 'Poppins';
  static const String _luckiestGuy = 'Luckiest Guy';
  static const String _inter = 'Inter';
  static const TextStyle heading1 = TextStyle(
    fontFamily: _manrope,
    fontWeight: FontWeight.w900,
    fontSize: 36.0,
    color: AppColors.text,
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: _manrope,
    fontWeight: FontWeight.w600,
    fontSize: 28.0,
    color: AppColors.text,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _manrope,
    fontWeight: FontWeight.w400,
    fontSize: 16.0,
    color: AppColors.text,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _manrope,
    fontWeight: FontWeight.w400,
    fontSize: 14.0,
    color: AppColors.text,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _manrope,
    fontWeight: FontWeight.w400,
    fontSize: 16.0,
    color: AppColors.text,
  );

  static const TextStyle buttonText = TextStyle(
    fontFamily: _manrope,
    fontWeight: FontWeight.w600,
    fontSize: 18.0,
    color: AppColors.text,
  );
  static const TextStyle unlockButtonText = TextStyle(
    fontFamily: _inter,
    fontWeight: FontWeight.w500,
    fontSize: 12.0,
    color: AppColors.background,
  );

  static const TextStyle specialText = TextStyle(
    fontFamily: _poppins,
    fontWeight: FontWeight.w500,
    fontSize: 19.69,
    color: AppColors.text,
  );

  static const TextStyle mediumText = TextStyle(
    fontFamily: _manrope,
    fontWeight: FontWeight.w500,
    fontSize: 16.0,
    color: AppColors.text,
  );

  static const TextStyle displayText = TextStyle(
    fontFamily: _luckiestGuy,
    fontWeight: FontWeight.w400,
    fontSize: 16.0,
    color: AppColors.text,
  );

  static TextStyle heading1WithColor(Color color) =>
      heading1.copyWith(color: color);
  static TextStyle heading2WithColor(Color color) =>
      heading2.copyWith(color: color);
  static TextStyle bodyLargeWithColor(Color color) =>
      bodyLarge.copyWith(color: color);
  static TextStyle bodyMediumWithColor(Color color) =>
      bodyMedium.copyWith(color: color);
  static TextStyle bodySmallWithColor(Color color) =>
      bodySmall.copyWith(color: color);
  static TextStyle unlockButtonTextWithColor(Color color) =>
      unlockButtonText.copyWith(color: color);
  static TextStyle buttonTextWithColor(Color color) =>
      buttonText.copyWith(color: color);
  static TextStyle specialTextWithColor(Color color) =>
      specialText.copyWith(color: color);
  static TextStyle mediumTextWithColor(Color color) =>
      mediumText.copyWith(color: color);
  static TextStyle displayTextWithColor(Color color) =>
      displayText.copyWith(color: color);

  static TextStyle heading1Bold = heading1.copyWith(
    fontWeight: FontWeight.bold,
  );
  static TextStyle heading2Bold = heading2.copyWith(
    fontWeight: FontWeight.bold,
  );
  static TextStyle bodyLargeBold = bodyLarge.copyWith(
    fontWeight: FontWeight.bold,
  );
  static TextStyle bodyMediumBold = bodyMedium.copyWith(
    fontWeight: FontWeight.bold,
  );
  static TextStyle bodySmallBold = bodySmall.copyWith(
    fontWeight: FontWeight.bold,
  );

  static TextStyle heading1WithSize(double size) =>
      heading1.copyWith(fontSize: size);
  static TextStyle heading2WithSize(double size) =>
      heading2.copyWith(fontSize: size);
  static TextStyle bodyLargeWithSize(double size) =>
      bodyLarge.copyWith(fontSize: size);
  static TextStyle bodyMediumWithSize(double size) =>
      bodyMedium.copyWith(fontSize: size);
  static TextStyle bodySmallWithSize(double size) =>
      bodySmall.copyWith(fontSize: size);
  static TextStyle unlockButtonTextWithSize(double size) =>
      unlockButtonText.copyWith(fontSize: size);
  static TextStyle buttonTextWithSize(double size) =>
      buttonText.copyWith(fontSize: size);
  static TextStyle specialTextWithSize(double size) =>
      specialText.copyWith(fontSize: size);
  static TextStyle mediumTextWithSize(double size) =>
      mediumText.copyWith(fontSize: size);
  static TextStyle displayTextWithSize(double size) =>
      displayText.copyWith(fontSize: size);
}
