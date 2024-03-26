import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:technician_app/core/app_export.dart';
import 'package:technician_app/serviceCard.dart';

class NotificationsScreen extends StatefulWidget {
  final List<String> notifications;

  const NotificationsScreen({Key? key, required this.notifications})
      : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  User? _user;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((User? user) {
      setState(() {
        _user = user;
      });
    });
    removeExpiredNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notification',
          style: TextStyle(
            color: Colors.white,
            fontSize: MediaQuery.of(context).size.width * 0.06,
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
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: fetchNotificationsFromFirestore(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child:
                  CircularProgressIndicator(), // Loading indicator while fetching data
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            List<DocumentSnapshot> documents = snapshot.data ?? [];
            if (documents.isEmpty) {
              return Center(
                child: Text(
                  'No New Booking',
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),
              );
            }
            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, index) {
                // Extract relevant details from the document
                String serviceName = documents[index]['serviceName'];
                String time = documents[index]['timeIndex'];
                bool urgent = documents[index]['urgentBooking'];
                String address = documents[index]['customerAddress'];
                String phoneNumber = documents[index]['customerPhone'];
                DateTime date = documents[index]['date'].toDate();
                String user = documents[index]['customerId'];
                String status = documents[index]['status'];

                if (status == 'n') {
                  return NotificationCard(
                    remainingSeconds: 3,
                    docname: documents[index].id,
                    serviceName: serviceName,
                    time: time,
                    urgent: urgent,
                    address: address,
                    phoneNumber: phoneNumber,
                    date: date,
                    user: user,
                  );
                } else {
                  // Return an empty container if status is not 'n'
                  return Container();
                }
              },
            );
          }
        },
      ),
    );
  }

  Future<List<DocumentSnapshot>> fetchNotificationsFromFirestore() async {
    try {
      DateTime currentTime = DateTime.now();
      DateTime threeMinutesAgo = currentTime.subtract(Duration(minutes: 3));

      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('technicians')
          .doc(_user!.uid)
          .collection('serviceList')
          .where('timestamp', isGreaterThan: threeMinutesAgo)
          .orderBy('timestamp', descending: true)
          .get();

      List<DocumentSnapshot> documents = querySnapshot.docs;
      return documents;
    } catch (error) {
      print('Error fetching notifications from Firestore: $error');
      return [];
    }
  }

// Function to remove expired notifications
  Future<void> removeExpiredNotifications() async {
    try {
      DateTime currentTime = DateTime.now();
      DateTime threeMinutesAgo = currentTime.subtract(Duration(minutes: 3));

      // Delete documents where 'status' is 'n' and 'timestamp' is older than 3 minutes
      QuerySnapshot<Map<String, dynamic>> expiredNotifications =
          await _firestore
              .collection('technicians')
              .doc(_user!.uid)
              .collection('serviceList')
              .where('status', isEqualTo: 'n')
              .where('timestamp', isLessThan: threeMinutesAgo)
              .get();

      for (DocumentSnapshot<Map<String, dynamic>> document
          in expiredNotifications.docs) {
        await document.reference.delete();
      }
    } catch (error) {
      print('Error removing expired notifications: $error');
    }
  }
}
