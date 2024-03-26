import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:technician_app/core/app_export.dart';
import 'package:technician_app/presentation/technician_home_screen/technician_home_screen.dart';
import 'package:technician_app/widgets/custom_elevated_button.dart';

class ServiceSelectionScreen extends StatefulWidget {
  const ServiceSelectionScreen({Key? key}) : super(key: key);

  @override
  State<ServiceSelectionScreen> createState() => _ServiceSelectionScreenState();
}

class _ServiceSelectionScreenState extends State<ServiceSelectionScreen> {
  User? _user;
  List<String> services = [];
  bool flag = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, String> serviceImages = {
    'AC': ImageConstant.imgImage38,
    'Fridge': ImageConstant.imgImage34,
    'Plumber': ImageConstant.imgImage83,
    'Electrician': ImageConstant.electrician,
    'Geyser': ImageConstant.geyser,
    'Air Cooler': ImageConstant.aircooler,
    'MicroWave': ImageConstant.microwave,
    'Painter': ImageConstant.painter,
    'Construction/Renovation': ImageConstant.construction,
    'Washing Machine': ImageConstant.imgImage31,
  };

  List<String> servicesList = [
    'AC',
    'Fridge',
    'Plumber',
    'Electrician',
    'Geyser',
    'Air Cooler',
    'MicroWave',
    'Painter',
    'Construction/Renovation',
    'Washing Machine',
  ];

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((User? user) {
      setState(() {
        _user = user;
      });
    });
  }

  void toggleService(String serviceName) {
    setState(() {
      if (services.contains(serviceName)) {
        services.remove(serviceName);
      } else {
        services.add(serviceName);
      }
      flag = services.isNotEmpty;
    });
  }

  Future<void> uploadServices() async {
    try {
      await _firestore.collection('technicians').doc(_user!.uid).set(
        {'services': FieldValue.arrayUnion(services)},
        SetOptions(merge: true),
      );

      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const TechnicianHomeScreen()),
          (route) => false);
    } catch (e) {
      log("Failed to upload services: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: const Alignment(0.5, 0),
              end: const Alignment(0.5, 1),
              colors: [
                theme.colorScheme.onError,
                appTheme.gray50,
              ],
            ),
          ),
          child: Container(
            width: double.maxFinite,
            padding: EdgeInsets.symmetric(
              horizontal: 23.h,
              vertical: 29.v,
            ),
            child: Column(
              children: [
                CustomImageView(
                  imagePath: ImageConstant.imgImage91,
                  height: 154.v,
                  width: 181.h,
                ),
                SizedBox(height: 24.v),
                Text(
                  "Service Selection",
                  style: theme.textTheme.headlineSmall,
                ),
                SizedBox(height: 12.v),
                Text(
                  "Select the services you render below",
                  style: theme.textTheme.bodyLarge,
                ),
                SizedBox(height: 32.v),
                Expanded(
                  child: SingleChildScrollView(
                    primary: false,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Container(
                      padding: EdgeInsets.only(
                          bottom: 32.v), // Adjust spacing as needed
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 32.0,
                        children: servicesList.map((serviceName) {
                          return _buildServiceTile(serviceName);
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30.v),
                CustomElevatedButton(
                  buttonStyle: flag == true
                      ? const ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.black))
                      : const ButtonStyle(),
                  text: "Confirm",
                  onPressed: () {
                    uploadServices();
                  },
                ),
                SizedBox(height: 32.v),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceTile(String serviceName) {
    bool isSelected = services.contains(serviceName);
    String imagePath = serviceImages.containsKey(serviceName)
        ? serviceImages[serviceName]!
        : ImageConstant.imgMenu;

    return Column(
      children: [
        Container(
          height: 100.adaptSize,
          width: 100.adaptSize,
          padding: EdgeInsets.symmetric(
            vertical: 10.v,
          ),
          decoration: AppDecoration.outlineBlueGrayE.copyWith(
            borderRadius: BorderRadiusStyle.roundedBorder10,
            color: isSelected ? const Color(0xFFCBCBCB) : Colors.white,
          ),
          child: CustomImageView(
            onTap: () {
              toggleService(serviceName);
            },
            imagePath: imagePath,
            height: 120.adaptSize,
            width: 100.adaptSize,
            alignment: Alignment.topCenter,
          ),
        ),
        SizedBox(height: 5.v), // Adjust spacing as needed
        Text(
          serviceName,
          style: theme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.v),
      ],
    );
  }
}
