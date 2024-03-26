import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:technician_app/core/app_export.dart';
import 'package:technician_app/presentation/login_screen/login_screen.dart';
import 'package:technician_app/widgets/custom_elevated_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: MediaQuery.of(context).size.width * 0.07,
            ),
          ),
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
            iconSize: MediaQuery.of(context).size.width * 0.08,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: StreamBuilder<User?>(
          stream: _auth.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Return a loading indicator if the user data is still loading.
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              // Handle any errors that occurred.
              return Text('Error: ${snapshot.error}');
            } else {
              // User data is available, use it to build the UI.
              User? user = snapshot.data;

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: MediaQuery.of(context).size.width * 0.2,
                      child: Icon(
                        Icons.person,
                        size: MediaQuery.of(context).size.width * 0.3,
                      ),
                    ),
                    SizedBox(
                      height: 5.v,
                    ),
                    Text(user?.phoneNumber ?? 'No phone number available'),
                    SizedBox(
                      height: 20.v,
                    ),
                    CustomElevatedButton(
                      onPressed: () => logOut(context),
                      height: 49.v,
                      width: 157.h,
                      text: "Log Out",
                      buttonStyle: CustomButtonStyles.none,
                      decoration: CustomButtonStyles
                          .gradientPrimaryToGrayTL13Decoration,
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Future<void> logOut(BuildContext context) async {
    await _auth.signOut();

    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false);
    return;
  }
}
