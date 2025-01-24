import 'dart:convert';
import 'package:car_tracking/Screens/admindashboard.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Constants/urls.dart';
import '../Screens/adminlogin.dart';
import '../Screens/driver_page.dart';
import '../Screens/driverlogin.dart';
import '../Screens/CarDisplay.dart';

class ApiService {
  Future<Map<String, dynamic>> loginDriver(
      String driverId, String password) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/login-driver'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'driverId': driverId, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to login driver: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> loginAdmin(
      String adminId, String password) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/login-admin'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'adminId': adminId, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to login admin: ${response.body}');
    }
  }
}

class TokenStorage {
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('driver_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('driver_token');
  }
}

class AdminTokenStorage {
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}

class BusnoTokenStorage {
  static Future<void> saveToken(String busno) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('busno', busno);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('busno');
  }

  //remove
  static Future<void> removeToken(String busno) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('busno');
  }
}

class DriverAuthState extends StatefulWidget {
  const DriverAuthState({super.key});

  @override
  State<DriverAuthState> createState() => _DriverAuthStateState();
}

class _DriverAuthStateState extends State<DriverAuthState> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Simulate a check for login status
    final token = await TokenStorage.getToken();

    if (token != null) {
      // Token exists, navigate to the dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DriverPage()),
      );
    } else {
      // No token, navigate to the login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DriverLoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
          child: CircularProgressIndicator(
        color: Colors.orange,
      )),
    );
  }
}

class AdminAuthState extends StatefulWidget {
  const AdminAuthState({super.key});

  @override
  State<AdminAuthState> createState() => _AdminAuthStateState();
}

class _AdminAuthStateState extends State<AdminAuthState> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Simulate a check for login status
    final token = await AdminTokenStorage.getToken();

    if (token != null) {
      // Token exists, navigate to the dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Admindashboard()),
      );
    } else {
      // No token, navigate to the login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Adminlogin()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
          child: CircularProgressIndicator(
        color: Colors.orange,
      )),
    );
  }
}
