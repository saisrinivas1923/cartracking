import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class Runningcarsapiservice {
  final String apiBaseUrl;

  Runningcarsapiservice({required this.apiBaseUrl});

  Future<Map<String, dynamic>> fetchAllCars(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/get-location-of-all-cars'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token}),
      );

      if (response.statusCode == 200) {
        debugPrint('success to fetch cars: ${response.body}');
        return jsonDecode(response.body);
      } else {
        debugPrint('Failed to fetch cars: ${response.body}');
        return {};
      }
    } catch (e) {
      debugPrint('Error occurred: $e');
      throw Exception('Failed to fetch cars');
    }
  }
}
