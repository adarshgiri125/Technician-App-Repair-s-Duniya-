// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:partnersapp/core/app_export.dart';
import 'package:partnersapp/presentation/my_bookings/my_bookings_screen.dart';
import 'package:partnersapp/widgets/custom_elevated_button.dart';

class NotificationDialog extends StatefulWidget {
  final int remainingSeconds;
  final String docname;
  final String serviceName;
  final String time;
  final bool urgent;
  final String address;
  final String phoneNumber;
  final DateTime date;
  final String user;
  const NotificationDialog({
    super.key,
    required this.remainingSeconds,
    required this.docname,
    required this.serviceName,
    required this.time,
    required this.urgent,
    required this.address,
    required this.phoneNumber,
    required this.date,
    required this.user,
  });

  @override
  _NotificationDialogState createState() => _NotificationDialogState();
}

class _NotificationDialogState extends State<NotificationDialog> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  late int _remainingSeconds;
  late Timer _timer;
  late String _docname;
  late String _serviceName;
  late String _time;
  late bool _urgent;
  late String _address;
  late String _phoneNumber;
  late String _date;
  late String _customerUser;

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((User? user) {
      setState(() {
        _user = user;
      });
    });
    _remainingSeconds = widget.remainingSeconds;
    _startTimer();
    _docname = widget.docname;
    _serviceName = widget.serviceName;
    _time = widget.time;
    _urgent = widget.urgent;
    _address = widget.address;
    _phoneNumber = widget.phoneNumber;
    final DateTime date = widget.date;
    String servicedate = '${date.day}/${date.month}/${date.year}';
    _date = servicedate;
    _customerUser = widget.user;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
        setStatus('r');
        Navigator.of(context).pop();
      }
    });
  }

  Future<void> setStatus(String status) async {
    try {
      await _firestore
          .collection('technicians')
          .doc(_user!.uid)
          .collection('serviceList')
          .doc(_docname)
          .update({'status': status});
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('New Customer - $_serviceName',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.adaptSize,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 20.v),
            Text('Time remaining: $_remainingSeconds seconds',
                style: CustomTextStyles.bodyMediumRed500),
            SizedBox(height: 15.v),
            Text(
              'User Phone Number: $_phoneNumber',
              style: const TextStyle(color: Colors.black),
            ),
            SizedBox(height: 8.v),
            Text(
              'ServiceName: $_serviceName',
              style: const TextStyle(color: Colors.black),
            ),
            SizedBox(height: 8.v),
            _urgent == false
                ? Text(
                    'Time shift: $_time',
                    style: const TextStyle(color: Colors.black),
                  )
                : const Text(
                    'Urgent Booking',
                    style: TextStyle(color: Colors.black),
                  ),
            SizedBox(height: 8.v),
            Text(
              'Date: $_date',
              style: const TextStyle(color: Colors.black),
            ),
            SizedBox(height: 8.v),
            Text(
              'Address: $_address',
              style: const TextStyle(color: Colors.black),
            ),
            SizedBox(height: 15.v),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: CustomElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      sendingNotification(_firestore, _user, _docname);
                      changeBooking(_customerUser, _docname, _user!);
                      setStatus('p');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyBookingsScreen(id: 'p'),
                        ),
                      );
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
                      Navigator.of(context).pop();
                      setStatus('r');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyBookingsScreen(id: 'r'),
                        ),
                      );
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
}

Future<void> sendingNotification(
  FirebaseFirestore firestore,
  User? user,
  String docName,
) async {
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

  notificationFormat(
      customerTokenId, customerId, phoneNumber, user, serviceName);
}

notificationFormat(String customerTokenId, String customerId,
    String phoneNumber, User user, String serviceName) async {
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

Future<void> changeBooking(
    String customerUser, String docname, User user) async {
  try {
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection("customers")
        .doc(customerUser)
        .collection("serviceDetails")
        .doc(docname);

    DocumentSnapshot snapshot = await documentReference.get();

    if (snapshot.exists) {
      // Update the values (replace these with your desired changes)
      String? newPhoneNumber = user.phoneNumber;
      bool accept = true; // Toggle the value, for example

      // Update the document with new values
      await documentReference.update({
        'userPhoneNumber': newPhoneNumber,
        'jobAcceptance': accept,
      });

      log('Booking details updated successfully.');
    } else {
      log('Document does not exist.');
      // Handle the case where the document doesn't exist if needed
    }
  } catch (e) {
    log('Error updating booking details: $e');
    // Handle the error as needed
  }
}
