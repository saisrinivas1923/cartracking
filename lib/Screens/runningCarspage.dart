import 'dart:async';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

import '../Providers/runningCarsProvider.dart';
import '../Providers/CarLocationProvider.dart';
import '../Services/localization_helper.dart';
import '../Constants/urls.dart';
import '../Services/authState.dart';

class Runningcarspage extends StatefulWidget {
  const Runningcarspage({super.key});

  @override
  State<Runningcarspage> createState() => _RunningcarspageState();
}

class _RunningcarspageState extends State<Runningcarspage> {
  @override
  void initState() {
    super.initState();
    // Fetch all cars when the page is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<Runningcarsprovider>(context, listen: false).fetchAllCars();
    });
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
                  LocalizationHelper.of(context).translate('Running'),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  textScaler: const TextScaler.linear(1),
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
      body: RefreshIndicator(
        color: isDarkMode
            ? const Color.fromRGBO(83, 215, 238, 1)
            : Colors.orange, // Set the color of the refresh indicator
        onRefresh: () async {
          // Trigger the fetchAllCars function to refresh data
          await Provider.of<Runningcarsprovider>(context, listen: false)
              .fetchAllCars();
        },
        child: Consumer<Runningcarsprovider>(
          builder: (context, carProvider, _) {
            if (carProvider.isFetching) {
              return Center(
                child: CircularProgressIndicator(
                  color: isDarkMode
                      ? const Color.fromRGBO(83, 215, 238, 1)
                      : Colors.orange,
                ),
              );
            }
            // Wrapping with a ListView to make RefreshIndicator work even when empty
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView(
                children: [
                  if (carProvider.Cars.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.height * 0.4,
                        horizontal: MediaQuery.of(context).size.width * 0.15,
                      ),
                      child: Text(
                        LocalizationHelper.of(context).translate('No Car'),
                        textScaler: const TextScaler.linear(1),
                        style: TextStyle(
                          fontSize: 18,
                          color: isDarkMode
                              ? const Color.fromRGBO(83, 215, 238, 1)
                              : Colors.orangeAccent,
                        ),
                      ),
                    )
                  else
                    ...carProvider.Cars.map((carNumber) {
                      return Card(
                        color: isDarkMode ? Colors.black87 : null,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                              color: isDarkMode
                                  ? const Color.fromRGBO(83, 215, 238, 1)
                                  : Colors.orange),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                        shadowColor: isDarkMode ? Colors.orange : Colors.black,
                        margin: const EdgeInsets.symmetric(vertical: 7),
                        child: ListTile(
                          minTileHeight: isDarkMode ? 65 : 70,
                          contentPadding: const EdgeInsets.all(5),
                          leading: Icon(
                            Icons.directions_car,
                            color: isDarkMode
                                ? const Color.fromARGB(255, 238, 234, 234)
                                : Colors.black,
                            size: isDarkMode ? 30 : 35,
                          ),
                          title: Text(
                            '${LocalizationHelper.of(context).translate('CarNumber')} : $carNumber',
                            textScaler: isDarkMode
                                ? const TextScaler.linear(0.9)
                                : const TextScaler.linear(1),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  carProvider.navigateToCarLocation(
                                      context, carNumber);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class AllCarMapPage extends StatefulWidget {
  const AllCarMapPage({super.key});

  @override
  State<AllCarMapPage> createState() => _AllCarPageState();
}

class _AllCarPageState extends State<AllCarMapPage> {
  final MapController _mapController = MapController();
  Timer? timer;

  List<Marker> _busMarkers = [];

  // Function to fetch bus locations from the API
  Future<void> _fetchBusLocations() async {
    final token = await AdminTokenStorage.getToken();
    final response = await http.post(
        Uri.parse('$apiBaseUrl/get-location-of-all-cars'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'token': token})); // Replace with your API URL

    if (response.statusCode == 200) {
      // Parse the JSON data from the API
      Map<String, dynamic> data = jsonDecode(response.body);
      // Create markers from the API data
      setState(() {
        _busMarkers = data.entries.map((entry) {
          // Ensure we only add valid latitude and longitude
          double latitude =
              double.tryParse(entry.value['latitude'].toString()) ?? 0.0;
          double longitude =
              double.tryParse(entry.value['longitude'].toString()) ?? 0.0;
          return Marker(
            point: LatLng(latitude, longitude),
            width: 50,
            height: 50,
            child: Stack(
              children: [
                Stack(
                  children: [
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(left: 2, right: 2),
                          color: Colors.white,
                          child: Text(
                            entry.key,
                            style: const TextStyle(fontSize: 8,color: Colors.black),
                            textScaler: const TextScaler.linear(1),
                          ),
                        ),
                        const Icon(Icons.directions_car, color: Colors.blue),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList();
      });
    } else {
      // Handle API error here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load car data')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 5), (_) async {
      await _fetchBusLocations();
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final mapState = Provider.of<MapState>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationHelper.of(context).translate('Cars Location on Map')),
        actions: [
          PopupMenuButton<MapProvider>(
            onSelected: (provider) => mapState.updateProvider(provider),
            itemBuilder: (context) {
              return mapProviders.map((provider) {
                return PopupMenuItem(
                  value: provider,
                  child: Text(provider.name),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: _busMarkers == []
          ? const Center(
              child: CircularProgressIndicator(
              color: Colors.orange,
            ))
          : FlutterMap(
              mapController: _mapController,
              options: const MapOptions(
                initialCenter:
                    LatLng(17.0862706, 82.0524117), // Set a default map center
                initialZoom: 15.0,
                maxZoom: 18.4,
              ),
              children: [
                TileLayer(
                  urlTemplate: mapState.selectedProvider.urlTemplate,
                ),
                MarkerLayer(
                  markers: _busMarkers, // Display the bus markers on the map
                ),
              ],
            ),
    );
  }
}
