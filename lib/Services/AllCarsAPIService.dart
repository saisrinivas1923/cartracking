import 'dart:convert';
import 'package:http/http.dart' as http;

class AllCarsApiService {
  final String baseUrl;

  AllCarsApiService({required this.baseUrl});

  Future<Map<String, dynamic>> fetchCars(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/get-cars'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'token': token}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch cars');
    }
  }

   Future<Map<String, dynamic>> fetchAllData() async {
    final response = await http.get(
      Uri.parse('$baseUrl/all-data'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch data');
    }
  }
  
  Future<void> addCar({
    required String carNumber,
    required String carName,
    required String empId,
    required String name,
    required String phno,
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/add-car'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'carNumber': carNumber,
        'carName': carName,
        'empId': empId,
        'name': name,
        'phno': phno,
        'token': token,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add car');
    }
  }

  Future<void> deleteCar(String carNumber, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/remove-car'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'carNumber': carNumber, 'token': token}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete car');
    }
  }
}
