import 'package:flutter/material.dart';

import '../Services/AllCarsAPIService.dart';

class CarProvider with ChangeNotifier {
  final AllCarsApiService apiService;
  List<String> _cars = [];
  bool _isLoading = false;
  bool _isLoading1 = false;
  Map<String, dynamic> _carList = {};
  Map<String, dynamic> _allList = {};
  List<dynamic> _carsdetails = [];

  List<String> get cars => _cars;
  bool get isLoading => _isLoading;
  bool get isLoading1 => _isLoading1;
  Map<String, dynamic> get carList => _carList;
  Map<String, dynamic> get allList => _allList;
  List<dynamic> get carsdetails => _carsdetails;

  CarProvider({required this.apiService});

  Future<void> fetchCars(String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await apiService.fetchCars(token);
      _cars = data.keys.toList();
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching cars: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCarData() async {
    _isLoading1 = true;
    notifyListeners();
    try {
      final data = await apiService.fetchAllData();
      _carList = data['cars'];
      _allList = data['details'];
      _carsdetails = allList.keys.toList();
      notifyListeners();
    } catch (e) {
      throw Exception(e.toString());
    } finally {
      _isLoading1 = false;
      notifyListeners();
    }
  }

  Future<void> addCar(String carNumber, String token, Map<String, String> details) async {
    try {
      await apiService.addCar(
        carNumber: carNumber,
        carName: details['carName'] ?? '',
        empId: details['empId'] ?? '',
        name: details['name'] ?? '',
        phno: details['phno'] ?? '',
        token: token,
      );
      _cars.add(carNumber);
      notifyListeners();
    } catch (e) {
      debugPrint("Error adding car: $e");
    }
  }

  Future<void> deleteCar(String carNumber, String token) async {
    try {
      await apiService.deleteCar(carNumber, token);
      _cars.remove(carNumber);
      notifyListeners();
    } catch (e) {
      debugPrint("Error deleting car: $e");
    }
  }
}
