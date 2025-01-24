import '../Constants/widget.dart';
import '../Screens/Carstops.dart';
import '../Services/authState.dart';
import '../Services/runningCarsApiService.dart';
import 'package:flutter/material.dart';

class Runningcarsprovider with ChangeNotifier {
  final Runningcarsapiservice apiService;
  List<String> _Cars = [];
  bool _isFetching = false;
  var data;

  List<String> get Cars => _Cars;
  bool get isFetching => _isFetching;

  Runningcarsprovider({required this.apiService});

  Future<void> fetchAllCars() async {
    _isFetching = true;
    notifyListeners();

    try {
      final token = await AdminTokenStorage.getToken();
      data = await apiService.fetchAllCars(token!);

      if (data.isNotEmpty) {
        _Cars = data.keys.toList();
      } else {
        _Cars = [];
        debugPrint('No cars found.');
      }
    } catch (e) {
      debugPrint('Error fetching cars: $e');
    } finally {
      _isFetching = false;
      notifyListeners();
    }
  }

  Future<void> navigateToCarLocation(
      BuildContext context, String carNumber) async {
    try {
      if (data.containsKey(carNumber)) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminCarMapPage(carNumber: carNumber),
          ),
        );
      } else {
        CustomWidget.showSnackBar('Car Not Started', context);
      }
    } catch (e) {
      debugPrint('Error occurred: $e');
    }
  }
}
