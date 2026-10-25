import 'package:flutter/material.dart';

/// Colors from frontend/src/app/globals.scss, Tailwind and antd v5 tokens
/// (colorPrimary #102C57).
class AppColors {
  // globals.scss
  static const Color main = Color(0xFF102C57);
  static const Color second = Color(0xFFEADBC8);
  static const Color third = Color(0xFFDBCEBC);
  static const Color fourth = Color(0xFF8D9396);
  static const Color danger = Color(0xFFFF4D4F);
  static const Color shareBg = Color(0xFFFAF1E6);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color gold = Color(0xFFFFD700);

  // Tailwind
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray900 = Color(0xFF111827);

  // antd tokens
  static const Color success = Color(0xFF52C41A);
  static const Color successLight = Color(0xFFF6FFED);
  static const Color warning = Color(0xFFFAAD14);
  static const Color info = Color(0xFF1677FF);
  static const Color text = Color(0xE0000000); // rgba(0,0,0,.88)
  static const Color textSecondary = Color(0x73000000); // rgba(0,0,0,.45)
  static const Color textDisabled = Color(0x40000000); // rgba(0,0,0,.25)
  static const Color border = Color(0xFFD9D9D9);
  static const Color fillDisabled = Color(0x0A000000); // rgba(0,0,0,.04)
  static const Color mask = Color(0x73000000); // rgba(0,0,0,.45)
  static const Color primaryBg = Color(0xFFE6EBF2);

  // globals.scss `.ant-input-outlined[disabled]`
  static const Color inputDisabledText = Color(0x80000000); // rgba(0,0,0,.5)
  static const Color inputDisabledBg = Color(0x17000000); // rgba(0,0,0,.09)
}

/// antd `boxShadowSecondary`, used by popovers, tooltips and messages.
const List<BoxShadow> kAntShadow = [
  BoxShadow(color: Color(0x14000000), offset: Offset(0, 6), blurRadius: 16),
  BoxShadow(
      color: Color(0x1F000000),
      offset: Offset(0, 3),
      blurRadius: 6,
      spreadRadius: -4),
  BoxShadow(
      color: Color(0x0D000000),
      offset: Offset(0, 9),
      blurRadius: 28,
      spreadRadius: 8),
];
