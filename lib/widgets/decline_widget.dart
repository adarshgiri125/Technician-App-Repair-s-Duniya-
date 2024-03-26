import 'package:flutter/material.dart';
import 'package:technician_app/core/app_export.dart';

// ignore: must_be_immutable
class DeclineWidget extends StatelessWidget {
  const DeclineWidget(
      {super.key,
      required this.phone,
      required this.timing,
      required this.time,
      required this.serviceName,
      required this.address,
      required this.date});
  final String phone;
  final String address;
  final String serviceName;
  final String time;
  final String timing;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.v, horizontal: 15.h),
      decoration: AppDecoration.gradientOnErrorToBlueGray.copyWith(
        borderRadius: BorderRadiusStyle.roundedBorder10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
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
                      phone,
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
                    imagePath: ImageConstant.imgImage86,
                    height: 22.v,
                    width: 24.h,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 13.h,
                      top: 2.v,
                      bottom: 2.v,
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
                      right: 10.v,
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
          Padding(
            padding: EdgeInsets.only(top: 8.v, bottom: 20.v, right: 5.v),
            child: Column(
              children: [
                CustomImageView(
                  imagePath: ImageConstant.imgImage74,
                  height: 50.v,
                  width: 50.h,
                ),
                SizedBox(height: 2.v),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(left: 0.h, top: 0.h),
                    child: Text(
                      "Declined",
                      style: TextStyle(
                        color: appTheme.red500,
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
