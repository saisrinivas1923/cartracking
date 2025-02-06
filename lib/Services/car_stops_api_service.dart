import 'dart:convert';
import 'package:http/http.dart' as http;

import '../services/export_services.dart';
import '../constants/export_constants.dart';

class CarStopsApiService {
  Future<List<String>> fetchStops(String carNumber) async {
    final token = await AdminTokenStorage.getToken();
    final response = await http.post(
      Uri.parse('$apiBaseUrl/get-cars'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'token': token}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<String>.from(data[carNumber] ?? []);
    } else {
      throw Exception('Failed to fetch stops: ${response.body}');
    }
  }

  Future<void> addStop(String carNumber, String stop) async {
    final token = await AdminTokenStorage.getToken();
    final response = await http.post(
      Uri.parse('$apiBaseUrl/add-car-stop'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'carNumber': carNumber, 'stop': stop, 'token': token}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add stop: ${response.body}');
    }
  }

  Future<void> removeStop(String carNumber, String stop) async {
    final token = await AdminTokenStorage.getToken();
    final response = await http.post(
      Uri.parse('$apiBaseUrl/remove-car-stop'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'carNumber': carNumber, 'stop': stop, 'token': token}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to remove stop: ${response.body}');
    }
  }

  Future<void> reorderStops(String carNumber, List<String> stops) async {
    final token = await AdminTokenStorage.getToken();
    final response = await http.post(
      Uri.parse('$apiBaseUrl/modify-car-stops'),
      headers: {'Content-Type': 'application/json'},
      body:
          json.encode({'carNumber': carNumber, 'stops': stops, 'token': token}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to reorder stops: ${response.body}');
    }
  }
}
