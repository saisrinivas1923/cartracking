import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import '../Services/authState.dart';
import '../constants/urls.dart';

class CarLocationProvider with ChangeNotifier {
  final String carNumber;
  LatLng? _currentLocation;
  StreamSubscription<LocationData>? _locationSubscription;
  final Location _location = Location();
  bool _isPermissionGranted = false;
  bool _isPermissionDeniedForever = false;
  String? errorMessage;
  bool _disposed = false;
  DateTime? _lastSentTime;

  LatLng? get currentLocation => _currentLocation;
  bool get isPermissionGranted => _isPermissionGranted;
  bool get isPermissionDeniedForever => _isPermissionDeniedForever;

  CarLocationProvider({required this.carNumber});

  Future<void> _storeCarData(
      String busNumber, double latitude, double longitude, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/update-car-location'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'carNumber': carNumber,
          'latitude': latitude,
          'longitude': longitude,
          'token': token,
        }),
      );
      if (response.statusCode != 200) {
        debugPrint('Failed to store car location: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error occurred while storing car location: $e');
    }
  }

  Future<void> startCarLocationUpdates(String token) async {
    try {
      final permissionStatus = await _location.requestPermission();
      debugPrint('Permission status: $permissionStatus');
      if (permissionStatus == PermissionStatus.denied) {
        _isPermissionGranted = false;
        errorMessage = "Permission denied. Please allow location access.";
        notifyListeners();
        return;
      }
      if (permissionStatus == PermissionStatus.deniedForever) {
        _isPermissionDeniedForever = true;
        errorMessage =
            "Permission permanently denied. Please enable location in settings.";
        notifyListeners();
        return;
      }
      if (permissionStatus == PermissionStatus.granted) {
        if (!await _location.serviceEnabled()) {
          if (!await _location.requestService()) {
            errorMessage =
                "Location services are disabled. Please enable them.";
            _isPermissionGranted = false;
            notifyListeners();
            debugPrint("Location services are not enabled");
            return;
          }
        }
        _isPermissionGranted = true;
        errorMessage = null;
        notifyListeners();

        await BusnoTokenStorage.saveToken(carNumber);
        // Start the background service
        _locationSubscription =
            _location.onLocationChanged.listen((locationData) {
          _currentLocation =
              LatLng(locationData.latitude!, locationData.longitude!);
          debugPrint("Location: $_currentLocation");
          // Store the current location on the server
          // Check if sufficient time has passed since the last update
          final now = DateTime.now();
          if (_lastSentTime == null ||
              now.difference(_lastSentTime!) >= const Duration(seconds: 5)) {
            _lastSentTime = now;
            debugPrint("Last sent time: $_lastSentTime");
            // Store the current location on the server
            // _storeCarData(
            //   carNumber,
            //   locationData.latitude!,
            //   locationData.longitude!,
            //   token,
            // );
          }
          notifyListeners();
        });
      }
    } catch (e) {
      errorMessage = "An unexpected error occurred: $e";
      notifyListeners();
    }
  }

  Future<void> stopLocationUpdates(String? token) async {
    if (token == null || token.isEmpty) {
      debugPrint('Invalid token: Cannot stop location updates.');
      return;
    }
    await BusnoTokenStorage.removeToken(carNumber);
    _locationSubscription?.cancel();
    _locationSubscription = null;
    notifyListeners();
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/stop-car-location'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'carNumber': carNumber, 'token': token}),
      );
      if (response.statusCode == 200) {
        debugPrint('Car location removed successfully!');
      } else {
        debugPrint('Failed to remove bus location: ${response.body}');
      }
    } catch (e) {
      errorMessage = "Error stopping location updates: $e";
      notifyListeners();
    }

    // Notify listeners only if the provider is not disposed
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() async {
    final token = await TokenStorage.getToken();
    _disposed = true;
    stopLocationUpdates(token);
    final service = FlutterBackgroundService();
    if (await service.isRunning()) {
      service.invoke("stopService");
    }
    _locationSubscription?.cancel();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    } else {
      debugPrint('Provider is disposed. notifyListeners() skipped.');
    }
  }
}

// List of free map providers with their URLs
class MapProvider {
  final String name;
  final String urlTemplate;
  final List<String>? subdomains;

  MapProvider({required this.name, required this.urlTemplate, this.subdomains});
}

// Available map providers
final List<MapProvider> mapProviders = [
  MapProvider(
    name: 'OpenStreetMap',
    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  ),
  MapProvider(
    name: 'Carto Positron',
    urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
    subdomains: ['a', 'b', 'c', 'd'],
  ),
  MapProvider(
    name: 'Carto Dark Matter',
    urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
    subdomains: ['a', 'b', 'c', 'd'],
  ),
  MapProvider(
    name: 'Esri Satellite',
    urlTemplate:
        'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
    subdomains: null,
  ),
];

// State management with Provider
class MapState with ChangeNotifier {
  MapProvider _selectedProvider = mapProviders[0];

  MapProvider get selectedProvider => _selectedProvider;

  void updateProvider(MapProvider provider) {
    _selectedProvider = provider;
    notifyListeners();
  }
}
