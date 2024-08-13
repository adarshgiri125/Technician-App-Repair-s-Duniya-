import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:partnersapp/theme/custom_button_style.dart';
import 'package:partnersapp/widgets/custom_elevated_button.dart';

class AddOfferScreen extends StatefulWidget {
  final String userId;

  const AddOfferScreen({super.key, required this.userId});

  @override
  _AddOfferScreenState createState() => _AddOfferScreenState();
}

class _AddOfferScreenState extends State<AddOfferScreen> {
  String? _selectedService;
  String _offerValue = "";
  Map<String, String> _existingOffers = {};

  @override
  void initState() {
    super.initState();
    _fetchExistingOffers();
  }

  Future<void> _fetchExistingOffers() async {
    try {
      DocumentSnapshot offersSnapshot = await FirebaseFirestore.instance
          .collection('technicians')
          .doc(widget.userId)
          .collection('offers')
          .doc('offersDocument')
          .get();

      if (offersSnapshot.exists) {
        setState(() {
          _existingOffers =
              Map<String, String>.from(offersSnapshot.data() as Map);
        });
      }
    } catch (e) {
      log('Error fetching existing offers: $e');
    }
  }

  Future<void> _addOffer() async {
    try {
      if (_selectedService == null || _offerValue.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select a service and enter an offer value'),
          ),
        );
        return;
      }

      Map<String, String> offerData = {_selectedService!: _offerValue};

      await FirebaseFirestore.instance
          .collection('technicians')
          .doc(widget.userId)
          .collection('offers')
          .doc('offersDocument')
          .set(offerData, SetOptions(merge: true));

      // Update the local state
      setState(() {
        _existingOffers[_selectedService!] = _offerValue;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Offer added successfully!')),
      );

      // Delay for a short time before popping the screen
      Future.delayed(Duration(milliseconds: 50), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AddOfferScreen(userId: widget.userId),
          ),
        );
      });
    } catch (e) {
      log('Error adding offer: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add offer')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Offer"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 16),
            Text(
              "Select Your Category",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('technicians')
                    .doc(widget.userId)
                    .get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var data = snapshot.data!.data() as Map<String, dynamic>;
                  log('Snapshot data: $data');

                  if (!data.containsKey('services')) {
                    return Center(child: Text("No services available."));
                  }

                  var services = List<String>.from(data['services']);
                  log('Services: $services');

                  if (services.isEmpty) {
                    return Center(child: Text("No services available."));
                  }

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      var service = services[index];
                      bool isSelected = _selectedService == service;
                      String offerText = _existingOffers.containsKey(service)
                          ? "Offer: ${_existingOffers[service]}"
                          : "No offer";

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedService = service;
                            _offerValue = _existingOffers[service] ?? "";
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                            border: Border.all(
                              color: isSelected ? Colors.blue : Colors.grey,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                service,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                offerText,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.red,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            if (_selectedService != null)
              Text(
                "Selected Service: $_selectedService",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: "Enter Offer Value (in Rupees)",
                labelStyle: TextStyle(color: Colors.blueAccent),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {
                  _offerValue = value;
                });
              },
              keyboardType: TextInputType.number,
              style: TextStyle(color: Colors.black87),
            ),
            SizedBox(height: 20),
            Center(
              child: CustomElevatedButton(
                height: 70.0,
                width: double.infinity,
                text: "Update Offer",
                buttonStyle: CustomButtonStyles.none,
                decoration:
                    CustomButtonStyles.gradientPrimaryToGrayTL13Decoration,
                onPressed: _selectedService == null || _offerValue.isEmpty
                    ? null
                    : _addOffer,
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
