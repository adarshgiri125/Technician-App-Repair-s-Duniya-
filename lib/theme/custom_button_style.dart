import 'package:flutter/material.dart';
import 'package:technician_app/core/app_export.dart';

/// A class that offers pre-defined button styles for customizing button appearance.
class CustomButtonStyles {
  // text button style
  static BoxDecoration get gradientLightGreenAToLightGreenADecoration =>
      BoxDecoration(
        borderRadius: BorderRadius.circular(13.h),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary,
            spreadRadius: 2.h,
            blurRadius: 2.h,
            offset: const Offset(
              0,
              3,
            ),
          ),
        ],
        gradient: LinearGradient(
          begin: const Alignment(0.5, 0),
          end: const Alignment(0.5, 1),
          colors: [
            appTheme.lightGreenA700,
            appTheme.lightGreenA70001,
          ],
        ),
      );

  static BoxDecoration get gradientPrimaryToGrayTL13Decoration => BoxDecoration(
        borderRadius: BorderRadius.circular(13.h),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary,
            spreadRadius: 2.h,
            blurRadius: 2.h,
            offset: Offset(
              0,
              3,
            ),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment(0.5, 0),
          end: Alignment(0.5, 1),
          colors: [
            theme.colorScheme.primary.withOpacity(1),
            appTheme.gray900,
          ],
        ),
      );

  static BoxDecoration get gradientRedAToRedTL13Decoration => BoxDecoration(
        borderRadius: BorderRadius.circular(13.h),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary,
            spreadRadius: 2.h,
            blurRadius: 2.h,
            offset: const Offset(
              0,
              3,
            ),
          ),
        ],
        gradient: LinearGradient(
          begin: const Alignment(0.5, 0),
          end: const Alignment(0.5, 1),
          colors: [
            appTheme.redA70001,
            appTheme.red800,
          ],
        ),
      );

  static BoxDecoration get gradientLightGreenAToOnPrimaryContainerDecoration =>
      BoxDecoration(
        borderRadius: BorderRadius.circular(13.h),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary,
            spreadRadius: 2.h,
            blurRadius: 2.h,
            offset: const Offset(
              0,
              3,
            ),
          ),
        ],
        gradient: LinearGradient(
          begin: const Alignment(0.5, 0),
          end: const Alignment(0.5, 1),
          colors: [
            appTheme.lightGreenA700,
            theme.colorScheme.onPrimaryContainer,
          ],
        ),
      );

  static BoxDecoration get gradientRedAToRedDecoration => BoxDecoration(
        borderRadius: BorderRadius.circular(13.h),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary,
            spreadRadius: 2.h,
            blurRadius: 2.h,
            offset: const Offset(
              0,
              3,
            ),
          ),
        ],
        gradient: LinearGradient(
          begin: const Alignment(0.5, 0),
          end: const Alignment(0.5, 1),
          colors: [
            appTheme.redA700,
            appTheme.red800,
          ],
        ),
      );

  static BoxDecoration get gradientPrimaryToGrayDecoration => BoxDecoration(
        borderRadius: BorderRadius.circular(16.h),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary,
            spreadRadius: 2.h,
            blurRadius: 2.h,
            offset: const Offset(
              0,
              4,
            ),
          ),
        ],
        gradient: LinearGradient(
          begin: const Alignment(0.5, 0),
          end: const Alignment(0.5, 1),
          colors: [
            theme.colorScheme.primary.withOpacity(1),
            appTheme.gray900,
          ],
        ),
      );

  static BoxDecoration get gradientPrimaryToOnPrimaryDecoration =>
      BoxDecoration(
        borderRadius: BorderRadius.circular(16.h),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary,
            spreadRadius: 2.h,
            blurRadius: 2.h,
            offset: const Offset(
              0,
              4,
            ),
          ),
        ],
        gradient: LinearGradient(
          begin: const Alignment(0.5, 0),
          end: const Alignment(0.5, 1),
          colors: [
            theme.colorScheme.primary.withOpacity(1),
            theme.colorScheme.onPrimary,
          ],
        ),
      );

  static ButtonStyle get outlinePrimaryTL13 => ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary.withOpacity(1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13.h),
        ),
        shadowColor: theme.colorScheme.primary,
        elevation: 3,
      );

  static ButtonStyle get none => ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
        elevation: MaterialStateProperty.all<double>(0),
      );
}
