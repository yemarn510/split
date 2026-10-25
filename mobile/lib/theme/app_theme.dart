import 'package:flutter/material.dart';
import 'app_colors.dart';

const String kFontFamily = 'Quicksand';

/// Builds a [TextStyle] the way CSS would lay it out: `lineHeight` is the
/// CSS line-height in px and leading is split evenly above and below.
TextStyle cssText({
  double size = 16,
  double? lineHeight,
  FontWeight weight = FontWeight.w400,
  Color? color,
}) {
  return TextStyle(
    fontFamily: kFontFamily,
    fontSize: size,
    height: (lineHeight ?? size * 1.5) / size,
    fontWeight: weight,
    color: color,
    leadingDistribution: TextLeadingDistribution.even,
  );
}

class AppText {
  /// `body` on the web: browser default 16px black with Tailwind's 1.5 line-height.
  static final TextStyle page = cssText(color: AppColors.black);

  /// Text inside antd components (modal, popover, message): 14px / 22px.
  static final TextStyle ant = cssText(size: 14, lineHeight: 22, color: AppColors.text);
}

/// Tailwind breakpoints used by the web app.
class Breakpoints {
  /// `md:` (min-width: 768px).
  static bool md(BuildContext context) => MediaQuery.sizeOf(context).width >= 768;

  /// globals.scss `(max-width: 575px)` overrides apply below this.
  static bool sm(BuildContext context) => MediaQuery.sizeOf(context).width >= 576;
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: false,
    fontFamily: kFontFamily,
    primaryColor: AppColors.main,
    scaffoldBackgroundColor: AppColors.second,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    colorScheme: const ColorScheme.light(
      primary: AppColors.main,
      secondary: AppColors.third,
      surface: AppColors.second,
      error: AppColors.danger,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.main,
      selectionHandleColor: AppColors.main,
    ),
  );

  return base.copyWith(
    textTheme: base.textTheme.copyWith(
      bodyMedium: AppText.page,
      bodyLarge: AppText.page,
      titleMedium: AppText.page,
    ),
  );
}
