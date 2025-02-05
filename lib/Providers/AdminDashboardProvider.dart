import 'package:flutter/material.dart';

import '../Services/AdminDashboardApiService.dart';

class AdminDashboardProvider with ChangeNotifier {
  final AdminDashboardApiService apiService;

  AdminDashboardProvider({required this.apiService});

  Map<String, dynamic> _carList = {};
  List<dynamic> _cars = [];
  List<dynamic> _busLocations = [];
  bool _isLoading = false;
  bool _isLoading1 = false;
  
  Map<String, dynamic> get carList => _carList;
  List<dynamic> get cars => _cars;
  List<dynamic> get busLocations => _busLocations;
  bool get isLoading => _isLoading;
  bool get isLoading1 => _isLoading1;

  Future<void> fetchCarData() async {
    try {
      _isLoading = true;
      notifyListeners();

      final data = await apiService.fetchCarData();
      _carList = data;
      _cars = data.keys.toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching car data: $e');
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchBusLocations(String token) async {
    try {
      _isLoading1 = true;
      notifyListeners();

      final locations = await apiService.fetchBusLocations(token);
      _busLocations = locations;
    } catch (e) {
      debugPrint('Error fetching bus locations: $e');
      throw e;
    } finally {
      _isLoading1 = false;
      notifyListeners();
    }
  }
}
