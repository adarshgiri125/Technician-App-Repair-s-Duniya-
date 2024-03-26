import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:technician_app/core/app_export.dart';
import 'package:technician_app/presentation/my_bookings/my_bookings_screen.dart';
import 'package:technician_app/widgets/custom_elevated_button.dart';


class NotificationCard extends StatelessWidget {
  final int remainingSeconds;
  final String docname;
  final String serviceName;
  final String time;
  final bool urgent;
  final String address;
  final String phoneNumber;
  final DateTime date;
  final String user;

  const NotificationCard({
    Key? key,
    required this.remainingSeconds,
    required this.docname,
    required this.serviceName,
    required this.time,
    required this.urgent,
    required this.address,
    required this.phoneNumber,
    required this.date,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'New Customer - $serviceName',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20.adaptSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.v),
            Text(
              'Time remaining: Less than $remainingSeconds Minutes',
              style: CustomTextStyles.bodyMediumRed500,
            ),
            SizedBox(height: 15.v),
            Text(
              'User Phone Number: $phoneNumber',
              style: const TextStyle(color: Colors.black),
            ),
            SizedBox(height: 8.v),
            Text(
              'ServiceName: $serviceName',
              style: const TextStyle(color: Colors.black),
            ),
            SizedBox(height: 8.v),
            urgent == false
                ? Text(
                    'Time shift: $time',
                    style: const TextStyle(color: Colors.black),
                  )
                : const Text(
                    'Urgent Booking',
                    style: TextStyle(color: Colors.black),
                  ),
            SizedBox(height: 8.v),
            Text(
              'Date: ${date.day}/${date.month}/${date.year}',
              style: const TextStyle(color: Colors.black),
            ),
            SizedBox(height: 8.v),
            Text(
              'Address: $address',
              style: const TextStyle(color: Colors.black),
            ),
            SizedBox(height: 15.v),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: CustomElevatedButton(
                    onPressed: () {
                      _acceptBooking(context);
                    },
                    text: 'Accept',
                    height: 49.v,
                    margin: EdgeInsets.only(right: 6.h),
                    decoration: CustomButtonStyles
                        .gradientLightGreenAToLightGreenADecoration,
                    buttonStyle: CustomButtonStyles.none,
                  ),
                ),
                Expanded(
                  child: CustomElevatedButton(
                    onPressed: () {
                      _rejectBooking(context);
                    },
                    text: 'Reject',
                    height: 49.v,
                    margin: EdgeInsets.only(right: 6.h),
                    decoration:
                        CustomButtonStyles.gradientRedAToRedTL13Decoration,
                    buttonStyle: CustomButtonStyles.none,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _acceptBooking(BuildContext context) async {
    // Navigator.of(context).pop();
    await _setStatus('p');
    await _sendingNotification(context);
    await _changeBooking();
    // Navigator.pushAndRemoveUntil(
    //   context,
    //   MaterialPageRoute(builder: (context) => MyBookingsScreen(id: 'p')),
    //   (route) => false,
    // );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MyBookingsScreen(id: 'p'),
      ),
    );
  }

  void _rejectBooking(BuildContext context) async {
    // Navigator.of(context).pop();
    await _setStatus('r');
    // Navigator.pushAndRemoveUntil(
    //   context,
    //   MaterialPageRoute(builder: (context) => MyBookingsScreen(id: 'r')),
    //   (route) => false,
    // );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MyBookingsScreen(id: 'r'),
      ),
    );
  }

  Future<void> _sendingNotification(BuildContext context) async {
    final firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;
    final docName = this.docname;

    String customerId = "";
    String customerTokenId = "";
    String phoneNumber = "";
    String serviceName = "";

    await firestore
        .collection('technicians')
        .doc(user!.uid)
        .collection('serviceList')
        .doc(docName)
        .get()
        .then((snapshot) {
      customerId = snapshot.data()!['customerId'];
      customerTokenId = snapshot.data()!['customerTokenId'];
      phoneNumber = snapshot.data()!['customerPhone'];
      serviceName = snapshot.data()!['serviceName'];
    });

    await _notificationFormat(
      customerTokenId,
      customerId,
      phoneNumber,
      user,
      serviceName,
    );
  }

  Future<void> _notificationFormat(
    String customerTokenId,
    String customerId,
    String phoneNumber,
    User user,
    String serviceName,
  ) async {
    log("Building notification format...");
    log(customerTokenId);
    log(customerId);
    log(phoneNumber);
    log(user.toString());

    Map<String, String> headerNotification = {
      "Content-Type": "application/json",
      "Authorization":
          "key=AAAA0PM0nhk:APA91bGFFhcYO051DiIDsKkcBX5cuOMWwAD_OhGxojHbiBdSogf5IJ7M0sptK8PVl7ifwsbLAziNw9F0KTRfPTTm9ePqf0oFpbmLaQErM4HK9Inz7P7_3JWjmzX-1m8DFtlRTeeJe3KL",
    };

    Map bodyNotification = {
      "body": "Your $serviceName request has been successfully accepted.",
      "title": "Technician Assigned",
    };

    Map dataMap = {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": "1",
      "status": "done",
      "phonenumber": user.phoneNumber,
      "user": user.uid,
    };

    Map notificationOfficialFormat = {
      "notification": bodyNotification,
      "data": dataMap,
      "priority": "high",
      "to": customerTokenId,
    };

    log("Sending notification to customer $customerId...");
    try {
      final response = await http.post(
        Uri.parse("https://fcm.googleapis.com/fcm/send"),
        headers: headerNotification,
        body: jsonEncode(notificationOfficialFormat),
      );

      if (response.statusCode == 200) {
        log("Notification sent successfully to customer $customerId.");
        log(customerTokenId);
      } else {
        log("Failed to send notification to customer $customerId Status code: ${response.statusCode}");
      }
    } catch (e) {
      log("Error while sending notification to customer $customerId: $e");
    }
  }

  Future<void> _changeBooking() async {
    final customerUser = this.user;
    final docname = this.docname;
    final user = FirebaseAuth.instance.currentUser;
    final firestore = FirebaseFirestore.instance;

    String serviceID = "";

    await firestore
        .collection('technicians')
        .doc(user!.uid)
        .collection('serviceList')
        .doc(docname)
        .get()
        .then((snapshot) {
      serviceID = snapshot.data()!['serviceId'];
    });

    try {
      DocumentReference documentReference = FirebaseFirestore.instance
          .collection("customers")
          .doc(customerUser)
          .collection("serviceDetails")
          .doc(serviceID);

      DocumentSnapshot snapshot = await documentReference.get();

      if (snapshot.exists) {
        String? newPhoneNumber = user?.phoneNumber;
        bool accept = true;

        await documentReference.update({
          'userPhoneNumber': newPhoneNumber,
          'jobAcceptance': accept,
        });

        log('Booking details updated successfully.');
      } else {
        log('Document does not exist.');
      }
    } catch (e) {
      log('Error updating booking details: $e');
    }
  }

  Future<void> _setStatus(String status) async {
    final firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;
    final docname = this.docname;

    try {
      await firestore
          .collection('technicians')
          .doc(user!.uid)
          .collection('serviceList')
          .doc(docname)
          .update({'status': status});
    } catch (e) {
      log(e.toString());
    }
  }
}


// NotificationCard(
//   remainingSeconds: 60,
//   docname: 'your_doc_name',
//   serviceName: 'Your Service',
//   time: '10:00 AM',
//   urgent: false,
//   address: '123 Main St',
//   phoneNumber: '123-456-7890',
//   date: DateTime.now(),
//   user: 'customer_user_id',
// )
