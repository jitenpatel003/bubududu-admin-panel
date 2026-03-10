import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF6D28D9);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFEA580C);
  static const Color danger = Color(0xFFDC2626);
  static const Color background = Color(0xFFF8F9FC);
  static const Color card = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSubtext = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);

  // Status badge colors
  static const Color statusScriptReview = Color(0xFF3B82F6);
  static const Color statusScriptApproved = Color(0xFF16A34A);
  static const Color statusInProgress = Color(0xFFEA580C);
  static const Color statusPreviewSent = Color(0xFF7C3AED);
  static const Color statusCompleted = Color(0xFF15803D);
  static const Color statusDraft = Color(0xFF6B7280);

  // Deadline colors
  static const Color deadlineGreen = Color(0xFF16A34A);
  static const Color deadlineYellow = Color(0xFFCA8A04);
  static const Color deadlineOrange = Color(0xFFEA580C);
  static const Color deadlineRed = Color(0xFFDC2626);

  // Priority colors
  static const Color priorityNormal = Color(0xFF6B7280);
  static const Color priorityHigh = Color(0xFFEA580C);
  static const Color priorityVip = Color(0xFF7C3AED);

  static Color statusColor(String status) {
    switch (status) {
      case 'Script Review':
        return statusScriptReview;
      case 'Script Approved':
        return statusScriptApproved;
      case 'In Progress':
        return statusInProgress;
      case 'Preview Sent':
        return statusPreviewSent;
      case 'Completed':
        return statusCompleted;
      case 'Draft':
        return statusDraft;
      default:
        return statusDraft;
    }
  }

  static Color priorityColor(String priority) {
    switch (priority) {
      case 'High':
        return priorityHigh;
      case 'VIP':
        return priorityVip;
      default:
        return priorityNormal;
    }
  }

  static Color deadlineColor(int daysRemaining) {
    if (daysRemaining < 0) return deadlineRed;
    if (daysRemaining <= 2) return deadlineOrange;
    if (daysRemaining <= 7) return deadlineYellow;
    return deadlineGreen;
  }
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        background: AppColors.background,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.nunitoTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.card,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSubtext,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.card,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}
