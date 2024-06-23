import 'package:flutter/material.dart';
import 'package:partnersapp/presentation/adhaarVerification/ahdaar_auth_service.dart';

class AadhaarAuthScreen extends StatefulWidget {
  @override
  _AadhaarAuthScreenState createState() => _AadhaarAuthScreenState();
}

class _AadhaarAuthScreenState extends State<AadhaarAuthScreen> {
  final AadhaarAuthService _aadhaarAuthService = AadhaarAuthService();
  final TextEditingController _aadhaarController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aadhaar Authentication'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _aadhaarController,
              decoration: InputDecoration(labelText: 'Enter Aadhaar Number'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                String aadhaarNumber = _aadhaarController.text;
                await _aadhaarAuthService.initiateAadhaarAuth(aadhaarNumber);
              },
              child: Text('Send OTP'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _otpController,
              decoration: InputDecoration(labelText: 'Enter OTP'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                String aadhaarNumber = _aadhaarController.text;
                String otp = _otpController.text;
                await _aadhaarAuthService.verifyOtp(aadhaarNumber, otp);
              },
              child: Text('Verify OTP'),
            ),
          ],
        ),
      ),
    );
  }
}