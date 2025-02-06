import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../services/export_services.dart';
import '../constants/export_constants.dart';

class CarsLocationProvider extends ChangeNotifier {
  final String carNumber;

  LatLng? _carLocation;
  LatLng? get carLocation => _carLocation;

  CarsLocationProvider({required this.carNumber}) {
    _startCarFetchingLocation();
  }

  late final StreamSubscription _locationSubscription;

  void _startCarFetchingLocation() {
    _locationSubscription = Stream.periodic(const Duration(seconds: 5))
        .asyncMap((_) => _fetchCarLocation())
        .listen((location) {
      if (location != null) {
        _carLocation = location;
        notifyListeners();
      }
    });
  }

  Future<LatLng?> _fetchCarLocation() async {
    final token = await AdminTokenStorage.getToken();
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/get-location-of-a-car'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'carNumber': carNumber,'token':token}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('=========== $data ===========');
        return LatLng(data['latitude'], data['longitude']);
      } else {
        debugPrint('Failed to retrieve car location: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching bus location: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _locationSubscription.cancel();
    super.dispose();
  }
}
