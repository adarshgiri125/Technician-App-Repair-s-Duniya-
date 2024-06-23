import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:partnersapp/core/app_export.dart';
import 'package:partnersapp/serviceCard.dart';

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

                String customerName =
                    "New-User"; // Default value if customerName field doesn't exist in the document

                String subCategory = "error";

                var data =
                    documents[index].data(); // Retrieve data from the document
                if (data != null &&
                    data is Map<String, dynamic> &&
                    data.containsKey('customerName')) {
                  customerName = data[
                      'customerName']; // Assign the value of customerName if it exists
                } else {
                  // Handle the case where 'customerName' field doesn't exist in the document
                  // You can log an error, use a default value, or perform any other desired action
                  print("Field 'customerName' does not exist in the document");
                }

                if (data != null &&
                    data is Map<String, dynamic> &&
                    data.containsKey('subCategory')) {
                  subCategory = data[
                  'subCategory']; // Assign the value of customerName if it exists
                }

                if (status == 'n') {
                  return NotificationCard(
                    remainingSeconds: 5,
                    docname: documents[index].id,
                    serviceName: serviceName,
                    time: time,
                    urgent: urgent,
                    address: address,
                    phoneNumber: phoneNumber,
                    date: date,
                    user: user,
                    customerName: customerName,
                    subCategory:subCategory,
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
      DateTime fiveMinutesAgo = currentTime.subtract(Duration(minutes: 5));

      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('technicians')
          .doc(_user!.uid)
          .collection('serviceList')
          .where('timestamp', isGreaterThan: fiveMinutesAgo)
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
      DateTime fiveMinutesAgo = currentTime.subtract(Duration(minutes: 5));

      // Delete documents where 'status' is 'n' and 'timestamp' is older than 5 minutes
      QuerySnapshot<Map<String, dynamic>> expiredNotifications =
          await _firestore
              .collection('technicians')
              .doc(_user!.uid)
              .collection('serviceList')
              .where('status', isEqualTo: 'n')
              .where('timestamp', isLessThan: fiveMinutesAgo)
              .get();

      // Iterate over expired notifications and delete them
      for (DocumentSnapshot<Map<String, dynamic>> document
          in expiredNotifications.docs) {
        await document.reference.delete();
      }

      // Fetch documents from technician's serviceList collection
      QuerySnapshot<Map<String, dynamic>> technicianServiceListSnapshot =
          await _firestore
              .collection('technicians')
              .doc(_user!.uid)
              .collection('serviceList')
              .get();

      // Iterate over technician's serviceList documents
      for (DocumentSnapshot<Map<String, dynamic>> technicianServiceDoc
          in technicianServiceListSnapshot.docs) {
        String serviceId = technicianServiceDoc['serviceId'];
        String userid = technicianServiceDoc['customerId'] ?? "";

        // Fetch customer documents under given serviceId
        if (userid != "") {
          QuerySnapshot<Map<String, dynamic>> customerServiceListSnapshot =
              await _firestore
                  .collection('customers')
                  .doc('userid') // Replace 'userid' with the actual user ID
                  .collection('serviceDetails')
                  .where('serviceId', isEqualTo: serviceId)
                  .get();

          // Iterate over customer documents
          for (DocumentSnapshot<Map<String, dynamic>> customerServiceDoc
              in customerServiceListSnapshot.docs) {
            bool jobAcceptance = customerServiceDoc['jobAcceptance'] ?? false;

            // If jobAcceptance is true, delete corresponding technician serviceList document
            if (jobAcceptance) {
              await technicianServiceDoc.reference.delete();
            }
          }
        }
      }
    } catch (error) {
      print('Error removing expired notifications: $error');
    }
  }
}
