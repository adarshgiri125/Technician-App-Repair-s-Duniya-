import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:partnersapp/core/app_export.dart';
import 'package:partnersapp/presentation/confirm_location_screen/confirm_location_screen.dart';
import 'package:partnersapp/presentation/id_verification_screen/id_verification_screen.dart';
import 'package:partnersapp/presentation/service_selection_screen/service_selection_screen.dart';
import 'package:partnersapp/presentation/technician_home_screen/technician_home_screen.dart';
import 'package:partnersapp/widgets/custom_elevated_button.dart';
import 'package:partnersapp/widgets/custom_pin_code_text_field.dart';

// ignore: must_be_immutable
class OtpScreen extends StatefulWidget {
  String verificationId;
  String phoneNumber;
  OtpScreen(
      {super.key, required this.verificationId, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String otp = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  bool flag = false;
  bool isSaving = false;

  Future<void> navigation(BuildContext context) async {
    final DocumentSnapshot documentSnapshot =
        await _firestore.collection('technicians').doc(_user!.uid).get();

    if (documentSnapshot.exists) {
      final data = documentSnapshot.data();
      if (data != null && data is Map<String, dynamic>) {
        final bool hasServices = data.containsKey('services');
        if (hasServices) {
          _navigateToTechnicianHomeScreen(context);
          return;
        }
      }
    }
    final QuerySnapshot locationSnapshot = await _firestore
        .collection('technicians')
        .doc(_user!.uid)
        .collection('location')
        .get();
    if (locationSnapshot.docs.isEmpty) {
      _navigateToConfirmLocationScreen(context);
      // _navigateToIdVerificationScreen(context);
      return;
    }

    final QuerySnapshot uploadsSnapshot = await _firestore
        .collection('technicians')
        .doc(_user!.uid)
        .collection('uploads')
        .get();
    if (uploadsSnapshot.docs.isNotEmpty) {
      _navigateToServiceSelectionScreen(context);
      return;
    } else {
      _navigateToIdVerificationScreen(context);
      return;
    }

    // If no uploads or location is found, directly go to ID verification screen
  }

// Remaining functions remain the same
  void _navigateToTechnicianHomeScreen(BuildContext context) {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const TechnicianHomeScreen()),
        (route) => false);
  }

  void _navigateToServiceSelectionScreen(BuildContext context) {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const ServiceSelectionScreen()),
        (route) => false);
  }

  void _navigateToIdVerificationScreen(BuildContext context) {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const IdVerificationScreen()),
        (route) => false);
  }

  void _navigateToConfirmLocationScreen(BuildContext context) {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const ConfirmLocationScreen()),
        (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    mediaQueryData = MediaQuery.of(context);
    return SafeArea(
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
        body: isSaving == true
            ? const Center(child: CircularProgressIndicator())
            : Container(
                width: mediaQueryData.size.width,
                height: mediaQueryData.size.height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: const Alignment(0.5, 0),
                    end: const Alignment(0.5, 1),
                    colors: [
                      theme.colorScheme.onError,
                      appTheme.gray50,
                    ],
                  ),
                ),
                child: Container(
                  width: double.maxFinite,
                  padding: EdgeInsets.only(
                    left: 24.h,
                    top: 61.v,
                    right: 24.h,
                  ),
                  child: Column(
                    children: [
                      CustomImageView(
                        imagePath: ImageConstant.imgImage69,
                        height: 172.adaptSize,
                        width: 172.adaptSize,
                      ),
                      SizedBox(height: 24.v),
                      Text(
                        "OTP Verification",
                        style: theme.textTheme.headlineSmall,
                      ),
                      SizedBox(height: 10.v),
                      SizedBox(
                        width: 226.h,
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "We sent a verification ",
                                style: theme.textTheme.bodyLarge,
                              ),
                              TextSpan(
                                text: "code",
                                style: theme.textTheme.bodyLarge,
                              ),
                              TextSpan(
                                text: " to ",
                                style: theme.textTheme.bodyLarge,
                              ),
                              TextSpan(
                                text: widget.phoneNumber,
                                style: CustomTextStyles
                                    .titleMediumInterBluegray700,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 30.v),
                      Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.h),
                          child: CustomPinCodeTextField(
                            context: context,
                            onChanged: (value) {
                              setState(() {
                                otp = value;
                                if (otp.length == 6) {
                                  flag = true;
                                } else {
                                  flag = false;
                                }
                              });
                            },
                          )),
                      SizedBox(height: 24.v),
                      CustomElevatedButton(
                        text: "Verify",
                        buttonStyle: flag == true
                            ? const ButtonStyle(
                                backgroundColor:
                                    MaterialStatePropertyAll(Colors.black))
                            : const ButtonStyle(),
                        onPressed: () async {
                          try {
                            setState(() {
                              isSaving = true;
                            });
                            PhoneAuthCredential credential =
                                await PhoneAuthProvider.credential(
                                    verificationId: widget.verificationId,
                                    smsCode: otp);
                            UserCredential authResult =
                                await _auth.signInWithCredential(credential);
                            String? userToken =
                                await authResult.user?.getIdToken();
                            setState(() {
                              _user = authResult.user;
                            });

                            if (userToken != null) {
                              await _firestore
                                  .collection('technicians')
                                  .doc(_user!.uid)
                                  .set({
                                'userId': _user!.uid,
                                'phone': widget.phoneNumber,
                              }, SetOptions(merge: true));

                              await navigation(context);
                            }
                          } catch (e) {
                            log(e.toString());
                          } finally {
                            setState(() {
                              isSaving = false;
                            });
                          }
                        },
                      ),
                      SizedBox(height: 33.v),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Didn’t receive the code?",
                            style: theme.textTheme.bodyMedium,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 4.h),
                            child: Text(
                              "Click to resend",
                              style: theme.textTheme.titleSmall,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 33.v),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomImageView(
                            imagePath: ImageConstant.imgArrowLeft,
                            height: 20.adaptSize,
                            width: 20.adaptSize,
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              left: 8.h,
                              top: 2.v,
                            ),
                            child: TextButton(
                              child: Text(
                                "Back to log in",
                                style: CustomTextStyles.titleSmallBluegray700,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5.v),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
