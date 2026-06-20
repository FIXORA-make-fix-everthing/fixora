import 'package:flutter/material.dart';
import '../providers/app_state.dart';

class AppColors {
  // Primary Brand Color
  static const Color deepSilkPurple = Color(0xFF712262);
  // Buttons / Cards
  static const Color royalPurple = Color(0xFFC5A059);
  // Highlights
  static const Color luxuryMagenta = Color(0xFFB4356B);
  // Secondary Accent
  static const Color berryPink = Color(0xFFD76193);
  // CTA Buttons
  static const Color darkCherryRed = Color(0xFFC5A059);
  // Background Gradients
  static const Color softRose = Color(0xFFD5909C);
  // Premium Elements
  static const Color goldSilkS = Color(0xFFD4A24A);
  // Icons / Premium Text
  static const Color lightGold = Color(0xFFE7C78A);

  // Role based Neon Colors
  static const Color customerNeon = Color(0xFF00E5FF); // Cyan Neon
  static const Color providerNeon = Color(0xFFFF9100); // Orange Neon
  static const Color shopKeeperNeon = Color(0xFFD500F9); // Purple Neon

  static Color getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return customerNeon;
      case UserRole.provider:
        return providerNeon;
      case UserRole.shopKeeper:
        return shopKeeperNeon;
      default:
        return royalPurple;
    }
  }

  // Additional semantic colors used in the app (mapped from existing usage)
  static const Color accent = goldSilkS; // accent color
  static const Color background = Color(0xFF0F0F0F); // dark background
}
