import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:partnersapp/presentation/technician_home_screen/addOffer.dart';
import 'package:partnersapp/presentation/technician_home_screen/visitOffer.dart';
import 'package:permission_handler/permission_handler.dart' as handler;
import 'package:location/location.dart' as loc;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:partnersapp/core/app_export.dart';
import 'package:partnersapp/notification.dart';
import 'package:partnersapp/presentation/my_bookings/my_bookings_screen.dart';
import 'package:partnersapp/presentation/technician_home_screen/notifications_display.dart';
import 'package:partnersapp/presentation/technician_home_screen/profile_screen.dart';
import 'package:partnersapp/widgets/app_bar/appbar_title.dart';
import 'package:partnersapp/widgets/app_bar/appbar_trailing_image.dart';
import 'package:partnersapp/widgets/completed_widget.dart';
import 'package:partnersapp/widgets/custom_elevated_button.dart';
import 'package:partnersapp/widgets/half_page.dart';

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
  bool isWorking = false;

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
      if (_user != null) {
        _fetchWorkingStatus();
      }
    });
    _getName();
    _checkLocationPermission();
    _getCurrentLocation();
    setupDeviceToken();
    initializePermission();
  }

  Future<void> _fetchWorkingStatus() async {
    try {
      var document =
          await _firestore.collection('technicians').doc(_user!.uid).get();
      setState(() {
        isWorking = document.data()?['workingStatus'] ?? false;
      });
      log('Fetched working status: $isWorking');
    } catch (e) {
      log('Error fetching working status: $e');
    }
  }

  Future<void> _updateWorkingStatus(bool status) async {
    try {
      await _firestore.collection('technicians').doc(_user!.uid).set({
        'workingStatus': status,
      }, SetOptions(merge: true));
      log('Updated working status to: $status');
    } catch (e) {
      log('Failed to update working status: $e');
    }
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
                              "Hi, Welcome!",
                              style: theme.textTheme.headlineSmall,
                            ),
                          ),
                        ),
                        SizedBox(height: 20.v),
                        _buildWorkingStatusToggle(context),
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

  Widget _buildWorkingStatusToggle(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.0),
      child: Container(
        width: double.infinity, // Make the container fill the width
        padding:
            EdgeInsets.symmetric(horizontal: 16.0), // Add horizontal padding
        decoration: BoxDecoration(
          color: Colors.grey[200], // Background color of the container
          borderRadius: BorderRadius.circular(8.0), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5), // Shadow color
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3), // Offset of the shadow
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Space between elements
          children: [
            Text(
              'Working: ',
              style: TextStyle(
                fontSize: 16.0, // Increase the text size
                fontWeight: FontWeight.bold, // Make the text bold
              ),
            ),
            Row(
              children: [
                Text(
                  isWorking ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: isWorking ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8.0), // Space between text and switch
                Switch(
                  value: isWorking,
                  onChanged: (value) {
                    setState(() {
                      isWorking = value;
                    });
                    _updateWorkingStatus(value);
                  },
                  activeColor: Colors.green, // Color when switch is on
                  inactiveThumbColor: Colors.red, // Color when switch is off
                  inactiveTrackColor: Colors.red
                      .withOpacity(0.5), // Track color when switch is off
                ),
              ],
            ),
          ],
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddOfferScreen(userId: _user!.uid),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Background color
                  minimumSize: Size(double.infinity, 70.0), // Button size
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12.0), // Rounded corners
                  ),
                  textStyle: TextStyle(color: Colors.white),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Colors.black),
                    SizedBox(width: 8.0),
                    Text("Add Offer", style: TextStyle(color: Colors.black)),
                  ],
                ),
              ),
            ),
            SizedBox(width: 16.0), // Space between buttons
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          VisitChargesScreen(userId: _user!.uid),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Background color
                  minimumSize: Size(double.infinity, 70.0), // Button size
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12.0), // Rounded corners
                  ),
                  textStyle: TextStyle(color: Colors.black),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.monetization_on, color: Colors.black),
                    SizedBox(width: 8.0),
                    Text("Visit Charge", style: TextStyle(color: Colors.black))
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 30.0), // Space between rows
        CustomElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyBookingsScreen(id: 'p'),
              ),
            );
          },
          height: 70.0,
          width: double.infinity,
          text: "All Bookings",
          buttonStyle: CustomButtonStyles.none,
          decoration: CustomButtonStyles.gradientPrimaryToGrayTL13Decoration,
        ),
      ],
    );
  }

  Future<void> _getName() async {
    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Get a reference to the document for the user
      DocumentReference userDocRef =
          _firestore.collection('technicians').doc(user.uid);

      // Check if the "name" field exists in the document
      DocumentSnapshot userDocSnapshot = await userDocRef.get();

      if (userDocSnapshot.exists) {
        Map<String, dynamic>? userData =
            userDocSnapshot.data() as Map<String, dynamic>?;

        if (userData != null && userData.containsKey('technicianName')) {
          // "name" field exists, proceed with your existing logic
          // You can call the function that shows the confirmation dialog here
          // For example:
          return;
        } else {
          // "name" field does not exist, show dialog to enter the name
          showDialog(
            context: context,
            builder: (context) {
              String newName = ""; // Variable to store the entered name
              return AlertDialog(
                title: Text("Enter Your Name"),
                content: TextField(
                  onChanged: (value) {
                    newName = value; // Update newName when the user types
                  },
                  decoration: InputDecoration(
                    hintText: "Enter Your Name",
                  ),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      // Add the entered name to Firestore
                      userDocRef.set({
                        'technicianName': newName,
                      }, SetOptions(merge: true)).then((value) {
                        // Close the dialog after adding the name
                        Navigator.pop(context);
                        // Proceed with your existing logic
                      }).catchError((error) {
                        // Handle error if adding name fails
                        print("Failed to add name: $error");
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors
                          .black, // Set button background color to dark black
                      textStyle: const TextStyle(
                          color: Colors.black, // Set text color to dark black
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold // Set font size

                          ),
                      padding: EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 24.0), // Set padding
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10.0), // Set button shape
                      ),
                    ),
                    child: Text(
                      "Submit",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              );
            },
          );
        }
      }
    }
  }
}
