import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VisitChargesScreen extends StatefulWidget {
  final String userId;

  const VisitChargesScreen({super.key, required this.userId});

  @override
  _VisitChargesScreenState createState() => _VisitChargesScreenState();
}

class _VisitChargesScreenState extends State<VisitChargesScreen> {
  final TextEditingController _chargesController = TextEditingController();
  bool _isFreeVisit = false;

  Future<void> _saveVisitCharges() async {
    try {
      Map<String, dynamic> visitChargesData = {
        'visitCharge': _isFreeVisit ? 'Free' : _chargesController.text,
      };

      await FirebaseFirestore.instance
          .collection('technicians')
          .doc(widget.userId)
          .set(visitChargesData, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Visit charges saved successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save visit charges')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Set Up Visit Charges"),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Set Up Visiting Charges",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              "Enter charges:",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _chargesController,
              decoration: InputDecoration(
                labelText: "Enter charges",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              enabled: !_isFreeVisit,
            ),
            SizedBox(height: 8),
            Text(
              "This charge will show to customers",
              style: TextStyle(fontSize: 13, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              "--------- OR ----------",
              style: TextStyle(fontSize: 18, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomCheckbox(
                  value: _isFreeVisit,
                  onChanged: (bool? value) {
                    setState(() {
                      _isFreeVisit = value ?? false;
                      if (_isFreeVisit) {
                        _chargesController.clear();
                      }
                    });
                  },
                ),
                SizedBox(width: 8),
                Text(
                  "I will do a free visit",
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              "High chance to customer book you",
              style: TextStyle(fontSize: 13, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              "Note: You will get bookings from 10 kms, set up low visiting charges accordingly so that customers can book you.",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 35),
            ElevatedButton(
              onPressed: _saveVisitCharges,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Update",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;

  const CustomCheckbox({
    Key? key,
    required this.value,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(4),
        color: Colors.white, // Checkbox background color
      ),
      child: Theme(
        data: ThemeData(
          unselectedWidgetColor: Colors.transparent, // Hide default border
        ),
        child: Checkbox(
          value: value,
          onChanged: onChanged,
          checkColor: Colors.black, // Checkmark color
          activeColor: Colors.white, // Checkbox fill color
          side: BorderSide(
              color: Colors.black, width: 2), // Checkbox border color
        ),
      ),
    );
  }
}
