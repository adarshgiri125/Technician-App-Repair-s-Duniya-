// ignore_for_file: unused_field, must_be_immutable
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:partnersapp/core/app_export.dart';
import 'package:partnersapp/presentation/technician_home_screen/notifications_display.dart';
import 'package:partnersapp/presentation/technician_home_screen/profile_screen.dart';
import 'package:partnersapp/presentation/technician_home_screen/technician_home_screen.dart';
import 'package:partnersapp/widgets/app_bar/appbar_title.dart';
import 'package:partnersapp/widgets/app_bar/appbar_trailing_image.dart';
import 'package:partnersapp/widgets/completed_widget.dart';
import 'package:partnersapp/widgets/decline_widget.dart';
import 'package:partnersapp/widgets/half_page.dart';
import 'package:partnersapp/widgets/pending_widget.dart';

class MyBookingsScreen extends StatefulWidget {
  MyBookingsScreen({super.key, required this.id});
  String id;

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  String screenId = '';
  bool showHalfPage = true;
  List<CompletedWidget> completed = [];
  List<PendingWidget> pending = [];
  List<DeclineWidget> rejected = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    setState(() {
      screenId = widget.id;
      showHalfPage = false;
    });
    _auth.authStateChanges().listen((User? user) async {
      setState(() {
        _user = user;
      });
      await getEntries();
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> getEntries() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('technicians')
          .doc(_user!.uid)
          .collection('serviceList')
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
          String docId = documentSnapshot.id;
          if (documentSnapshot['status'] == 'p' ||
              documentSnapshot['status'] == 's') {
            Timestamp timeStamp = documentSnapshot['date'];
            DateTime datetime = timeStamp.toDate();
            String date = '${datetime.day}/${datetime.month}/${datetime.year}';
            String customerName =
                "not-mentioned"; // Default value if customerName field doesn't exist in the document

            var data =
                documentSnapshot.data(); // Retrieve data from the document
            if (data != null &&
                data is Map<String, dynamic> &&
                data.containsKey('customerName')) {
              customerName = documentSnapshot[
                  'customerName']; // Assign the value of customerName if it exists
            }
            String subCategory = "not-mentioned";
            if (data != null &&
                data is Map<String, dynamic> &&
                data.containsKey('subCategory')) {
              subCategory = documentSnapshot[
                  'subCategory']; // Assign the value of customerName if it exists
            }

            pending.add(
              PendingWidget(
                serviceName: documentSnapshot['serviceName'],
                id: documentSnapshot['status'],
                docName: docId,
                timing: documentSnapshot['urgentBooking'] == true
                    ? 'Urgent Booking'
                    : documentSnapshot['timeIndex'],
                phone: documentSnapshot['customerPhone'],
                address: documentSnapshot['customerAddress'],
                location: documentSnapshot['customerLocation'],
                date: date,
                customerName: customerName,
                subCategory: subCategory,
              ),
            );
          } else if (documentSnapshot['status'] == 'c') {
            Timestamp timestamp = documentSnapshot['date'];
            DateTime dateTime = timestamp.toDate();
            String time =
                '${dateTime.hour}:${dateTime.minute}:${dateTime.second}';
            String date = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
            String customerName =
                "not-mentioned"; // Default value if customerName field doesn't exist in the document

            var data =
                documentSnapshot.data(); // Retrieve data from the document
            if (data != null &&
                data is Map<String, dynamic> &&
                data.containsKey('customerName')) {
              customerName = data[
                  'customerName']; // Assign the value of customerName if it exists
            }
            String subCategory = "not-mentioned";
            if (data != null &&
                data is Map<String, dynamic> &&
                data.containsKey('subCategory')) {
              subCategory = data[
                  'subCategory']; // Assign the value of customerName if it exists
            }
            completed.add(
              CompletedWidget(
                time: time,
                timing: documentSnapshot['urgentBooking'] == true
                    ? 'Urgent Booking'
                    : documentSnapshot['timeIndex'],
                serviceName: documentSnapshot['serviceName'],
                phone: documentSnapshot['customerPhone'],
                address: documentSnapshot['customerAddress'],
                date: date,
                customerName: customerName,
                subCategory: subCategory,
              ),
            );
          } else if (documentSnapshot['status'] == 'r') {
            Timestamp timestamp = documentSnapshot['date'];
            DateTime dateTime = timestamp.toDate();
            String time =
                '${dateTime.hour}:${dateTime.minute}:${dateTime.second}';
            String date = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
            String customerName =
                "not-mentioned"; // Default value if customerName field doesn't exist in the document

            var data =
                documentSnapshot.data(); // Retrieve data from the document
            if (data != null &&
                data is Map<String, dynamic> &&
                data.containsKey('customerName')) {
              customerName = data[
                  'customerName']; // Assign the value of customerName if it exists
            }
            String subCategory = "not-mentioned";
            if (data != null &&
                data is Map<String, dynamic> &&
                data.containsKey('subCategory')) {
              subCategory = data[
                  'subCategory']; // Assign the value of customerName if it exists
            }
            rejected.add(
              DeclineWidget(
                time: time,
                timing: documentSnapshot['urgentBooking'] == true
                    ? 'Urgent Booking'
                    : documentSnapshot['timeIndex'],
                serviceName: documentSnapshot['serviceName'],
                phone: documentSnapshot['customerPhone'],
                address: documentSnapshot['customerAddress'],
                date: date,
                customerName: customerName,
                subCategory: subCategory,
              ),
            );
          }
        }
      }

      //  pending.sort((a, b) {
      //   // First, check if either a or b is an urgent booking
      //   bool isAUrgent = a.timing == 'Urgent Booking';
      //   bool isBUrgent = b.timing == 'Urgent Booking';

      //   // If both are urgent or both are not urgent, sort by date
      //   if (isAUrgent == isBUrgent) {
      //     // Manually parse the date strings
      //     List<int> dateA = a.date.split('/').map(int.parse).toList();
      //     List<int> dateB = b.date.split('/').map(int.parse).toList();
      //     DateTime dateTimeA =
      //         DateTime(dateA[2], dateA[1], dateA[0]); // Swap positions
      //     DateTime dateTimeB =
      //         DateTime(dateB[2], dateB[1], dateB[0]); // Swap positions

      //     print(dateTimeA);
      //     print(dateTimeB);

      //     return dateTimeA
      //         .compareTo(dateTimeB); // Sort by date, but in reverse order
      //   } else {
      //     // If only one of them is urgent, prioritize the urgent booking
      //     // Urgent bookings should appear before non-urgent ones
      //     return isBUrgent ? 1 : -1;
      //   }
      // });

      pending.sort((a, b) {
        // First, check if either a or b is an urgent booking
        bool isAUrgent = a.timing == 'Urgent Booking';
        bool isBUrgent = b.timing == 'Urgent Booking';

        // Manually parse the date strings
        List<int> dateA = a.date.split('/').map(int.parse).toList();
        List<int> dateB = b.date.split('/').map(int.parse).toList();
        DateTime dateTimeA = DateTime(dateA[2], dateA[1], dateA[0]);
        DateTime dateTimeB = DateTime(dateB[2], dateB[1], dateB[0]);

        // If dates are the same, compare by timing
        if (dateTimeA.isAtSameMomentAs(dateTimeB)) {
          if (a.timing == b.timing) {
            // If timing is also same, return 0
            return 0;
          } else if (a.timing == 'Urgent Booking') {
            // If a is urgent, prioritize it
            return -1;
          } else if (b.timing == 'Urgent Booking') {
            // If b is urgent, prioritize it
            return 1;
          } else {
            // Otherwise, sort by timing value
            return a.timing.compareTo(b.timing);
          }
        } else {
          // If dates are different, sort by date
          return dateTimeA.compareTo(dateTimeB);
        }
      });

      completed.sort((a, b) {
        int c1 = b.date.compareTo(a.date);
        int c2 = b.time.compareTo(a.time);

        // You need to return a value based on the comparison
        if (c1 != 0) {
          return c1;
        } else {
          return c2;
        }
      });

      rejected.sort((a, b) {
        int c1 = b.date.compareTo(a.date);
        int c2 = b.time.compareTo(a.time);

        // You need to return a value based on the comparison
        if (c1 != 0) {
          return c1;
        } else {
          return c2;
        }
      });
    } catch (e) {
      log("Error fetching data: $e");
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
    // Update the state or perform other actions as needed
    setState(() {
      showHalfPage = false;
    });
    Navigator.of(context).popUntil(
      (route) {
        return route is TechnicianHomeScreen;
      },
    );
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

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                NotificationsScreen(notifications: notifications)));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: theme.colorScheme.onError,
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : SizedBox(
                width: double.maxFinite,
                child: Column(
                  children: [
                    _buildFrame(context),
                    Expanded(
                        child: SizedBox(
                      width: double.maxFinite,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 17.h, vertical: 28.v),
                        child: Column(
                          children: [
                            _buildSubscribeRow(context),
                            SizedBox(
                              height: 19.v,
                            ),
                            _buildStatusRow(context),
                            SizedBox(
                              height: 20.v,
                            ),
                            _buildUsersList(context)
                          ],
                        ),
                      ),
                    ))
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildFrame(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4.v),
      decoration: AppDecoration.gradientPrimaryToGray,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.v, vertical: 16.h),
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
              AppbarTitle(text: 'My Bookings'),
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
                SizedBox(height: 10.v),
                SizedBox(
                  width: 166.h,
                  child: Text(
                    "Get works around from you...",
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

  Widget _buildStatusRow(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 3.h, right: 11.h),
      padding: EdgeInsets.symmetric(horizontal: 8.h),
      decoration: AppDecoration.outlineBluegray100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildStatusButton("Pending", 'p', appTheme.gray500),
          _buildStatusButton("Completed", 'c', appTheme.gray500),
          _buildStatusButton("Rejected", 'r', appTheme.gray500),
        ],
      ),
    );
  }

  Widget _buildStatusButton(String text, String status, Color color) {
    final isSelected = screenId == status;
    return GestureDetector(
      onTap: () {
        setState(() {
          screenId = status;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.h, vertical: 2.v),
        decoration: AppDecoration.fillPrimary.copyWith(
          borderRadius: BorderRadiusStyle.customBorderTL5,
          color: isSelected ? theme.colorScheme.onError : Colors.transparent,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.black : color,
            fontSize: 16.fSize,
            fontFamily: 'Open Sans',
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildUsersList(BuildContext context) {
    log(completed.length.toString());
    log(rejected.length.toString());
    log(pending.length.toString());
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(left: 5.h, right: 5.h),
        child: (screenId == 'c' && completed.isEmpty) ||
                ((screenId == 'p' || screenId == 's') && pending.isEmpty) ||
                (screenId == 'r' && rejected.isEmpty)
            ? Column(
                children: [
                  SizedBox(
                    height: 230.v,
                  ),
                  Text(
                    screenId == 'c'
                        ? 'No completed bookings yet..'
                        : screenId == 'r'
                            ? 'No rejected bookings yet..'
                            : 'No pending bookings yet',
                    style: TextStyle(color: Colors.black, fontSize: 20.fSize),
                  ),
                ],
              )
            : ListView.separated(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                separatorBuilder: (context, index) {
                  return SizedBox(
                    height: 19.v,
                  );
                },
                itemCount: screenId == 'c'
                    ? completed.length
                    : screenId == 'p' || screenId == 's'
                        ? pending.length
                        : rejected.length,
                itemBuilder: (context, index) {
                  if (screenId == 'c') {
                    return CompletedWidget(
                      time: completed[index].time,
                      timing: completed[index].timing,
                      serviceName: completed[index].serviceName,
                      phone: completed[index].phone,
                      address: completed[index].address,
                      date: completed[index].date,
                      customerName: completed[index].customerName,
                      subCategory: completed[index].subCategory,
                    );
                  } else if (screenId == 'p' || screenId == 's') {
                    return PendingWidget(
                      location: pending[index].location,
                      serviceName: pending[index].serviceName,
                      timing: pending[index].timing,
                      docName: pending[index].docName,
                      id: pending[index].id,
                      phone: pending[index].phone,
                      address: pending[index].address,
                      date: pending[index].date,
                      customerName: pending[index].customerName,
                      subCategory: pending[index].subCategory,
                    );
                  } else {
                    return DeclineWidget(
                      time: rejected[index].time,
                      timing: rejected[index].timing,
                      serviceName: rejected[index].serviceName,
                      phone: rejected[index].phone,
                      address: rejected[index].address,
                      date: rejected[index].date,
                      customerName: rejected[index].customerName,
                      subCategory: rejected[index].subCategory,
                    );
                  }
                },
              ),
      ),
    );
  }
}
