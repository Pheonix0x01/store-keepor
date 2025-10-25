import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class AppColors {
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color surfaceLight = Color(0xFF2C2C2C);
  static const Color primary = Color(0xFF6B6B6B);
  static const Color primaryLight = Color(0xFF8E8E8E);
  static const Color accent = Color(0xFFB0B0B0);
  static const Color textPrimary = Color(0xFFE5E5E5);
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color textTertiary = Color(0xFF6B6B6B);
  static const Color divider = Color(0xFF3A3A3A);
  static const Color error = Color(0xFFCF6679);
  static const Color success = Color(0xFF81C784);
  static const Color warning = Color(0xFFFFB74D);
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontFamily: 'SourceCodePro',
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontFamily: 'SourceCodePro',
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );
  
  static const TextStyle heading3 = TextStyle(
    fontFamily: 'SourceCodePro',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'SourceCodePro',
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'SourceCodePro',
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'SourceCodePro',
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
  
  static const TextStyle button = TextStyle(
    fontFamily: 'SourceCodePro',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
  );
}

class AppConstants {
  static const int lowStockThreshold = 10;
  static const String appName = 'StoreKeeper';
  static const String databaseName = 'products.db';
  static const int databaseVersion = 1;
}