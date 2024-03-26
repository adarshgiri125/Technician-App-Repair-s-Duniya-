import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart' as handler;
import 'package:location/location.dart' as loc;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:technician_app/core/app_export.dart';
import 'package:technician_app/notification.dart';
import 'package:technician_app/presentation/my_bookings/my_bookings_screen.dart';
import 'package:technician_app/presentation/technician_home_screen/notifications_display.dart';
import 'package:technician_app/presentation/technician_home_screen/profile_screen.dart';
import 'package:technician_app/widgets/app_bar/appbar_title.dart';
import 'package:technician_app/widgets/app_bar/appbar_trailing_image.dart';
import 'package:technician_app/widgets/completed_widget.dart';
import 'package:technician_app/widgets/custom_elevated_button.dart';
import 'package:technician_app/widgets/half_page.dart';

class TechnicianHomeScreen extends StatefulWidget {
  const TechnicianHomeScreen({super.key});

  @override
  State<TechnicianHomeScreen> createState() => _TechnicianHomeScreenState();
}

class _TechnicianHomeScreenState extends State<TechnicianHomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final loc.Location _location = loc.Location();
  User? _user;
  LatLng? _currentPosition;
  bool showHalfPage = false;
  List<CompletedWidget> recentBookings = [];

  @override
  void initState() {
    super.initState();
    // PushNotificationSystem notificationSystem = PushNotificationSystem();
    // notificationSystem.whenNotificationReceived(context);
    setState(() {
      showHalfPage = true;
    });
    _auth.authStateChanges().listen((User? user) {
      setState(() {
        _user = user;
        saveLogin();
      });
    });
    _checkLocationPermission();
    _getCurrentLocation();
    setupDeviceToken();
    initializePermission();
  }

  Future<void> _checkLocationPermission() async {
    var status = await Permission.location.status;

    if (status == PermissionStatus.granted) {
      // User has granted location permission, proceed to get the current location
      await _getCurrentLocation();
    } else if (status == PermissionStatus.denied) {
      // Location permission is denied, show a dialog to request permission
      bool requested = await _requestLocationPermission();
      if (requested) {
        // Permission requested successfully, proceed to get the current location
        await _getCurrentLocation();
      } else {
        // Permission request was not successful
        _showLocationPermissionDialog(context);
      }
    } else {
      // User has not yet been asked for permission, request it
      await Permission.location.request();
      // Proceed to get the current location after requesting permission
      await _getCurrentLocation();
    }
  }

  Future<bool> _requestLocationPermission() async {
    // Request location permission
    var status = await Permission.location.request();
    return status == PermissionStatus.granted;
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });

    bool documentExists = await _firestore
        .collection('technicians')
        .doc(_user!.uid)
        .collection('location')
        .doc('currentLocation')
        .get()
        .then((DocumentSnapshot document) => document.exists);

    if (documentExists == true) {
      try {
        await _firestore
            .collection('technicians')
            .doc(_user!.uid)
            .collection('location')
            .doc('currentLocation')
            .update({
          'latitude': _currentPosition!.latitude,
          'longitude': _currentPosition!.longitude
        });
      } catch (e) {
        log(e.toString());
      }
    } else {
      try {
        await _firestore
            .collection('technicians')
            .doc(_user!.uid)
            .collection('location')
            .doc('currentLocation')
            .set({
          'latitude': _currentPosition!.latitude,
          'longitude': _currentPosition!.longitude
        }, SetOptions(merge: true));
      } catch (e) {
        log(e.toString());
      }
    }
  }

  void _showLocationPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Location Permission"),
          content: Text(
              "Turn on the location permission- (if you don't turn on your Location you will not get any service from customer)"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                await openAppSettings(); // Open app settings
                Navigator.pop(context); // Close the dialog
              },
              child: Text(
                "Open Settings",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> saveLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = await _user!.getIdToken();

    prefs.setString('userToken', token!);
  }

  // Future<void> getCurrentLocation() async {
  //   bool serviceEnabled;
  //   loc.PermissionStatus permission;

  //   try {
  //     // Check if location services are enabled
  //     serviceEnabled = await _location.serviceEnabled();
  //     if (!serviceEnabled) {
  //       serviceEnabled = await _location.requestService();
  //     }

  //     if (!serviceEnabled) {
  //       throw Exception('Location Services not Enabled');
  //     }

  //     // Request permission to access location
  //     permission = await _location.hasPermission();
  //     if (permission == loc.PermissionStatus.denied) {
  //       permission = await _location.requestPermission();

  //       if (permission == loc.PermissionStatus.denied) {
  //         // ignore: use_build_context_synchronously
  //         showDialog(
  //           context: context,
  //           builder: (BuildContext context) {
  //             return AlertDialog(
  //               content: Text(
  //                 "This app will utilize location data only while the app is in use to enhance and optimize the user experience.",
  //                 style: TextStyle(color: Colors.black, fontSize: 20.adaptSize),
  //               ),
  //               actions: [
  //                 TextButton(
  //                   onPressed: () {
  //                     Navigator.of(context).pop();
  //                     setState(() {
  //                       permission = loc.PermissionStatus.deniedForever;
  //                     });
  //                   },
  //                   child: Text(
  //                     'Deny',
  //                     style: TextStyle(
  //                       color: Colors.black,
  //                       fontSize: 15.adaptSize,
  //                     ),
  //                   ),
  //                 ),
  //                 TextButton(
  //                   onPressed: () async {
  //                     Navigator.of(context).pop();
  //                     await handler.openAppSettings();
  //                   },
  //                   child: Text(
  //                     'Allow',
  //                     style: TextStyle(
  //                       color: Colors.black,
  //                       fontSize: 15.adaptSize,
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             );
  //           },
  //         );

  //         throw Exception('Location permissions are denied');
  //       }
  //     }

  //     if (permission == loc.PermissionStatus.deniedForever) {
  //       throw Exception(
  //           'Location permissions are denied forever, cannot request permission');
  //     }

  //     getUserLocation();
  //   } catch (e) {
  //     // Handle the exception here
  //     print('Exception in getCurrentLocation: $e');
  //   }
  // }

  // Future<void> getUserLocation() async {
  //   Position position = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high);
  //   setState(() {
  //     _currentPosition = LatLng(position.latitude, position.longitude);
  //   });

  //   bool documentExists = await _firestore
  //       .collection('technicians')
  //       .doc(_user!.uid)
  //       .collection('location')
  //       .doc('currentLocation')
  //       .get()
  //       .then((DocumentSnapshot document) => document.exists);

  //   if (documentExists == true) {
  //     try {
  //       await _firestore
  //           .collection('technicians')
  //           .doc(_user!.uid)
  //           .collection('location')
  //           .doc('currentLocation')
  //           .update({
  //         'latitude': _currentPosition!.latitude,
  //         'longitude': _currentPosition!.longitude
  //       });
  //     } catch (e) {
  //       log(e.toString());
  //     }
  //   } else {
  //     try {
  //       await _firestore
  //           .collection('technicians')
  //           .doc(_user!.uid)
  //           .collection('location')
  //           .doc('currentLocation')
  //           .set({
  //         'latitude': _currentPosition!.latitude,
  //         'longitude': _currentPosition!.longitude
  //       }, SetOptions(merge: true));
  //     } catch (e) {
  //       log(e.toString());
  //     }
  //   }
  // }

  Future<void> initializePermission() async {
    bool isDenied = await Permission.notification.isDenied;
    if (isDenied) {
      await Permission.notification.request();
    }
  }

  Future<void> setupDeviceToken() async {
    String? token = await _messaging.getToken();
    _uploadToken(token!);
    _messaging.onTokenRefresh.listen(_uploadToken);
  }

  Future<void> _uploadToken(String token) async {
    try {
      await _firestore
          .collection('technicians')
          .doc(_user!.uid)
          .set({'token': token}, SetOptions(merge: true));
    } catch (e) {
      log(e.toString());
    }
  }

  void _showHalfPage(BuildContext context) {
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      pageBuilder: (context, animation, secondaryAnimation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, -1.0),
            end: Offset.zero,
          ).animate(animation),
          child: HalfPage(
            onClose: () {
              // Callback function to be invoked when the half page is closed
              _hideHalfPage(context);
            },
          ),
        );
      },
    ));
  }

  void _hideHalfPage(BuildContext context) {
    setState(() {
      showHalfPage = false;
    });
  }

  Future<List<String>> fetchNotificationsFromFirestore() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('technicians')
          .doc(_user!.uid)
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .get();

      List<String> notifications =
          querySnapshot.docs.map((doc) => doc['message'].toString()).toList();
      return notifications;
    } catch (error) {
      log('Error fetching notifications from Firestore: $error');
      return [];
    }
  }

  Future<void> openNotifications(BuildContext context) async {
    List<String> notifications = await fetchNotificationsFromFirestore();

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                NotificationsScreen(notifications: notifications)));
  }

  @override
  Widget build(BuildContext context) {
    mediaQueryData = MediaQuery.of(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: theme.colorScheme.onError,
        body: SizedBox(
          width: double.maxFinite,
          child: Column(
            children: [
              _buildFrame(context),
              Expanded(
                child: SizedBox(
                  width: double.maxFinite,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 17.h,
                      vertical: 28.v,
                    ),
                    child: Column(
                      children: [
                        _buildSubscribeRow(context),
                        SizedBox(height: 25.v),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(left: 10.h),
                            child: Text(
                              "Recent Bookings",
                              style: theme.textTheme.headlineSmall,
                            ),
                          ),
                        ),
                        SizedBox(height: 26.v),
                        _buildUserProfileList(context),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFrame(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 3.v),
      decoration: AppDecoration.gradientPrimaryToGray,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.v, vertical: 16.h),
                child: CustomImageView(
                  onTap: () {
                    showHalfPage == true
                        ? _hideHalfPage(context)
                        : _showHalfPage(context);
                  },
                  imagePath: ImageConstant.imgMenu,
                  height: 24.adaptSize,
                  width: 24.adaptSize,
                  fit: BoxFit.contain,
                  color: Colors.white,
                ),
              ),
              AppbarTitle(text: 'Home'),
            ],
          ),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.end, // Adjusted alignment for the right side
            children: [
              GestureDetector(
                onTap: () {
                  openNotifications(context);
                },
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Align the text in the center
                  crossAxisAlignment:
                      CrossAxisAlignment.end, // Align the text to the right
                  children: [
                    AppbarTrailingImage(
                      imagePath: ImageConstant.imgGroup5139931,
                      margin: EdgeInsets.only(
                        left: 24.h,
                        right: 46.h,
                      ),
                    ),
                    const Text(
                      'New Booking',
                      style: TextStyle(
                        color: Colors.white, // Set the text color to white
                        // You can add more style properties if needed
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 15.0),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfileScreen()),
                  );
                },
                child: AppbarTrailingImage(
                  imagePath: ImageConstant.imgGroup,
                  margin: EdgeInsets.only(
                    left: 4.h,
                    top: 3.v,
                  ),
                ),
              ),
              SizedBox(width: 15.0),
            ],
          ),
        ],
      ),
    );
  }

  /// Section Widget
  Widget _buildSubscribeRow(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 7.h),
      decoration: AppDecoration.gradientOrangeAToOnError
          .copyWith(borderRadius: BorderRadiusStyle.roundedBorder10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 17.v),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomImageView(
                  imagePath: ImageConstant.imgEllipse13,
                  height: 60.adaptSize,
                  width: 60.adaptSize,
                  radius: BorderRadius.circular(25.h),
                ),
                SizedBox(height: 20.v),
                SizedBox(
                  width: 166.h,
                  child: Text(
                    "Get works around from you....",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: appTheme.gray80001,
                      fontSize: 15.fSize,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: 8.v),
              ],
            ),
          ),
          CustomImageView(
            imagePath: ImageConstant.imgImage90,
            height: 163.adaptSize,
            width: 163.adaptSize,
            margin: EdgeInsets.only(top: 3.v),
          )
        ],
      ),
    );
  }

  // Section Widget
  Widget _buildUserProfileList(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200.v,
        ),
        CustomElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyBookingsScreen(id: 'p'),
              ),
            );
          },
          height: 100.v,
          width: double.infinity,
          text: "My Bookings",
          buttonStyle: CustomButtonStyles.none,
          decoration: CustomButtonStyles.gradientPrimaryToGrayTL13Decoration,
        ),
      ],
    );
  }
}
