import 'package:flutter/material.dart';
import 'package:technician_app/core/app_export.dart';
import 'package:technician_app/help_support.dart';
import 'package:technician_app/presentation/my_bookings/my_bookings_screen.dart';
import 'package:technician_app/presentation/technician_home_screen/technician_home_screen.dart';

class HalfPage extends StatelessWidget {
  final VoidCallback onClose;

  const HalfPage({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () {
          onClose();
        },
        child: Container(
          height:
              MediaQuery.of(context).size.height * 0.2, // Set a fixed height
          margin: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 0.09,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          decoration: AppDecoration.gradientPrimaryToGray,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 30.v),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildContainer(
                      context,
                      ImageConstant.homeIcon,
                      'Home',
                    ),
                    _buildContainer(
                      context,
                      ImageConstant.bookingIcon,
                      'My Bookings',
                    ),
                    _buildContainer(
                      context,
                      ImageConstant.contactIcon,
                      'Contact',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContainer(BuildContext context, String imagePath, String name) {
    return GestureDetector(
      onTap: () {
        if (name == 'Home') {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => const TechnicianHomeScreen()),
              (route) => false);
        } else if (name == 'My Bookings') {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => MyBookingsScreen(id: 'p')),
              (route) => false);
        } else if (name == 'Contact') {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => const HelpSupportScreen()),
              (route) => false);
        }
      },
      child: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.1,
            width: MediaQuery.of(context).size.height * 0.1,
            decoration: BoxDecoration(
              color: Colors.black,
              shape: BoxShape.rectangle,
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage(imagePath), // Use your actual image path
              ),
            ),
          ),
          SizedBox(
            height: 8.v,
          ),
          Text(
            name,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
          // Remove SizedBox to reduce extra space
        ],
      ),
    );
  }
}
