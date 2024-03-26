import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:technician_app/core/app_export.dart';
import 'package:technician_app/presentation/my_bookings/end_selfie_screen.dart';
import 'package:technician_app/presentation/my_bookings/start_selfie_screen.dart';
import 'package:technician_app/widgets/custom_elevated_button.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class PendingWidget extends StatefulWidget {
  const PendingWidget({
    super.key,
    required this.docName,
    required this.location,
    required this.id,
    required this.phone,
    required this.address,
    required this.serviceName,
    required this.timing,
    required this.date,
  });

  final String id;
  final String phone;
  final String timing;
  final GeoPoint location;
  final String serviceName;
  final String address;
  final String date;
  final String docName;

  @override
  State<PendingWidget> createState() => _PendingWidgetState();
}

class _PendingWidgetState extends State<PendingWidget> {
  static Future<void> launchMap(double latitude, double longitude) async {
    String googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    Uri url = Uri.parse(googleMapsUrl);

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $googleMapsUrl';
    }
  }

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 7.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            widget.phone,
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
                            widget.serviceName,
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
                            widget.date,
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
                            widget.timing,
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
                            widget.address,
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
                Align(
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 70.h, // Adjust the width as needed
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CustomImageView(
                            imagePath: ImageConstant.imgImage89,
                            height: 50.v,
                            width: 50.h,
                            fit: BoxFit.fill,
                          ),
                          SizedBox(height: 10.v),
                          Padding(
                            padding: EdgeInsets.only(left: 0.h, right: 0.h),
                            child: Text(
                              widget.id == 'p' ? "Pending" : "Started Working",
                              style: TextStyle(
                                color: appTheme.red500,
                                fontSize: 13.740318298339844.fSize,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 14.v,
          ),
          CustomElevatedButton(
            text: 'Get Directions',
            onPressed: () async {
              double latitude = widget.location.latitude;
              double longitude = widget.location.longitude;

              launchMap(latitude, longitude);
            },
            buttonStyle: CustomButtonStyles.none,
            decoration: CustomButtonStyles.gradientRedAToRedTL13Decoration,
          ),
          SizedBox(height: 14.v),
          widget.id == 'p'
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomElevatedButton(
                      onPressed: () async {
                        launchUrl(Uri.parse('tel://${widget.phone}'));
                      },
                      height: 49.v,
                      width: 157.h,
                      text: "Call",
                      buttonStyle: CustomButtonStyles.none,
                      decoration: CustomButtonStyles
                          .gradientPrimaryToGrayTL13Decoration,
                    ),
                    CustomElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => StartSelfieScreen(
                                      docName: widget.docName,
                                    )));
                      },
                      height: 49.v,
                      width: 157.h,
                      text: "Start",
                      buttonStyle: CustomButtonStyles.none,
                      decoration: CustomButtonStyles
                          .gradientLightGreenAToLightGreenADecoration,
                      alignment: Alignment.bottomRight,
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomElevatedButton(
                      onPressed: () async {
                        launchUrl(Uri.parse('tel://${widget.phone}'));
                      },
                      height: 49.v,
                      width: 157.h,
                      text: "Call",
                      buttonStyle: CustomButtonStyles.none,
                      decoration: CustomButtonStyles
                          .gradientPrimaryToGrayTL13Decoration,
                    ),
                    CustomElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EndSelfieScreen(
                                      docName: widget.docName,
                                    )));
                      },
                      height: 49.v,
                      width: 157.h,
                      text: "Done",
                      buttonStyle: CustomButtonStyles.none,
                      decoration: CustomButtonStyles
                          .gradientLightGreenAToLightGreenADecoration,
                      alignment: Alignment.bottomRight,
                    ),
                  ],
                ),
          SizedBox(height: 4.v),
        ],
      ),
    );
  }
}
