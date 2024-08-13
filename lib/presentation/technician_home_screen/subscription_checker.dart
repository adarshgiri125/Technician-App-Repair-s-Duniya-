import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:partnersapp/presentation/technician_home_screen/technician_home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionChecker extends StatefulWidget {
  @override
  _SubscriptionCheckerState createState() => _SubscriptionCheckerState();
}

class _SubscriptionCheckerState extends State<SubscriptionChecker> {
  bool? isSubscribed;
  String? userId;
  User? _user;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((User? user) {
      setState(() {
        _user = user;
        saveLogin();
      });
    });
    _getUserIdAndCheckSubscription();
  }

  Future<void> saveLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = await _user!.getIdToken();

    prefs.setString('userToken', token!);
  }

  Future<void> _getUserIdAndCheckSubscription() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
      _checkSubscription(user.uid);
    }
  }

  Future<void> _checkSubscription(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('technicians')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          isSubscribed = userDoc['subscription'] == true;
        });
      } else {
        setState(() {
          isSubscribed = false;
        });
      }
    } catch (e) {
      print("Error fetching subscription status: $e");
      setState(() {
        isSubscribed = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null || isSubscribed == null) {
      return Center(
          child:
              CircularProgressIndicator()); // Show loading indicator while fetching data
    }

    if (isSubscribed!) {
      return TechnicianHomeScreen(); // The main content of the home screen
    } else {
      return _showSubscriptionDialog(context);
    }
  }

  Widget _showSubscriptionDialog(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false; // Prevent back button from closing the dialog
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red, Colors.black], // Background gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
              backgroundColor: Colors.white
                  .withOpacity(0.9), // Foreground background with transparency
              title: Text(
                "Subscription Required",
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Title color
                ),
              ),
              content: Text(
                "To Get works, you need to have an active subscription plan. Please contact us to take suitable plan",
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black87, // Content color
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    // Add your contact method here, such as opening a phone dialer or an email app
                    const phoneNumber = '+919550589138';
                    final Uri launchUri = Uri(
                      scheme: 'tel',
                      path: phoneNumber,
                    );
                    await launchUrl(launchUri);
                  },
                  child: Text(
                    "Contact Us",
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue, // Button text color
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(
                        0.2), // Button background with transparency
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
