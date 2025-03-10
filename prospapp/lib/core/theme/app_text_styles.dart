import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.w800,
    fontSize: 28,
    color: AppColors.textDark,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.normal,
    fontSize: 14,
    color: AppColors.textGrey,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.bold,
    fontSize: 18,
    color: AppColors.white,
  );

  static TextStyle prospectTitle(double fontSize) => TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.bold,
    fontSize: fontSize,
    color: AppColors.textDark,
  );

  static TextStyle prospectSubtitle(double fontSize) => TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.normal,
    fontSize: fontSize,
    color: AppColors.textGrey,
  );
}