import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppleColors {
  static const canvas = Color(0xFFF5F5F7);
  static const card = Color(0xFFFFFFFF);
  static const label = Color(0xFF1D1D1F);
  static const bodySecondary = Color(0xFF6E6E73);
  static const secondaryLabel = Color(0xFF86868B);
  static const tertiaryLabel = Color(0xFFAEAEB2);
  static const blue = Color(0xFF007AFF);
  static const searchFill = Color(0xFFF2F2F7);
  static const separator = Color(0xFFD2D2D7);
  static const fill = Color(0xFFE8E8ED);
}

class AppleSpacing {
  static const screen = 22.0;
  static const card = 22.0;
  static const element = 10.0;
  static const section = 28.0;
}

class AppleRadius {
  static const card = 24.0;
  static const search = 20.0;
  static const button = 28.0;
  static const tile = 16.0;
}

class AppleTextStyles {
  static const largeTitle = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.8,
    height: 1.05,
    color: AppleColors.label,
  );

  static const title2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    color: AppleColors.label,
  );

  static const title3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    color: AppleColors.label,
  );

  static const headline = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: AppleColors.label,
  );

  static const body = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: -0.1,
    color: AppleColors.bodySecondary,
  );

  static const callout = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppleColors.bodySecondary,
  );

  static const subheadline = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppleColors.secondaryLabel,
  );

  static const footnote = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppleColors.secondaryLabel,
  );

  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
    color: AppleColors.secondaryLabel,
  );

  static const price = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: AppleColors.label,
  );

  static const priceAccent = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: AppleColors.blue,
  );

  static const cardCategory = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.6,
    color: AppleColors.secondaryLabel,
  );

  static const cardTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.2,
    color: AppleColors.label,
  );

  static const cardSubtitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.25,
    color: AppleColors.bodySecondary,
  );
}

class AppleDecorations {
  static BoxDecoration card = BoxDecoration(
    color: AppleColors.card,
    borderRadius: BorderRadius.circular(AppleRadius.card),
    boxShadow: const [
      BoxShadow(
        color: Color(0x06000000),
        blurRadius: 24,
        offset: Offset(0, 8),
      ),
      BoxShadow(
        color: Color(0x04000000),
        blurRadius: 4,
        offset: Offset(0, 1),
      ),
    ],
  );

  static BoxDecoration softTile = BoxDecoration(
    color: AppleColors.canvas,
    borderRadius: BorderRadius.circular(AppleRadius.tile),
  );

  static BoxDecoration imageWell = const BoxDecoration(
    color: AppleColors.canvas,
  );
}

ThemeData buildAppleTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppleColors.canvas,
    primaryColor: AppleColors.blue,
    colorScheme: const ColorScheme.light(
      primary: AppleColors.blue,
      onPrimary: Colors.white,
      surface: AppleColors.card,
      onSurface: AppleColors.label,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppleColors.canvas,
      foregroundColor: AppleColors.label,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),
    dividerColor: AppleColors.separator,
    splashColor: AppleColors.blue.withValues(alpha: 0.06),
    highlightColor: AppleColors.blue.withValues(alpha: 0.03),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppleColors.label.withValues(alpha: 0.92),
      contentTextStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppleColors.label,
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
      ),
    ),
    iconTheme: const IconThemeData(color: AppleColors.label, size: 24),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}

Route<T> createAppleRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: const Duration(milliseconds: 380),
    reverseTransitionDuration: const Duration(milliseconds: 320),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: Tween<double>(begin: 0.92, end: 1).animate(curved),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.025),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

String formatPrice(double amount) {
  final value = amount.round();
  final digits = value.toString();
  final buffer = StringBuffer('\$');
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

double parsePrice(String price) {
  return double.tryParse(price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
}
