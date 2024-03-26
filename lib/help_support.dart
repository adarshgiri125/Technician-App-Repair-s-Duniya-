import 'package:flutter/material.dart';
import 'package:technician_app/core/app_export.dart';
import 'package:technician_app/presentation/technician_home_screen/technician_home_screen.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Help and Support',
            style: TextStyle(
                color: Colors.white,
                fontSize: MediaQuery.of(context).size.width * 0.07),
          ),
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
            iconSize: MediaQuery.of(context).size.width * 0.08,
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const TechnicianHomeScreen()),
                  (route) => false);
            },
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                  radius: MediaQuery.of(context).size.width * 0.2,
                  child: Image.asset(ImageConstant.imgEllipse12)),
              SizedBox(
                height: 10.v,
              ),
              const Text(
                'Call: +91 9550589138',
                style: TextStyle(color: Colors.black),
              ),
              SizedBox(
                height: 5.v,
              ),
              const Text(
                'Mail: repairsduniya@gmail.com',
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
