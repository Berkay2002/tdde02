import 'package:flutter/material.dart';

/// Application color palette
/// Color scheme designed for a fresh, natural cooking/recipe app aesthetic
class AppColors {
  // Primary Color Palette

  /// Dark slate gray - Primary color for headers, important UI elements
  static const Color darkSlateGray = Color(0xFF35524A);
  static const Color darkSlateGray100 = Color(0xFF0A100E);
  static const Color darkSlateGray200 = Color(0xFF15201D);
  static const Color darkSlateGray300 = Color(0xFF1F302B);
  static const Color darkSlateGray400 = Color(0xFF2A403A);
  static const Color darkSlateGray500 = Color(0xFF35524A);
  static const Color darkSlateGray600 = Color(0xFF527E72);
  static const Color darkSlateGray700 = Color(0xFF76A698);
  static const Color darkSlateGray800 = Color(0xFFA4C3BA);
  static const Color darkSlateGray900 = Color(0xFFD1E1DD);

  /// Slate gray - Secondary color for text and subtle UI elements
  static const Color slateGray = Color(0xFF627C85);
  static const Color slateGray100 = Color(0xFF14191A);
  static const Color slateGray200 = Color(0xFF273135);
  static const Color slateGray300 = Color(0xFF3B4A4F);
  static const Color slateGray400 = Color(0xFF4E636A);
  static const Color slateGray500 = Color(0xFF627C85);
  static const Color slateGray600 = Color(0xFF7E97A0);
  static const Color slateGray700 = Color(0xFF9EB1B7);
  static const Color slateGray800 = Color(0xFFBECBCF);
  static const Color slateGray900 = Color(0xFFDFE5E7);

  /// Air superiority blue - Accent color for interactive elements
  static const Color airSuperiorityBlue = Color(0xFF779CAB);
  static const Color airSuperiorityBlue100 = Color(0xFF162024);
  static const Color airSuperiorityBlue200 = Color(0xFF2C4048);
  static const Color airSuperiorityBlue300 = Color(0xFF42606C);
  static const Color airSuperiorityBlue400 = Color(0xFF588090);
  static const Color airSuperiorityBlue500 = Color(0xFF779CAB);
  static const Color airSuperiorityBlue600 = Color(0xFF92B0BC);
  static const Color airSuperiorityBlue700 = Color(0xFFADC4CD);
  static const Color airSuperiorityBlue800 = Color(0xFFC9D8DE);
  static const Color airSuperiorityBlue900 = Color(0xFFE4EBEE);

  /// Tiffany blue - Highlight color for special features
  static const Color tiffanyBlue = Color(0xFFA2E8DD);
  static const Color tiffanyBlue100 = Color(0xFF103F38);
  static const Color tiffanyBlue200 = Color(0xFF1F7E70);
  static const Color tiffanyBlue300 = Color(0xFF2FBCA7);
  static const Color tiffanyBlue400 = Color(0xFF62D8C6);
  static const Color tiffanyBlue500 = Color(0xFFA2E8DD);
  static const Color tiffanyBlue600 = Color(0xFFB4ECE4);
  static const Color tiffanyBlue700 = Color(0xFFC7F1EB);
  static const Color tiffanyBlue800 = Color(0xFFD9F6F1);
  static const Color tiffanyBlue900 = Color(0xFFECFAF8);

  /// Emerald - Success color, fresh/organic indicator
  static const Color emerald = Color(0xFF32DE8A);
  static const Color emerald100 = Color(0xFF082E1C);
  static const Color emerald200 = Color(0xFF0F5D37);
  static const Color emerald300 = Color(0xFF178B53);
  static const Color emerald400 = Color(0xFF1EBA6F);
  static const Color emerald500 = Color(0xFF32DE8A);
  static const Color emerald600 = Color(0xFF5AE4A1);
  static const Color emerald700 = Color(0xFF83EBB9);
  static const Color emerald800 = Color(0xFFADF2D0);
  static const Color emerald900 = Color(0xFFD6F8E8);

  // Semantic Color Mappings

  /// Primary color for main actions and branding
  static const Color primary = darkSlateGray;

  /// Secondary color for supporting UI elements
  static const Color secondary = slateGray;

  /// Accent color for interactive elements and highlights
  static const Color accent = airSuperiorityBlue;

  /// Success color for positive feedback
  static const Color success = emerald;

  /// Info color for informational messages
  static const Color info = tiffanyBlue;

  /// Warning color
  static const Color warning = Color(0xFFFF9800);

  /// Error color
  static const Color error = Color(0xFFB3261E);

  // Text Colors

  /// Primary text color (dark mode: light, light mode: dark)
  static const Color textPrimary = darkSlateGray500;

  /// Secondary text color (slightly muted)
  static const Color textSecondary = slateGray500;

  /// Tertiary text color (most muted)
  static const Color textTertiary = slateGray700;

  /// Text on colored backgrounds
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Background Colors

  /// Light background
  static const Color backgroundLight = Color(0xFFFFFBFE);

  /// Dark background
  static const Color backgroundDark = Color(0xFF1C1B1F);

  /// Surface color (cards, sheets)
  static const Color surface = Color(0xFFFFFFFF);

  /// Surface variant (slightly different from surface)
  static const Color surfaceVariant = darkSlateGray900;

  // Border and Divider Colors

  /// Border color
  static const Color border = slateGray800;

  /// Divider color
  static const Color divider = slateGray900;

  // Gradient Definitions

  /// Primary gradient (dark slate gray to air superiority blue)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [darkSlateGray, airSuperiorityBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Fresh gradient (tiffany blue to emerald)
  static const LinearGradient freshGradient = LinearGradient(
    colors: [tiffanyBlue, emerald],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Subtle gradient (slate gray variations)
  static const LinearGradient subtleGradient = LinearGradient(
    colors: [slateGray800, slateGray900],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
