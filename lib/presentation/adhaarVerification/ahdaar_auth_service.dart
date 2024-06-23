import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class AadhaarAuthService {
  final String baseUrl = "https://api.sandbox.co.in/kyc/aadhaar/okyc/otp"; // Replace with actual API endpoint

  Future<void> initiateAadhaarAuth(String aadhaarNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/initiate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'aadhaarNumber': aadhaarNumber}),
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "OTP sent to registered mobile number.");
      } else {
        Fluttertoast.showToast(msg: "Failed to initiate authentication.");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }

  Future<void> verifyOtp(String aadhaarNumber, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'aadhaarNumber': aadhaarNumber, 'otp': otp}),
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "Authentication successful.");
      } else {
        Fluttertoast.showToast(msg: "Failed to verify OTP.");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }
}
