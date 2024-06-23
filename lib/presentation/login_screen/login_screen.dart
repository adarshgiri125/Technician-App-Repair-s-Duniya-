// ignore_for_file: must_be_immutable
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:partnersapp/core/app_export.dart';
import 'package:partnersapp/presentation/otp_screen/otp_screen.dart';
import 'package:partnersapp/widgets/custom_elevated_button.dart';
import 'package:partnersapp/widgets/custom_text_form_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController phoneNumberController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String phoneNumber = '';
  bool flag = false;
  bool isLogin = false;
  FocusNode _focusNode = FocusNode();

  // ignore: prefer_final_fields
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    mediaQueryData = MediaQuery.of(context);
    return SafeArea(
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
        body: Container(
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
          child: Form(
            key: _formKey,
            child: Container(
              width: double.maxFinite,
              padding: EdgeInsets.only(
                left: 23.h,
                top: 72.v,
                right: 23.h,
              ),
              child: Column(
                children: [
                  CustomImageView(
                    imagePath: ImageConstant.imgEllipse12,
                    height: 65.adaptSize,
                    width: 65.adaptSize,
                    radius: BorderRadius.circular(
                      32.h,
                    ),
                  ),
                  SizedBox(height: 27.v),
                  Text(
                    "Log in to your account",
                    style: theme.textTheme.headlineSmall,
                  ),
                  SizedBox(height: 10.v),
                  Text(
                    "Welcome back! Please enter your details.",
                    style: theme.textTheme.bodyLarge,
                  ),
                  SizedBox(height: 33.v),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 3.h),
                      child: Text(
                        "Phone number",
                        style: CustomTextStyles.titleSmallOnPrimary,
                      ),
                    ),
                  ),
                  SizedBox(height: 7.v),
                  CustomTextFormField(
                    onChanged: (value) {
                      phoneNumber = value;
                      setState(() {
                        if (phoneNumber.length == 10) {
                          flag = true;
                        } else {
                          flag = false;
                        }
                      });
                    },
                    focusNode: _focusNode,
                    controller: phoneNumberController,
                    hintText: "Enter your phone number",
                    textInputAction: TextInputAction.done,
                    textInputType: TextInputType.phone,
                    hintStyle: const TextStyle(color: Colors.black),
                  ),
                  SizedBox(height: 24.v),
                  CustomElevatedButton(
                    text: "Log in",
                    buttonStyle: flag == true
                        ? const ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll(Colors.black))
                        : const ButtonStyle(),
                    onPressed: () async {
                      setState(() {
                        isLogin = true;
                      });
                      await _auth.verifyPhoneNumber(
                        phoneNumber: '+91${phoneNumberController.text}',
                        verificationCompleted:
                            (PhoneAuthCredential credential) {},
                        verificationFailed: (FirebaseAuthException e) {},
                        codeSent: (String verificationId, int? resendToken) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OtpScreen(
                                verificationId: verificationId,
                                phoneNumber: '+91${phoneNumberController.text}',
                              ),
                            ),
                          );
                        },
                        codeAutoRetrievalTimeout: (String verificationId) {
                          setState(() {
                            isLogin = false;
                          });
                        },
                      );
                    },
                  ),
                  if (isLogin)
                    SizedBox(
                      height: 20.v,
                    ),
                  if (isLogin)
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  SizedBox(height: 33.v),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
