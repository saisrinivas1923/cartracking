import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../Providers/CarLocationProvider.dart';
import '../Providers/CarsDetailsProvider.dart';
import '../constants/widget.dart';
import '../Services/localization_helper.dart';
import '../constants/urls.dart';
import '../Services/authState.dart';
import 'CarDisplay.dart';

class CarManageStopsScreen extends StatefulWidget {
  final String car;

  const CarManageStopsScreen({super.key, required this.car});

  @override
  _CarManageStopsScreenState createState() => _CarManageStopsScreenState();
}

class _CarManageStopsScreenState extends State<CarManageStopsScreen> {
  List<String> stops = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStops();
  }

  Future<void> fetchStops() async {
    final token = await AdminTokenStorage.getToken();
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/get-cars'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'token': token}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          stops = List<String>.from(data[widget.car] ?? []);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch stops: ${response.body}');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      CustomWidget.showSnackBar('Error fetching stops: $error', context);
    }
  }

  Future<void> addStop(String stop) async {
    final token = await AdminTokenStorage.getToken();
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/add-car-stop'),
        headers: {'Content-Type': 'application/json'},
        body: json
            .encode({'carNumber': widget.car, 'stop': stop, 'token': token}),
      );

      if (response.statusCode == 200) {
        setState(() {
          stops.add(stop);
        });
        CustomWidget.showSnackBar('Stop added successfully', context);
      } else {
        throw Exception('Failed to add stop: ${response.body}');
      }
    } catch (error) {
      CustomWidget.showSnackBar('Error adding stop: $error', context);
    }
  }

  Future<void> removeStop(String stop) async {
    final token = await AdminTokenStorage.getToken();
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/remove-car-stop'),
        headers: {'Content-Type': 'application/json'},
        body: json
            .encode({'carNumber': widget.car, 'stop': stop, 'token': token}),
      );

      if (response.statusCode == 200) {
        setState(() {
          stops.remove(stop);
        });
        if (stops.isEmpty) {
          Navigator.pop(context);
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const PlaceListPage()));
        }
        CustomWidget.showSnackBar('Stop removed successfully', context);
      } else {
        throw Exception('Failed to remove stop: ${response.body}');
      }
    } catch (error) {
      CustomWidget.showSnackBar('Error removing stop: $error', context);
    }
  }

  Future<void> reorderStops() async {
    final token = await AdminTokenStorage.getToken();
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/modify-car-stops'),
        headers: {'Content-Type': 'application/json'},
        body: json
            .encode({'carNumber': widget.car, 'stops': stops, 'token': token}),
      );

      if (response.statusCode == 200) {
        CustomWidget.showSnackBar('Stops reordered successfully', context);
      } else {
        throw Exception('Failed to reorder stops: ${response.body}');
      }
    } catch (error) {
      CustomWidget.showSnackBar('Error reordering stops: $error', context);
    }
  }

  void _showAddStopDialog() {
    String stopName = '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(LocalizationHelper.of(context).translate('as')),
          content: TextField(
            onChanged: (value) => stopName = value.trim(),
            decoration: InputDecoration(
              labelText: LocalizationHelper.of(context).translate('sn'),
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(LocalizationHelper.of(context).translate('cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                if (stopName.isNotEmpty) {
                  addStop(stopName);
                  Navigator.pop(context);
                } else {
                  CustomWidget.showSnackBar(
                      'Stop name cannot be empty', context);
                }
              },
              child: Text(LocalizationHelper.of(context).translate('okay')),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDarkMode == false
                  ? [Colors.orange, const Color.fromARGB(255, 255, 119, 110)]
                  : [const Color.fromRGBO(83, 215, 238, 1), Colors.black],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 15),
              child: AppBar(
                title: Text(
                  '${LocalizationHelper.of(context).translate('msfc')} ${widget.car}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                leading: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.only(left: 10),
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                centerTitle: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
            ),
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
              color: isDarkMode
                  ? const Color.fromRGBO(83, 215, 238, 1)
                  : Colors.orange,
            ))
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Expanded(
                    child: ReorderableListView(
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) newIndex -= 1;
                          final item = stops.removeAt(oldIndex);
                          stops.insert(newIndex, item);
                        });
                        reorderStops();
                      },
                      children: [
                        for (int index = 0; index < stops.length; index++)
                          Card(
                            color: isDarkMode ? Colors.black : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: isDarkMode
                                  ? const BorderSide(
                                      color: Color.fromRGBO(83, 215, 238, 1)
                                      // Darker color for border
                                      )
                                  : BorderSide.none,
                            ),
                            key: ValueKey(stops[index]),
                            elevation: 5, // Shadow for card
                            shadowColor: isDarkMode
                                ? const Color.fromRGBO(83, 215, 238, 1)
                                : Colors.black,
                            margin: const EdgeInsets.symmetric(
                                vertical: 6), // Space between cards
                            child: ListTile(
                              minTileHeight: 70,
                              leading: const Icon(
                                Icons.location_on_outlined,
                                color: Colors.red,
                                size: 25,
                              ), // Same as before
                              title: Text(
                                stops[index],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.delete,
                                    color: isDarkMode
                                        ? Colors.red
                                        : Colors
                                            .blueGrey), // Updated delete icon color
                                onPressed: () => removeStop(stops[index]),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: GestureDetector(
        onTap: _showAddStopDialog,
        child: Container(
          height: 50,
          width: 60,
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.black87
                : Colors.black54, // Updated to match admin FAB color
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            border: Border.all(
              color: isDarkMode
                  ? const Color.fromRGBO(83, 215, 238, 1)
                  : Colors.white,
            ),
          ),
          child: Center(
            child: Icon(Icons.add,
                color: isDarkMode
                    ? const Color.fromRGBO(83, 215, 238, 1)
                    : Colors.white),
          ), // Updated icon color
        ),
      ),
    );
  }
}

class AdminCarMapPage extends StatelessWidget {
  final String carNumber;

  AdminCarMapPage({super.key, required this.carNumber});
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final mapState = Provider.of<MapState>(context);
    return ChangeNotifierProvider(
      create: (_) => CarsLocationProvider(carNumber: carNumber),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "${LocalizationHelper.of(context).translate('Car Location')}: $carNumber",
            textScaler: const TextScaler.linear(1),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: Stack(
          children: [
            Consumer<CarsLocationProvider>(
              builder: (context, provider, _) {
                final carLocation = provider.carLocation;
                return carLocation == null
                    ? Center(
                        child: CircularProgressIndicator(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Color.fromARGB(255, 38, 176, 235)
                            : Colors.orange,
                      ))
                    : FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: carLocation,
                          initialZoom: 15.0,
                          maxZoom: 18.4,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: mapState.selectedProvider.urlTemplate,
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: carLocation,
                                width: 50,
                                height: 50,
                                child: const Icon(
                                  Icons.directions_car,
                                  color: Colors.blue,
                                  size: 25,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
              },
            ),
            Positioned(
              bottom: 10,
              right: 10,
              child: Consumer<CarsLocationProvider>(
                  builder: (context, provider, _) {
                final busLocation = provider.carLocation;
                return FloatingActionButton(
                  onPressed: () {
                    if (busLocation != null) {
                      _mapController.move(busLocation, 15.0);
                    } else {
                      CustomWidget.showSnackBar(
                          "Car location not available", context);
                    }
                  },
                  child: const Icon(Icons.my_location),
                );
              }),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(top: 80),
          child: CircleAvatar(
            child: IconButton(
              icon: const Icon(Icons.layers),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (BuildContext context) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Select Map Style",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...mapProviders.map((provider) {
                            return ListTile(
                              leading: const Icon(Icons.map),
                              title: Text(provider.name),
                              onTap: () {
                                mapState.updateProvider(provider);
                                Navigator.pop(
                                    context); // Close the bottom sheet
                              },
                            );
                          }).toList(),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
