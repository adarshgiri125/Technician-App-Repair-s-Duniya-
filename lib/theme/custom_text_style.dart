import 'package:flutter/material.dart';
import '../core/app_export.dart';

/// A collection of pre-defined text styles for customizing text appearance,
/// categorized by different font families and weights.
/// Additionally, this class includes extensions on [TextStyle] to easily apply specific font families to text.

class CustomTextStyles {
  // Body text style
  static get bodyLargeBluegray500 => theme.textTheme.bodyLarge!.copyWith(
        color: appTheme.blueGray500,
      );
  static get bodyLargeOpenSansGray500 =>
      theme.textTheme.bodyLarge!.openSans.copyWith(
        color: appTheme.gray500,
      );
  static get bodyLargeOpenSansOnError =>
      theme.textTheme.bodyLarge!.openSans.copyWith(
        color: theme.colorScheme.onError,
      );
  static get bodyLargeErrorContainer => theme.textTheme.bodyLarge!.copyWith(
        color: theme.colorScheme.errorContainer,
      );
  static get bodyMedium14 => theme.textTheme.bodyMedium!.copyWith(
        fontSize: 14.fSize,
      );
  static get bodyMediumOpenSansOnError =>
      theme.textTheme.bodyMedium!.openSans.copyWith(
        color: theme.colorScheme.onError,
        fontSize: 14.fSize,
      );
  static get bodyMediumRed500 => theme.textTheme.bodyMedium!.copyWith(
        color: appTheme.red500,
      );
  static get bodySmallBluegray700 => theme.textTheme.bodySmall!.copyWith(
        color: appTheme.blueGray700,
      );
  static get bodySmallInterBluegray700 =>
      theme.textTheme.bodySmall!.inter.copyWith(
        color: appTheme.blueGray700,
        fontSize: 8.fSize,
      );
  static get bodySmallInter => theme.textTheme.bodySmall!.inter.copyWith(
        fontSize: 8.fSize,
      );
  static get bodySmallInterBluegray700_1 =>
      theme.textTheme.bodySmall!.inter.copyWith(
        color: appTheme.blueGray700,
      );
  // Headline text style
  static get headlineSmallOnError => theme.textTheme.headlineSmall!.copyWith(
        color: theme.colorScheme.onError,
      );
  // Label text style
  static get labelLargeInterErrorContainer =>
      theme.textTheme.labelLarge!.inter.copyWith(
        color: theme.colorScheme.errorContainer,
        fontWeight: FontWeight.w500,
      );
  static get labelLargeInterGray800 =>
      theme.textTheme.labelLarge!.inter.copyWith(
        color: appTheme.gray800,
        fontSize: 12.fSize,
        fontWeight: FontWeight.w500,
      );
  static get labelLargeInterGray80001 =>
      theme.textTheme.labelLarge!.inter.copyWith(
        color: appTheme.gray80001,
        fontSize: 12.fSize,
        fontWeight: FontWeight.w500,
      );
  static get labelLargeInterRed500 =>
      theme.textTheme.labelLarge!.inter.copyWith(
        color: appTheme.red500,
        fontWeight: FontWeight.w500,
      );
  // Title text style
  static get titleMediumInterBluegray700 =>
      theme.textTheme.titleMedium!.inter.copyWith(
        color: appTheme.blueGray700,
        fontWeight: FontWeight.w500,
      );
  static get titleSmallBluegray700 => theme.textTheme.titleSmall!.copyWith(
        color: appTheme.blueGray700,
      );
  static get titleSmallBluegray800 => theme.textTheme.titleSmall!.copyWith(
        color: appTheme.blueGray800,
        fontWeight: FontWeight.w500,
      );
  static get titleSmallOnPrimary => theme.textTheme.titleSmall!.copyWith(
        color: theme.colorScheme.onPrimary,
        fontWeight: FontWeight.w500,
      );
  static get titleSmallPrimary => theme.textTheme.titleSmall!.copyWith(
        color: theme.colorScheme.primary.withOpacity(1),
      );
  static get bodySmallGray800 => theme.textTheme.bodySmall!.copyWith(
        color: appTheme.gray800,
      );
  static get titleSmallOpenSansOnError =>
      theme.textTheme.titleSmall!.openSans.copyWith(
        color: theme.colorScheme.onError,
        fontWeight: FontWeight.w700,
      );
}

extension on TextStyle {
  TextStyle get openSans {
    return copyWith(
      fontFamily: 'Open Sans',
    );
  }

  TextStyle get inter {
    return copyWith(
      fontFamily: 'Inter',
    );
  }
}
