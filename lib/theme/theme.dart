import 'package:flutter/material.dart';

///
/// Definition of App colors.
///
class RTAColors {
  static Color primary = const Color(0xFFECB476);

  static Color backgroundAccent = const Color(0xFFEDEDED);

  static Color neutralDark = const Color(0xFF054752);
  static Color neutral = const Color(0xFF3d5c62);
  static Color neutralLight = const Color(0xFF708c91);
  static Color neutralLighter = const Color(0xFF92A7AB);
  static Color success = const Color(0xFF4CAF50);
  static Color error = const Color(0xFFF44336);
  static Color warning = const Color(0xFFFFC107);
  static Color greyLight = const Color(0xFFE2E2E2);

  static Color white = Colors.white;

  static Color get backGroundColor {
    return RTAColors.primary;
  }

  static Color get textNormal {
    return RTAColors.neutralDark;
  }

  static Color get textLight {
    return RTAColors.neutralLight;
  }

  static Color get iconNormal {
    return RTAColors.neutral;
  }

  static Color get iconLight {
    return RTAColors.neutralLighter;
  }

  static Color get disabled {
    return RTAColors.greyLight;
  }
}

/// RTA = Race Tracking App
///
/// Definition of App text styles.
///
class RTATextStyles {
  static TextStyle heading = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w500,
  );

  static TextStyle title = TextStyle(fontSize: 20, fontWeight: FontWeight.w400);

  static TextStyle body = TextStyle(fontSize: 16, fontWeight: FontWeight.w400);

  static TextStyle label = TextStyle(fontSize: 13, fontWeight: FontWeight.w400);

  static TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
}

///
/// Definition of App spacings, in pixels.
/// Bascially small (S), medium (m), large (l), extra large (x), extra extra large (xxl)
///
class RTASpacings {
  static const double s = 12;
  static const double m = 16;
  static const double l = 24;
  static const double xl = 32;
  static const double xxl = 40;

  static const double radius = 16;
  static const double radiusLarge = 24;
}

class RTASize {
  static const double icon = 24;
}

///
/// Definition of App Theme.
///
ThemeData appTheme = ThemeData(
  fontFamily: 'Eesti',
  scaffoldBackgroundColor: Colors.white,
);
