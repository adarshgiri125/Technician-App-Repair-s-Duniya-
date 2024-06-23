import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:partnersapp/core/app_export.dart';
import 'package:partnersapp/presentation/id_verification_screen/verfication_complete_screen.dart';
import 'package:partnersapp/widgets/custom_elevated_button.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';

class IdVerificationScreen extends StatefulWidget {
  const IdVerificationScreen({super.key});

  @override
  State<IdVerificationScreen> createState() => _IdVerificationScreenState();
}

class _IdVerificationScreenState extends State<IdVerificationScreen> {
  File? imageIDFrontPath;
  File? imageIDBackPath;
  File? imageSelfiePath;
  bool flag = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((User? user) {
      setState(() {
        _user = user;
      });
    });
  }

  bool getValue() {
    if (imageIDFrontPath != null &&
        imageIDBackPath != null &&
        imageSelfiePath != null) {
      return true;
    }
    return false;
  }

  Future<void> _uploadFiles() async {
    try {
      setState(() {
        isUploading = true;
      });
      _uploadFile(imageIDFrontPath!, 'front');
      _uploadFile(imageIDBackPath!, 'back');
      _uploadFile(imageSelfiePath!, 'selfie');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const VerificationCompleteScreen(),
        ),
      );
    } catch (e) {
      log("Failed to upload files: $e");
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  Future<void> _uploadFile(File path, String fileName) async {
    try {
      File pickedFile = path;

      final Reference storageReference = _storage.ref().child(
          'uploads/${_user!.uid}/${DateTime.now().millisecondsSinceEpoch}_{$fileName}');
      final TaskSnapshot snapshot = await storageReference.putFile(pickedFile);
      String downloadUrl = await snapshot.ref.getDownloadURL();

      await _firestore
          .collection('technicians')
          .doc(_user!.uid)
          .collection('uploads')
          .add({
        'fileName': fileName,
        'filePath': downloadUrl,
        'timeStamp': FieldValue.serverTimestamp()
      });
    } catch (e) {
      log("Failed to upload file: $fileName");
    }
  }

  Future<dynamic> showSheet(BuildContext context, String s) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.image),
            title: Text(
              'Gallery',
              style: theme.textTheme.bodyLarge,
            ),
            onTap: () {
              Navigator.pop(context);
              setImage(s, ImageSource.gallery);
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera),
            title: Text(
              'Camera',
              style: theme.textTheme.bodyLarge,
            ),
            onTap: () {
              Navigator.pop(context);
              setImage(s, ImageSource.camera);
            },
          )
        ],
      ),
    );
  }

  Future<void> setImage(String s, ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;

      File path = File(image.path);

      // Read image bytes
      Uint8List imageBytes = await path.readAsBytes();
      img.Image? decodedImage = img.decodeImage(imageBytes);

      // Compress the image
      final compressedBytes = Uint8List.fromList(img.encodeJpg(decodedImage!,
          quality: 80)); // Adjust quality as needed (0 - 100)

      // Write compressed image bytes to the file
      await path.writeAsBytes(compressedBytes);

      setState(() {
        if (s == 'front') {
          imageIDFrontPath = path;
        } else if (s == 'back') {
          imageIDBackPath = path;
        } else {
          imageSelfiePath = path;
        }
      });
    } on PlatformException catch (e) {
      log(e.toString());
    } catch (e) {
      log('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    mediaQueryData = MediaQuery.of(context);
    return SafeArea(
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: isUploading == true
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
                    left: 23.h,
                    top: 111.v,
                    right: 23.h,
                  ),
                  child: Column(
                    children: [
                      CustomImageView(
                        imagePath: ImageConstant.imgImage71,
                        height: 117.v,
                        width: 138.h,
                      ),
                      SizedBox(height: 24.v),
                      Text(
                        "ID Verification",
                        style: theme.textTheme.headlineSmall,
                      ),
                      SizedBox(height: 11.v),
                      SizedBox(
                        width: 188.h,
                        child: Text(
                          "Please upload necessary Images",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge!.copyWith(
                            height: 1.50,
                          ),
                        ),
                      ),
                      SizedBox(height: 29.v),
                      _buildIdVerificationFrame(context),
                      SizedBox(height: 8.v),
                      Padding(
                        padding: EdgeInsets.only(
                          left: 10.h,
                          right: 30.h,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              "Adhaar Front",
                              style: theme.textTheme.bodySmall,
                            ),
                            SizedBox(
                              width: mediaQueryData.size.width * 0.05,
                            ),
                            Text(
                              "Adhaar Back",
                              style: theme.textTheme.bodySmall,
                            ),
                            SizedBox(
                              width: mediaQueryData.size.width * 0.1,
                            ),
                            Text(
                              "Selfie",
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 36.v),
                      flag == true
                          ? CustomElevatedButton(
                              buttonStyle: const ButtonStyle(
                                  backgroundColor:
                                      MaterialStatePropertyAll(Colors.black)),
                              text: "Verify",
                              onPressed: () {
                                _uploadFiles();
                              },
                            )
                          : CustomElevatedButton(
                              text: "Verify",
                            ),
                      SizedBox(height: 32.v),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomImageView(
                            imagePath: ImageConstant.imgArrowLeft,
                            height: 20.adaptSize,
                            width: 20.adaptSize,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 8.h),
                            child: TextButton(
                              onPressed: (() => Navigator.pop(context)),
                              child: Text(
                                'Back',
                                style: CustomTextStyles.titleSmallBluegray700,
                              ),
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

  /// Section Widget
  Widget _buildIdVerificationFrame(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              width: mediaQueryData.size.width * 0.03,
              height: mediaQueryData.size.width * 0.2,
              decoration: AppDecoration.outlineOnPrimaryContainer.copyWith(
                borderRadius: BorderRadiusStyle.roundedBorder14,
              ),
              child: imageIDFrontPath != null
                  ? GestureDetector(
                      onTap: (() {
                        showSheet(context, 'front');
                        setState(() {
                          flag = getValue();
                        });
                      }),
                      child: Image.file(
                        imageIDFrontPath!,
                        width: mediaQueryData.size.width * 0.03,
                        height: mediaQueryData.size.width * 0.2,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Center(
                      child: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          showSheet(context, 'front');
                          setState(() {
                            flag = getValue();
                          });
                        },
                      ),
                    ),
            ),
          ),
          SizedBox(
            width: mediaQueryData.size.width * 0.02,
          ),
          Expanded(
            child: Container(
              width: mediaQueryData.size.width * 0.03,
              height: mediaQueryData.size.width * 0.2,
              decoration: AppDecoration.outlineOnPrimaryContainer.copyWith(
                borderRadius: BorderRadiusStyle.roundedBorder14,
              ),
              child: imageIDBackPath != null
                  ? GestureDetector(
                      onTap: (() {
                        showSheet(context, 'back');
                        setState(() {
                          flag = getValue();
                        });
                      }),
                      child: Image.file(
                        imageIDBackPath!,
                        width: mediaQueryData.size.width * 0.03,
                        height: mediaQueryData.size.width * 0.2,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Center(
                      child: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          showSheet(context, 'back');
                          setState(() {
                            flag = getValue();
                          });
                        },
                      ),
                    ),
            ),
          ),
          SizedBox(
            width: mediaQueryData.size.width * 0.02,
          ),
          Expanded(
            child: Container(
              width: mediaQueryData.size.width * 0.03,
              height: mediaQueryData.size.width * 0.2,
              decoration: AppDecoration.outlineOnPrimaryContainer.copyWith(
                borderRadius: BorderRadiusStyle.roundedBorder14,
              ),
              child: imageSelfiePath != null
                  ? GestureDetector(
                      onTap: () async {
                        try {
                          final image = await ImagePicker()
                              .pickImage(source: ImageSource.camera);
                          if (image == null) return;

                          final path = File(image.path);
                          setState(() {
                            imageSelfiePath = path;
                          });
                        } on PlatformException catch (e) {
                          log(e.toString());
                        }
                        setState(() {
                          flag = getValue();
                        });
                      },
                      child: Image.file(
                        imageSelfiePath!,
                        width: mediaQueryData.size.width * 0.03,
                        height: mediaQueryData.size.width * 0.2,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Center(
                      child: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () async {
                          try {
                            final image = await ImagePicker()
                                .pickImage(source: ImageSource.camera);
                            if (image == null) return;

                            final path = File(image.path);
                            setState(() {
                              imageSelfiePath = path;
                            });
                          } on PlatformException catch (e) {
                            log(e.toString());
                          }
                          setState(() {
                            flag = getValue();
                          });
                        },
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
