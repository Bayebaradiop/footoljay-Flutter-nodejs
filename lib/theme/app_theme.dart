import 'package:flutter/material.dart';

class AppTheme {
  // ==================== COULEURS ====================
  // Palette principale : Violet et Blanc
  static const Color primaryColor = Color(0xFF7C4DFF); // Violet moderne
  static const Color secondaryColor = Color(0xFFFFFFFF); // Blanc
  
  // Accents
  static const Color backgroundColor = Color(0xFFF5F5F5); // Gris très clair
  static const Color surfaceColor = Color(0xFFFFFFFF); // Blanc
  static const Color cardColor = Color(0xFFFFFFFF); // Blanc
  
  // Gris
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color mediumGrey = Color(0xFF9E9E9E);
  static const Color darkGrey = Color(0xFF616161);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  
  // États
  static const Color successColor = Color(0xFF4CAF50); // Vert
  static const Color errorColor = Color(0xFFF44336); // Rouge
  static const Color warningColor = Color(0xFFFF9800); // Orange
  static const Color infoColor = Color(0xFF2196F3); // Bleu info
  
  // ==================== TYPOGRAPHY ====================
  static const String fontFamily = 'Roboto';
  
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -0.5,
  );
  
  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -0.3,
  );
  
  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: -0.2,
  );
  
  static const TextStyle subtitle1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );
  
  static const TextStyle subtitle2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textSecondary,
  );
  
  static const TextStyle bodyText1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimary,
    height: 1.5,
  );
  
  static const TextStyle bodyText2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textSecondary,
    height: 1.5,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textSecondary,
  );
  
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
  
  // ==================== SPACING ====================
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 16.0;
  static const double spacingLG = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;
  
  // ==================== BORDER RADIUS ====================
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusFull = 999.0;
  
  // ==================== ELEVATION ====================
  static const double elevationSM = 2.0;
  static const double elevationMD = 4.0;
  static const double elevationLG = 8.0;
  
  // ==================== THEME DATA ====================
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      
      // Colors
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      
      // Color Scheme
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: primaryColor,
        surface: surfaceColor,
        background: backgroundColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onBackground: textPrimary,
        onError: Colors.white,
      ),
      
      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: h2.copyWith(fontSize: 20),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      
      // Card
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: elevationSM,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMD),
        ),
        margin: EdgeInsets.all(spacingSM),
      ),
      
      // Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: elevationSM,
          padding: EdgeInsets.symmetric(
            horizontal: spacingLG,
            vertical: spacingMD,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMD),
          ),
          textStyle: button,
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          padding: EdgeInsets.symmetric(
            horizontal: spacingLG,
            vertical: spacingMD,
          ),
          side: BorderSide(color: primaryColor, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMD),
          ),
          textStyle: button,
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: EdgeInsets.symmetric(
            horizontal: spacingLG,
            vertical: spacingMD,
          ),
          textStyle: button,
        ),
      ),
      
      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: EdgeInsets.all(spacingMD),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: BorderSide(color: lightGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: BorderSide(color: lightGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: BorderSide(color: errorColor),
        ),
        labelStyle: subtitle2,
        hintStyle: bodyText2,
      ),
      
      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: backgroundColor,
        selectedColor: primaryColor.withOpacity(0.2),
        labelStyle: subtitle2,
        padding: EdgeInsets.symmetric(
          horizontal: spacingMD,
          vertical: spacingSM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusFull),
        ),
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: mediumGrey,
        elevation: elevationMD,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: caption.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: caption,
      ),
      
      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: elevationMD,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLG),
        ),
      ),
      
      // Divider
      dividerTheme: DividerThemeData(
        color: lightGrey,
        thickness: 1,
        space: spacingMD,
      ),
      
      // Icon
      iconTheme: IconThemeData(
        color: textPrimary,
        size: 24,
      ),
    );
  }
  
  // ==================== SHADOWS ====================
  static List<BoxShadow> get shadowSM => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      offset: Offset(0, 2),
      blurRadius: 4,
    ),
  ];
  
  static List<BoxShadow> get shadowMD => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      offset: Offset(0, 4),
      blurRadius: 8,
    ),
  ];
  
  static List<BoxShadow> get shadowLG => [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      offset: Offset(0, 8),
      blurRadius: 16,
    ),
  ];
  
  // ==================== GRADIENTS ====================
  static LinearGradient get primaryGradient => LinearGradient(
    colors: [
      primaryColor,
      primaryColor.withOpacity(0.8),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // ==================== HELPER METHODS ====================
  static BoxDecoration cardDecoration({Color? color}) => BoxDecoration(
    color: color ?? cardColor,
    borderRadius: BorderRadius.circular(radiusMD),
    boxShadow: shadowSM,
  );
  
  static BoxDecoration chipDecoration({
    required Color color,
    bool selected = false,
  }) => BoxDecoration(
    color: selected ? color.withOpacity(0.2) : backgroundColor,
    borderRadius: BorderRadius.circular(radiusFull),
    border: Border.all(
      color: selected ? color : lightGrey,
      width: selected ? 2 : 1,
    ),
  );
  
  static BoxDecoration statusChipDecoration(String status) {
    Color color;
    switch (status.toUpperCase()) {
      case 'APPROVED':
        color = successColor;
        break;
      case 'PENDING':
        color = warningColor;
        break;
      case 'REJECTED':
        color = errorColor;
        break;
      default:
        color = mediumGrey;
    }
    
    return BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(radiusSM),
      border: Border.all(color: color.withOpacity(0.3)),
    );
  }
}
