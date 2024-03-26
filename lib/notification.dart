// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:technician_app/dialog.dart';
// import 'package:technician_app/presentation/technician_home_screen/notifications_display.dart';
// import 'dart:developer';
// import 'package:technician_app/presentation/technician_home_screen/technician_home_screen.dart';

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

// class PushNotificationSystem {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   User? _user;
//   FirebaseMessaging messaging = FirebaseMessaging.instance;
//   final int _timerDuration = 250;
//   bool _notificationHandled = false;

//   // for termination state
//   Future whenNotificationReceived(BuildContext context) async {
//     try {
//       _user = _auth.currentUser;

//       FirebaseMessaging.instance
//           .getInitialMessage()
//           .then((RemoteMessage? remoteMessage) {
//         if (remoteMessage != null && !_notificationHandled) {
//           handleNotification(remoteMessage, context);
//         }
//       });

//       // for foreground state
//       FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
//         if (remoteMessage != null && !_notificationHandled) {
//           handleNotification(remoteMessage, context);
//         }
//       });

//       // for background state
//       FirebaseMessaging.onMessageOpenedApp
//           .listen((RemoteMessage? remoteMessage) {
//         if (remoteMessage != null && !_notificationHandled) {
//           handleNotification(remoteMessage, context);
//         }
//       });
//     } catch (error) {
//       log("Error in whenNotificationReceived: $error");
//     }
//   }

//   void handleNotification(
//       RemoteMessage? remoteMessage, BuildContext context) async {
//     try {
//       if (remoteMessage != null) {
//         // Extract data from the message
//         String phoneNumber = remoteMessage.data!["phonenumber"];
//         String documentName = remoteMessage.data!["documentName"];
//         String user = remoteMessage.data!["user"];

//         // Call the method to handle the notification
//         createNotification(remoteMessage);
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//               builder: (context) => const NotificationsScreen(
//                     notifications: [],
//                   )),
//         );
//         // openAppShowAndShowNotification(
//         //     phoneNumber, documentName, user, context);

//         _notificationHandled = true;
//       }
//     } catch (error) {
//       log("Error handling notification: $error");
//     }
//   }

//   void createNotification(RemoteMessage message) async {
//     AndroidNotificationChannel androidSettings = AndroidNotificationChannel(
//       'default_channel_id',
//       'High Importance Notifications',
//       importance: Importance.high,
//       playSound: true,
//       sound: RawResourceAndroidNotificationSound(
//           'notification.mp3'.split('.').first),
//     );

//     await flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(androidSettings);

//     RemoteNotification? notification = message.notification;
//     AndroidNotification? android = message.notification?.android;

//     if (android == null) {
//       print("something error in android missing");
//     }
//     print("check1 : $notification");

//     if (notification != null && android != null) {
//       flutterLocalNotificationsPlugin.show(
//         notification.hashCode,
//         notification.title,
//         notification.body,
//         NotificationDetails(
//           android: AndroidNotificationDetails(
//             androidSettings.id,
//             androidSettings.name,
//             importance: Importance.max,
//             color: Colors.blue,
//             playSound: true,
//             priority: Priority.max,
//             audioAttributesUsage: AudioAttributesUsage
//                 .notification, // Set audioAttributesUsage to notification
//             enableLights: true,
//             enableVibration: true,
//             icon: '@mipmap/ic_launcher',
//             timeoutAfter: 40000,

//             // other properties...
//           ),
//         ),
//       );
//       print("check2 : $notification");
//     }
//   }
// }

// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   print("Handling a background message");
//   PushNotificationSystem().createNotification(message);
// }



// // --->>>
// //   openAppShowAndShowNotification(
// //       phoneNumber, documentName, user, context) async {
// //     try {
// //       log(user);
// //       log(_user!.uid);
// //       log(documentName);
// //       log(phoneNumber);

// //       // if (_user != null &&
// //       //     phoneNumber != null &&
// //       //     documentName != null &&
// //       //     user != null) {
// //       //   String customerTokenId = '';

// //       //   await FirebaseFirestore.instance
// //       //       .collection('customers')
// //       //       .doc(user)
// //       //       .get()
// //       //       .then((snapshot) {
// //       //     if (snapshot.data()!['device_token'] != null) {
// //       //       customerTokenId = snapshot.data()!['device_token'].toString();
// //       //       log(customerTokenId);
// //       //     }
// //       //   });

// //       // await FirebaseFirestore.instance
// //       //     .collection("customers")
// //       //     .doc(user)
// //       //     .collection("serviceDetails")
// //       //     .doc(documentName)
// //       //     .get()
// //       //     .then((snapshot) async {
// //       //   if (snapshot.exists) {
// //       //     bool job = snapshot.data()?['jobAcceptance'] ?? false;
// //       //     String phoneNumber = snapshot.data()?['userPhoneNumber'] ?? "error";
// //       //     int time = snapshot.data()?['timeIndex'] ?? -1;
// //       //     bool urgentBooking = snapshot.data()?['urgentBooking'] ?? false;
// //       //     Timestamp timeStamp = Timestamp.now();
// //       //     DateTime date = timeStamp.toDate();
// //       //     if (urgentBooking == false) {
// //       //       timeStamp = snapshot.data()?['serviceDate'] ?? Timestamp.now();
// //       //       date = timeStamp.toDate();
// //       //     }
// //       //     String address = snapshot.data()?['address']?.toString() ?? "hello";
// //       //     GeoPoint? geoPoint = snapshot.data()?['userLocation'];
// //       //     String service =
// //       //         snapshot.data()?['serviceName']?.toString() ?? 'hello';
// //       //     timeStamp = snapshot.data()?['DateTime'] ?? Timestamp.now();
// //       //     DateTime bookingTime = timeStamp.toDate();
// //       //     DateTime currentTime = DateTime.now();

// //       //     String timing = '';
// //       //     if (time == 0) {
// //       //       timing = 'Morning';
// //       //     } else if (time == 1) {
// //       //       timing = 'Afternoon';
// //       //     } else if (time == 2) {
// //       //       timing = 'Evening';
// //       //     }

// //       // if (currentTime.difference(bookingTime) <=
// //       //     const Duration(minutes: 3)) {
// //       // await _firestore
// //       //     .collection('technicians')
// //       //     .doc(_user!.uid)
// //       //     .collection('serviceList')
// //       //     .doc(documentName)
// //       //     .set({
// //       //   'jobAcceptance': job,
// //       //   'timeIndex': timing,
// //       //   'date': date,
// //       //   'serviceName': service,
// //       //   'serviceId': documentName,
// //       //   'customerPhone': phoneNumber,
// //       //   'urgentBooking': urgentBooking,
// //       //   'customerAddress': address,
// //       //   'customerLocation': geoPoint,
// //       //   'customerId': user,
// //       //   'customerTokenId': customerTokenId,
// //       //   'timestamp': FieldValue.serverTimestamp(),
// //       //   'status': 'n',
// //       // }, SetOptions(merge: true));

// //       // await _firestore
// //       //     .collection('technicians')
// //       //     .doc(_user!.uid)
// //       //     .collection('notifications')
// //       //     .add({
// //       //   'message': 'You have received a new booking.',
// //       //   'timestamp': FieldValue.serverTimestamp()
// //       // });

// //       // }

// //       Navigator.push(
// //         context,
// //         MaterialPageRoute(
// //             builder: (context) => const NotificationsScreen(
// //                   notifications: [],
// //                 )),
// //       );

// //       // Navigator.pushAndRemoveUntil(
// //       //     context,
// //       //     MaterialPageRoute(
// //       //         builder: (context) => const TechnicianHomeScreen()),
// //       //     ((route) => false));

// //       // Set the threshold for showing the dialog (2 minutes)
// //       // const int thresholdSeconds = 300;

// //       // Calculate the remaining time in seconds
// //       // int remainingSeconds = _timerDuration;

// //       // if (remainingSeconds <= thresholdSeconds &&
// //       //     currentTime.difference(bookingTime) <=
// //       //         const Duration(minutes: 3)) {
// //       //   // Show the dialog
// //       //   showDialog(
// //       //     context: context,
// //       //     builder: (context) => NotificationDialog(
// //       //       remainingSeconds: remainingSeconds,
// //       //       docname: documentName,
// //       //       serviceName: service,
// //       //       time: timing,
// //       //       date: date,
// //       //       urgent: urgentBooking,
// //       //       phoneNumber: phoneNumber,
// //       //       address: address,
// //       //       user: user,
// //       //     ),
// //       //   );
// //       //}
// //       // } else {
// //       //   // Handle the case where the document does not exist
// //       //   log("Document does not exist.");
// //       // }
// //       //   });
// //       // } else {
// //       //   // Handle the case where _user is null
// //       //   log("something is null.");
// //       // }
// //     } catch (error) {
// //       log("Error in openAppShowAndShowNotification: $error");
// //     }
// //   }
// // }