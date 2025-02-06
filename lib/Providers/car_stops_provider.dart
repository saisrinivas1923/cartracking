import 'package:flutter/material.dart';

import '../services/export_services.dart';

class CarStopsProvider with ChangeNotifier {
  final CarStopsApiService _apiService = CarStopsApiService();
  List<String> _stops = [];
  bool _isLoading = true;

  List<String> get stops => _stops;
  bool get isLoading => _isLoading;

  Future<void> fetchStops(String carNumber) async {
    _isLoading = true;
    notifyListeners();

    try {
      _stops = await _apiService.fetchStops(carNumber);
    } catch (error) {
      debugPrint('Error fetching stops: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addStop(String carNumber, String stop) async {
  _stops.add(stop);  // Optimistically add to the list
  notifyListeners(); // Update UI immediately

  try {
    await _apiService.addStop(carNumber, stop);
  } catch (error) {
    debugPrint('Error adding stop: $error');
    _stops.remove(stop); // Revert the change if API call fails
    notifyListeners();
  }
}


  Future<void> removeStop(String carNumber, String stop) async {
    try {
      await _apiService.removeStop(carNumber, stop);
      _stops.remove(stop);
      notifyListeners();
    } catch (error) {
      debugPrint('Error removing stop: $error');
    }
  }

  Future<void> reorderStops(String carNumber, List<String> stops) async {
    try {
      await _apiService.reorderStops(carNumber, stops);
      _stops = stops;
      notifyListeners();
    } catch (error) {
      debugPrint('Error reordering stops: $error');
    }
  }
}