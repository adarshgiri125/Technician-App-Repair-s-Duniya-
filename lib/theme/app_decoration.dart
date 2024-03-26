import 'package:flutter/material.dart';
import 'package:technician_app/core/app_export.dart';

class AppDecoration {
  // Gradient decorations
  static BoxDecoration get fillOnError => BoxDecoration(
        color: theme.colorScheme.onError,
      );
  static BoxDecoration get fillRed => BoxDecoration(
        color: appTheme.red50,
      );
  static BoxDecoration get fillPrimary => BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(1),
      );
  static BoxDecoration get fillGray => BoxDecoration(
        color: appTheme.gray50,
      );

  static BoxDecoration get gradientOnErrorToBlueGray => BoxDecoration(
        border: Border.all(
          color: appTheme.blueGray10002,
          width: 1.h,
        ),
        gradient: LinearGradient(
          begin: const Alignment(0.03, 0),
          end: const Alignment(0.2, 3.21),
          colors: [
            theme.colorScheme.onError,
            appTheme.blueGray10002,
          ],
        ),
      );

  static BoxDecoration get outlineGray500 => BoxDecoration(
        border: Border(
          top: BorderSide(
            color: appTheme.gray500,
            width: 1.h,
          ),
        ),
      );

  static BoxDecoration get gradientOnErrorToGray => BoxDecoration(
        gradient: LinearGradient(
          begin: const Alignment(0.5, 0),
          end: const Alignment(0.5, 1),
          colors: [
            theme.colorScheme.onError,
            appTheme.gray50,
          ],
        ),
      );

  static BoxDecoration get gradientOrangeAToOnError => BoxDecoration(
        border: Border.all(
          color: appTheme.blueGray10001,
          width: 1.h,
        ),
        gradient: LinearGradient(
          begin: const Alignment(0.5, 0),
          end: const Alignment(0.5, 1),
          colors: [
            appTheme.orangeA100,
            theme.colorScheme.onError,
          ],
        ),
      );

  static BoxDecoration get gradientPrimaryToOnPrimaryContainer => BoxDecoration(
        gradient: LinearGradient(
          begin: const Alignment(0.5, 0),
          end: const Alignment(0.5, 1),
          colors: [
            theme.colorScheme.primary.withOpacity(1),
            theme.colorScheme.onPrimaryContainer,
          ],
        ),
      );

  static BoxDecoration get gradientPrimaryToGray => BoxDecoration(
        gradient: LinearGradient(
          begin: const Alignment(0.5, 0),
          end: const Alignment(0.5, 1),
          colors: [
            theme.colorScheme.primary.withOpacity(1),
            appTheme.gray900,
          ],
        ),
      );

  static BoxDecoration get outlineBlueGrayE => BoxDecoration(
        color: appTheme.whiteA700,
        border: Border.all(
          color: appTheme.blueGray100E5,
          width: 1.h,
        ),
      );

  static BoxDecoration get outlineBluegray100e5 => BoxDecoration(
        color: appTheme.gray400,
        border: Border.all(
          color: appTheme.blueGray100E5,
          width: 1.h,
        ),
      );

  static BoxDecoration get outlineBlueGray => BoxDecoration(
        color: theme.colorScheme.onError,
        border: Border.all(
          color: appTheme.blueGray10002.withOpacity(0.9),
          width: 1.h,
        ),
      );
  static BoxDecoration get outlineBluegray100 => BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: appTheme.blueGray100,
            width: 1.h,
          ),
        ),
      );
  static BoxDecoration get outlineBluegray10002 => BoxDecoration(
        color: appTheme.gray40001,
        border: Border.all(
          color: appTheme.blueGray10002.withOpacity(0.9),
          width: 1.h,
        ),
      );
  static BoxDecoration get outlineGray => BoxDecoration(
        color: theme.colorScheme.onError,
        border: Border.all(
          color: appTheme.gray500,
          width: 3.h,
        ),
        boxShadow: [
          BoxShadow(
            color: appTheme.gray9000c,
            spreadRadius: 2.h,
            blurRadius: 2.h,
            offset: const Offset(
              0,
              1.79,
            ),
          ),
        ],
      );

  static BoxDecoration get outlineOnPrimaryContainer => BoxDecoration(
        color: appTheme.whiteA700,
        border: Border.all(
          color: theme.colorScheme.onPrimaryContainer,
          width: 3.h,
        ),
        boxShadow: [
          BoxShadow(
            color: appTheme.gray9000c,
            spreadRadius: 2.h,
            blurRadius: 2.h,
            offset: const Offset(
              0,
              1.79,
            ),
          ),
        ],
      );
}

class BorderRadiusStyle {
  // Rounded borders
  static BorderRadius get roundedBorder10 => BorderRadius.circular(
        10.h,
      );
  static BorderRadius get roundedBorder14 => BorderRadius.circular(
        14.h,
      );
  static BorderRadius get roundedBorder15 => BorderRadius.circular(
        15.h,
      );
  static BorderRadius get roundedBorder22 => BorderRadius.circular(
        22.h,
      );
  static BorderRadius get roundedBorder32 => BorderRadius.circular(
        32.h,
      );
  static BorderRadius get roundedBorder57 => BorderRadius.circular(
        57.h,
      );
  static BorderRadius get customBorderTL5 => BorderRadius.vertical(
        top: Radius.circular(5.h),
      );
}

// Comment/Uncomment the below code based on your Flutter SDK version.

// For Flutter SDK Version 3.7.2 or greater.

double get strokeAlignInside => BorderSide.strokeAlignInside;

double get strokeAlignCenter => BorderSide.strokeAlignCenter;

double get strokeAlignOutside => BorderSide.strokeAlignOutside;

// For Flutter SDK Version 3.7.1 or less.

// StrokeAlign get strokeAlignInside => StrokeAlign.inside;
//
// StrokeAlign get strokeAlignCenter => StrokeAlign.center;
//
// StrokeAlign get strokeAlignOutside => StrokeAlign.outside;
