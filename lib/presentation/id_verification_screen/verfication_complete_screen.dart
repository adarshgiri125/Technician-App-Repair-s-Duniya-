import 'package:flutter/material.dart';
import 'package:technician_app/core/app_export.dart';
import 'package:technician_app/presentation/service_selection_screen/service_selection_screen.dart';
import 'package:technician_app/widgets/custom_elevated_button.dart';

class VerificationCompleteScreen extends StatelessWidget {
  const VerificationCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: const Alignment(0.5, 0),
              end: const Alignment(0.5, 1),
              colors: [appTheme.whiteA700, appTheme.gray50],
            ),
          ),
          child: Container(
            width: double.maxFinite,
            padding: EdgeInsets.only(left: 23.h, top: 105.v, right: 23.h),
            child: Column(
              children: [
                CustomImageView(
                    imagePath: ImageConstant.imgImage71,
                    height: 117.v,
                    width: 138.h),
                SizedBox(height: 24.v),
                Text("ID Verification", style: theme.textTheme.headlineSmall),
                SizedBox(height: 15.v),
                CustomImageView(
                    imagePath: ImageConstant.imgImage73,
                    height: 146.v,
                    width: 156.h,
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(left: 94.h)),
                SizedBox(height: 18.v),
                Text("Complete", style: theme.textTheme.bodyLarge),
                SizedBox(height: 32.v),
                CustomElevatedButton(
                    text: "Proceed",
                    buttonStyle: CustomButtonStyles.none,
                    decoration:
                        CustomButtonStyles.gradientPrimaryToOnPrimaryDecoration,
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const ServiceSelectionScreen()),
                        ((route) => false),
                      );
                    }),
                SizedBox(height: 32.v),
                SizedBox(height: 5.v)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
