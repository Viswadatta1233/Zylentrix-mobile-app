/**
 * App Colors Configuration
 * 
 * Defines the color palette for the application.
 * Matches the web implementation with gradient colors.
 */

import 'package:flutter/material.dart';

class AppColors {
  // Primary gradient colors (blue to purple)
  static const Color primaryBlue = Color(0xFF2563EB); // Blue-600
  static const Color primaryPurple = Color(0xFF9333EA); // Purple-600
  
  // Accent colors
  static const Color accentBlue = Color(0xFF3B82F6); // Blue-500
  static const Color accentPurple = Color(0xFFA855F7); // Purple-500
  
  // Status colors
  static const Color successGreen = Color(0xFF10B981); // Green-500
  static const Color warningOrange = Color(0xFFF59E0B); // Orange-500
  static const Color errorRed = Color(0xFFEF4444); // Red-500
  
  // Task status colors
  static const Color completedGreen = Color(0xFF22C55E); // Green-600
  static const Color pendingOrange = Color(0xFFEA580C); // Orange-600
  
  // Light mode background
  static const Color lightBackground = Color(0xFFEBF4FF); // Blue-50
  static const Color lightCardBackground = Color(0xFFFFFFFF);
  
  // Dark mode background
  static const Color darkBackground = Color(0xFF111827); // Gray-900
  static const Color darkCardBackground = Color(0xFF1F2937); // Gray-800
  
  // Text colors for light mode
  static const Color lightTextPrimary = Color(0xFF1F2937); // Gray-800
  static const Color lightTextSecondary = Color(0xFF6B7280); // Gray-600
  
  // Text colors for dark mode
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFD1D5DB); // Gray-300
  
  // Border colors
  static const Color lightBorder = Color(0xFFE5E7EB); // Gray-200
  static const Color darkBorder = Color(0xFF374151); // Gray-700
  
  // Primary gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, primaryPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Completed task gradient
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Pending task gradient
  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Error gradient
  static const LinearGradient errorGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

