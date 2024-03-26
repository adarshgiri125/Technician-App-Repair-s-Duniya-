import 'package:flutter/material.dart';
import 'package:technician_app/core/app_export.dart';

// ignore: must_be_immutable
class AppbarTrailingImage extends StatelessWidget {
  AppbarTrailingImage({
    Key? key,
    this.imagePath,
    this.margin,
  }) : super(
          key: key,
        );

  String? imagePath;

  EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: CustomImageView(
        imagePath: imagePath,
        height: 24.adaptSize,
        width: 24.adaptSize,
        fit: BoxFit.contain,
      ),
    );
  }
}
