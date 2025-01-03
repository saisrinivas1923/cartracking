import 'dart:async';
import 'dart:convert';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../Constants/widget.dart';
import '../Providers/CarLocationProvider.dart';
import '../Services/localization_helper.dart';
import '../Constants/urls.dart';
import '../Services/authState.dart';

class DriverPage extends StatefulWidget {
  const DriverPage({super.key});

  @override
  State<DriverPage> createState() => _DriverPageState();
}

class _DriverPageState extends State<DriverPage> {
  final TextEditingController carcontroller = TextEditingController();
  Map<String, dynamic> carlist = {};
  bool _isSharingcar = false;
  bool is_loading = false;
  bool isSelect = false;

  Future<void> _fetchNo() async {
    setState(() {
      is_loading = true;
    });
    final url = Uri.parse('$apiBaseUrl/all-data');
    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Extract the keys from the "routes" object
        carlist = data['cars'];
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('connected success.')),
        );
        // Get the keys of the routes
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No buses found or an error occurred.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to connect to the server.')),
      );
    }
    setState(() {
      is_loading = false;
    });
  }

  void startSharingCarLocation(String carNumber) async {
    final token = await TokenStorage.getToken();
    debugPrint(carNumber);
    if (carNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a car number")),
      );
      return;
    }
    //return;
    if (carlist[carNumber] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("car not found")),
      );
      return;
    }
    try {
      await http.post(Uri.parse('$apiBaseUrl/send-notification'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'token': token}));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to connect to the server.')),
      );
      return;
    }
    setState(() {
      _isSharingcar = true;
    });

    // Simulate a delay for better user feedback
    await Future.delayed(const Duration(seconds: 1));

    // Navigate to Driver Map Page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CarMapPage(carNumber: carNumber),
      ),
    ).then((_) async {
      FocusManager.instance.primaryFocus?.unfocus();
      // Reset the sharing state when coming back
      setState(() {
        _isSharingcar = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchNo();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;
    return GestureDetector(
      behavior: HitTestBehavior
          .opaque, // Ensures taps outside of children are detected
      onTap: () {
        // Unfocus any focused widget
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(220), // Default AppBar height
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange, Color.fromARGB(255, 255, 119, 110)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30)),
            ),
            child: Column(
              children: [
                SafeArea(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, top: 15),
                    child: AppBar(
                      title: Text(
                        LocalizationHelper.of(context).translate('dp'),
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
                              color: Colors.white),
                          child: const Center(
                            child: Icon(
                              Icons.arrow_back_ios, // Menu icon
                              color: Colors.black, // Icon color
                            ),
                          ),
                        ),
                      ),
                      centerTitle: true,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      actions: const [],
                    ),
                  ),
                ),
                Container(
                  height: 120,
                  width: 200,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/bus.png'), fit: BoxFit.fill),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: is_loading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.orange,
                ),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 20.0, right: 20, top: 50),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return const Iterable<String>.empty();
                          }
                          return carlist.keys
                              .where((String key) => key.toLowerCase().contains(
                                  textEditingValue.text.toLowerCase()))
                              .toList();
                        },
                        onSelected: (String item) {
                          setState(() {
                            carcontroller.text = item;
                            print("Selected: $item");
                          });
                        },
                        fieldViewBuilder: (context, autocompleteController,
                            focusNode, onEditingComplete) {
                          return TextField(
                            controller: autocompleteController,
                            focusNode: focusNode,
                            style: const TextStyle(color: Colors.black87),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.directions_bus,
                                  color: Colors.black),
                              labelText: LocalizationHelper.of(context)
                                  .translate('Enter Car Number'),
                              labelStyle: TextStyle(
                                  color:
                                      isDarkMode ? Colors.orange : Colors.black,
                                  fontSize: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: const BorderSide(
                                    color: Colors.orange, width: 1),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: const BorderSide(
                                    color: Colors.black26, width: 1),
                              ),
                              filled: true,
                              fillColor: isDarkMode
                                  ? Colors.white
                                  : const Color.fromARGB(42, 187, 205, 214),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 18, horizontal: 30),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      _isSharingcar
                          ? Center(
                              child: const CircularProgressIndicator(
                                color: Colors.orange,
                              ),
                            ) // Show loading spinner
                          : Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                  //side: const BorderSide(color: Colors.black),
                                  borderRadius: BorderRadius.circular(20)),
                              child: ElevatedButton(
                                onPressed: () {
                                  final carNumber = carcontroller.text.trim();
                                  if (carNumber.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              "Please enter a car number")),
                                    );
                                    return;
                                  }
                                  startSharingCarLocation(carNumber);
                                },
                                style: ElevatedButton.styleFrom(
                                    //backgroundColor: Colors.black45,
                                    backgroundColor:
                                        const Color.fromARGB(255, 23, 72, 112),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    elevation: 4,
                                    fixedSize: const Size(280, 58)),
                                child: SizedBox(
                                  width:
                                      double.infinity, // Set the desired width
                                  height: 25, // Set the desired height
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          LocalizationHelper.of(context)
                                              .translate(
                                                  'start sharing car location'),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const Icon(
                                          Icons.location_on,
                                          size: 20,
                                          color: Colors.white,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
} // Import token storage for getting tokens

class CarMapPage extends StatelessWidget {
  final String carNumber;

  const CarMapPage({super.key, required this.carNumber});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CarLocationProvider(carNumber: carNumber),
      child: const _CarMapView(),
    );
  }
}

class _CarMapView extends StatefulWidget {
  const _CarMapView();

  @override
  State<_CarMapView> createState() => _CarMapViewState();
}

class _CarMapViewState extends State<_CarMapView> {
  late CarLocationProvider _provider;
  late String _token;
  final MapController _mapController = MapController();
  bool isLoading = true;
  bool _backgroundLocationStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _token = (await TokenStorage.getToken())!;
      _provider = Provider.of<CarLocationProvider>(context, listen: false);
      _provider.startCarLocationUpdates(_token);
      _provider.addListener(() {
        // This will be called whenever the provider updates
        if (_provider.currentLocation != null && !_backgroundLocationStarted) {
          _startBackGroundLocation();
          setState(() {
            isLoading = false;
            _backgroundLocationStarted = true; // Ensure this runs only once
          });
        }
      });
    });
  }

  void _recenterMap() {
    if (_provider.currentLocation != null) {
      _mapController.move(_provider.currentLocation!, 15.0);
    } else {
      CustomWidget.showSnackBar("Current location not available", context);
    }
  }

  void _stopSharingLocation() async {
    debugPrint(_token);
    _provider.stopLocationUpdates(_token);
    final service = FlutterBackgroundService();
    if (await service.isRunning()) {
      service.invoke("stopService");
    }
    Navigator.pop(context);
    CustomWidget.showSnackBar("Location sharing stopped", context);
  }

  void _startBackGroundLocation() async {
    // final token = await TokenStorage.getToken();
    _provider = Provider.of<CarLocationProvider>(context, listen: false);
    if (!await FlutterBackgroundService().isRunning()) {
      FlutterBackgroundService().startService();
    }
    FlutterBackgroundService().invoke("setAsForeground");
    // try {
    //   await http.post(Uri.parse("$apiBaseUrl/send-notification"),
    //       headers: {"Content-Type": "application/json"},
    //       body: jsonEncode({
    //         "topic": "all",
    //         "title": "Bus started",
    //         "message": "${_provider.busNumber} has started!!!",
    //         "token": token
    //       }));
    // } catch (e) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text("Failed to send notification")),
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    final mapState = Provider.of<MapState>(context);
    return PopScope(
      canPop: isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            LocalizationHelper.of(context).translate('dloc'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
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
        body: Consumer<CarLocationProvider>(
          builder: (context, provider, child) {
            if (provider.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      provider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        final token = await TokenStorage.getToken();
                        provider.startCarLocationUpdates(token!);
                      },
                      child: Text(
                        LocalizationHelper.of(context).translate('rp'),
                      ),
                    ),
                  ],
                ),
              );
            }
      
            if (!provider.isPermissionGranted) {
              return Center(
                child: Text(
                    "${LocalizationHelper.of(context).translate('wait')}..."),
              );
            }
      
            if (provider.currentLocation == null) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.orange,
                ),
              );
            }
      
            return Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                      initialCenter: provider.currentLocation!,
                      initialZoom: 15.0,
                      maxZoom: 18.4,
                      minZoom: 10),
                  children: [
                    TileLayer(
                      urlTemplate: mapState.selectedProvider.urlTemplate,
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: provider.currentLocation!,
                          width: 50.0,
                          height: 50.0,
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  bottom: 90,
                  right: 20,
                  child: FloatingActionButton(
                    onPressed: _recenterMap,
                    child: const Icon(Icons.my_location),
                  ),
                ),
                Positioned(
                  bottom: 40,
                  left: 85,
                  child: ElevatedButton(
                    onPressed: _stopSharingLocation,
                    child:
                        Text(LocalizationHelper.of(context).translate('stopsl')),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
