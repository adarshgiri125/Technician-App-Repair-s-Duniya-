import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:technician_app/firebase_options.dart';
import 'package:technician_app/notification.dart';
import 'package:technician_app/presentation/login_screen/login_screen.dart';
import 'package:technician_app/presentation/technician_home_screen/notifications_display.dart';
import 'package:technician_app/presentation/technician_home_screen/technician_home_screen.dart';
import 'package:technician_app/theme/theme_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message");
  createNotification(message);
}

var globalMessengerKey = GlobalKey<ScaffoldMessengerState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    if (message != null) {
      createNotification(message);
    }
  });
  FirebaseMessaging.instance
      .getInitialMessage()
      .then((RemoteMessage? message) async {
    if (message != null) {
      createNotification(message);
    }
  });

  FirebaseMessaging.onBackgroundMessage((message) async {
    if (message != null) {
      createNotification(message);
    }
  });
  FirebaseMessaging.onMessageOpenedApp.listen((message) async {
    // createNotification(message);
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
                ? const TechnicianHomeScreen()
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

createNotification(RemoteMessage message) async {
  AndroidNotificationChannel androidSettings = AndroidNotificationChannel(
    'default_channel_id',
    'High Importance Notifications',
    importance: Importance.high,
    playSound: true,
    sound: RawResourceAndroidNotificationSound(
        'notification.mp3'.split('.').first),
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(androidSettings);

  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;

  if (android == null) {
    print("something error in android missing");
  }
  print("check1 : $notification");

  if (notification != null && android != null) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          androidSettings.id,
          androidSettings.name,
          importance: Importance.max,
          color: Colors.blue,
          playSound: true,
          priority: Priority.max,
          audioAttributesUsage: AudioAttributesUsage
              .notification, // Set audioAttributesUsage to notification
          enableLights: true,
          enableVibration: true,
          icon: '@mipmap/ic_launcher',
          timeoutAfter: 40000,

          // other properties...
        ),
      ),
    );
    print("check2 : $notification");
  }
}
