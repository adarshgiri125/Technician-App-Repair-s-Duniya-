import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:partnersapp/firebase_options.dart';
import 'package:partnersapp/notification.dart';
import 'package:partnersapp/notification1.dart';
import 'package:partnersapp/presentation/login_screen/login_screen.dart';
import 'package:partnersapp/presentation/technician_home_screen/notifications_display.dart';
import 'package:partnersapp/presentation/technician_home_screen/subscription_checker.dart';
import 'package:partnersapp/presentation/technician_home_screen/technician_home_screen.dart';
import 'package:partnersapp/theme/theme_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message");
  if (message != null) {
    String notificationTitle = message.notification?.title ?? "No title";
    String notificationBody = message.notification?.body ?? "No message body";
    LocalNotificationService.showBasicNotification(
        notificationTitle, notificationBody);
  }
}

var globalMessengerKey = GlobalKey<ScaffoldMessengerState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await Future.wait([
    LocalNotificationService.init(),
  ]);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    if (message != null) {
      String notificationTitle = message.notification?.title ?? "No title";
      String notificationBody = message.notification?.body ?? "No message body";
      LocalNotificationService.showBasicNotification(
          notificationTitle, notificationBody);
    }
  });
  FirebaseMessaging.instance
      .getInitialMessage()
      .then((RemoteMessage? message) async {
    if (message != null) {
      String notificationTitle = message.notification?.title ?? "No title";
      String notificationBody = message.notification?.body ?? "No message body";
      LocalNotificationService.showBasicNotification(
          notificationTitle, notificationBody);
    }
  });

  FirebaseMessaging.onBackgroundMessage((message) async {
    if (message != null) {
      String notificationTitle = message.notification?.title ?? "No title";
      String notificationBody = message.notification?.body ?? "No message body";
      LocalNotificationService.showBasicNotification(
          notificationTitle, notificationBody);
    }
  });
  FirebaseMessaging.onMessageOpenedApp.listen((message) async {
    // createNotification(message);
    if (message != null) {
      String notificationTitle = message.notification?.title ?? "No title";
      String notificationBody = message.notification?.body ?? "No message body";
      LocalNotificationService.showBasicNotification(
          notificationTitle, notificationBody);
    }
    Navigator.push(
      globalMessengerKey.currentContext!,
      MaterialPageRoute(
        builder: (context) => const NotificationsScreen(
          notifications: [],
        ),
      ),
    );
  });

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeHelper().themeData(),
      title: 'rd_technician_app',
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: checkLoginStatus(context), // Check login status asynchronously
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Return the appropriate screen based on the login status
            return snapshot.data == true
                ? SubscriptionChecker()
                : const LoginScreen();
          } else {
            // Return a loading indicator or splash screen while checking login status
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }

  Future<bool> checkLoginStatus(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString('userToken');
    if (token != null) {
      return await checkUserExistsInFirebase(context, token);
    }
    // Token is not valid or not present, return false
    return false;
  }

  Future<bool> checkUserExistsInFirebase(
      BuildContext context, String token) async {
    try {
      // Check if the device is connected to the internet
      var connectivityResult = await Connectivity().checkConnectivity();
      bool isConnected = true;
      if (connectivityResult == ConnectivityResult.none) {
        print('No internet connection');
        isConnected = false; // Stop execution
      }

      if (!isConnected) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('No internet connection. Please check your connection.'),
          ),
        );
        return false;
      }

      // Attempt to sign in with the custom token
      String uid = await FirebaseAuth.instance.currentUser!.uid;
      var userDoc = await FirebaseFirestore.instance
          .collection('technicians')
          .doc(uid)
          .get();
      if (userDoc.exists) {
        // User is registered
        return true;
      } else {
        // User is not registered
        return false;
      }
    } catch (e) {
      // Handle the error appropriately
      print("Error checking user existence: $e");
      // Return false indicating that user existence couldn't be verified
      return false;
    }
  }
}
