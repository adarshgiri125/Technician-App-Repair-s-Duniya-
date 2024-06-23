import 'package:flutter/material.dart';
import 'package:partnersapp/core/app_export.dart';

// ignore: must_be_immutable
class CompletedWidget extends StatelessWidget {
  const CompletedWidget({
    super.key,
    required this.phone,
    required this.time,
    required this.address,
    required this.timing,
    required this.serviceName,
    required this.date,
    required this.customerName,
    required this.subCategory,
  });
  final String phone;
  final String timing;
  final String time;
  final String serviceName;
  final String address;
  final String date;
  final String customerName;
  final String subCategory;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 15.h,
        vertical: 20.v,
      ),
      decoration: AppDecoration.gradientOnErrorToBlueGray.copyWith(
        borderRadius: BorderRadiusStyle.roundedBorder10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomImageView(
                    imagePath: ImageConstant.imgGroupOnprimary,
                    height: 24.adaptSize,
                    width: 24.adaptSize,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 13.h,
                      top: 2.v,
                      bottom: 4.v,
                    ),
                    child: Text(
                      "+91**********",
                      style: TextStyle(
                        color: appTheme.blueGray700,
                        fontSize: 13.740318298339844.fSize,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.v),
              Text(
                "Name : ${customerName}",
                style: TextStyle(
                  color: appTheme.blueGray700,
                  fontSize: 13.740318298339844.fSize,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 12.v),
              Text(
                "Issue : $subCategory",
                style: TextStyle(
                  color: appTheme.blueGray700,
                  fontSize: 13.740318298339844.fSize,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 12.v),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomImageView(
                    imagePath: ImageConstant.imgImage86,
                    height: 24.adaptSize,
                    width: 24.adaptSize,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 13.h,
                      top: 2.v,
                      bottom: 3.v,
                    ),
                    child: Text(
                      serviceName,
                      style: TextStyle(
                        color: appTheme.blueGray700,
                        fontSize: 13.740318298339844.fSize,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.v),
              Row(
                children: [
                  CustomImageView(
                    imagePath: ImageConstant.imgImage87,
                    height: 24.adaptSize,
                    width: 24.adaptSize,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 13.h,
                      top: 3.v,
                      bottom: 3.v,
                    ),
                    child: Text(
                      date,
                      style: TextStyle(
                        color: appTheme.blueGray700,
                        fontSize: 13.740318298339844.fSize,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.v),
              Row(
                children: [
                  CustomImageView(
                    imagePath: ImageConstant.imgImage88,
                    height: 24.adaptSize,
                    width: 24.adaptSize,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 13.h,
                      top: 4.v,
                      bottom: 2.v,
                    ),
                    child: Text(
                      timing,
                      style: TextStyle(
                        color: appTheme.blueGray700,
                        fontSize: 13.740318298339844.fSize,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.v),
              Row(
                children: [
                  CustomImageView(
                    imagePath: ImageConstant.imgVector,
                    height: 22.v,
                    width: 21.h,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 12.h,
                      top: 4.v,
                    ),
                    child: Text(
                      address,
                      style: TextStyle(
                        color: appTheme.blueGray700,
                        fontSize: 12.fSize,
                        fontFamily: 'Open Sans',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            height: 100.v,
            width: 100.h,
            margin: EdgeInsets.symmetric(vertical: 0.v),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Positioned(
                  top: 0,
                  child: CustomImageView(
                    imagePath: ImageConstant.imgImage73,
                    height: 50.v,
                    width: 50.h,
                    alignment: Alignment.topCenter,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: EdgeInsets.only(left: 13.h),
                    child: Text(
                      "Completed",
                      style: TextStyle(
                        color: appTheme.lightGreenA70001,
                        fontSize: 13.740318298339844.fSize,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
