import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants/export_constants.dart';

class AdminDashboardApiService {

  AdminDashboardApiService();

  // Fetch car data
  Future<Map<String, dynamic>> fetchCarData() async {
    final url = Uri.parse('$apiBaseUrl/all-data');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['cars'];
    } else {
      throw Exception('Failed to fetch car data.');
    }
  }

  // Fetch bus locations
  Future<List<dynamic>> fetchBusLocations(String token) async {
    final url = Uri.parse('$apiBaseUrl/get-location-of-all-cars');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': token}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data.keys.toList();
    } else {
      throw Exception('Failed to fetch bus locations.');
    }
  }
}
