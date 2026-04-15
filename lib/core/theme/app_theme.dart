import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: const TextTheme(
        headlineMedium: AppTextStyles.heading,
        bodyMedium: AppTextStyles.body,
      ),
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.secondary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.secondary,
        brightness: Brightness.dark,
      ),
    );
  }
}
