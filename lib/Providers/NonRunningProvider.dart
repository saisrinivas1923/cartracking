import 'dart:async';
import 'package:flutter/material.dart';

import '../Services/NonRunningApiService.dart';
import '../Services/authState.dart';

class NonRunningProvider {
  final NonRunningApiService _apiService = NonRunningApiService();
  List<String> _allCars = [];
  List<String> _nonRunningCars = [];
  bool _isFetching = false;

  List<String> get allCars => _allCars;
  List<String> get nonRunningCars => _nonRunningCars;
  bool get isFetching => _isFetching;

  Future<void> fetchNonRunningCars(List<String> allCars) async {
    _isFetching = true;
    _allCars = allCars;

    try {
      final token = await AdminTokenStorage.getToken();
      final runningCars = await _apiService.fetchNonRunningCars(token!);
      _nonRunningCars = allCars.where((car) => !runningCars.contains(car)).toList();
    } catch (e) {
      // Handle error
      debugPrint('$e');
    } finally {
      _isFetching = false;
    }
  }
}