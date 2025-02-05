import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Constants/urls.dart';

class NonRunningApiService {
  Future<List<String>> fetchNonRunningCars(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/get-location-of-all-cars'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data.keys.toList();
      } else {
        throw Exception('Failed to retrieve Car location. ${response.body}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }
}