import 'dart:async';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../Constants/widget.dart';
import '../Providers/CarLocationProvider.dart';
import '../Services/localization_helper.dart';
import '../Constants/urls.dart';
import '../Services/authState.dart';
import 'Carstops.dart';

class PlaceListPage extends StatefulWidget {
  const PlaceListPage({super.key});

  @override
  State<PlaceListPage> createState() => _PlaceListPageState();
}

class _PlaceListPageState extends State<PlaceListPage>
    with SingleTickerProviderStateMixin {
  List<String> Cars = [];
  bool fetch = false;
  @override
  void initState() {
    super.initState();
    fetchCarNumbers();
  }

  Future<void> _addCar(String car) async {
    final token = await AdminTokenStorage.getToken();
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/add-car'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({'carNumber': car, 'token': token}),
      );
      if (response.statusCode == 200) {
        setState(() {
          Cars.add(car);
        });
        CustomWidget.showSnackBar('Car $car added successfully', context);
      } else {
        CustomWidget.showSnackBar('Failed to add Car', context);
      }
    } catch (e) {
      CustomWidget.showSnackBar('Error adding Car: $e', context);
    }
  }

  Future<void> _deleteCar(String car) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            LocalizationHelper.of(context).translate('cde'),
            textScaler: const TextScaler.linear(1),
          ),
          content: Text(
            '${LocalizationHelper.of(context).translate('sure')} $car?',
            textScaler: const TextScaler.linear(1),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                LocalizationHelper.of(context).translate('cancel'),
                textScaler: const TextScaler.linear(1),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text(
                LocalizationHelper.of(context).translate('delete'),
                textScaler: const TextScaler.linear(1),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
    if (confirmDelete) {
      final token = await AdminTokenStorage.getToken();
      try {
        final response = await http.post(
          Uri.parse('$apiBaseUrl/remove-car'),
          headers: {"Content-Type": "application/json"},
          body: json.encode({'carNumber': car, 'token': token}),
        );
        if (response.statusCode == 200) {
          setState(() {
            Cars.remove(car);
          });
          CustomWidget.showSnackBar('Car $car removed successfully', context);
        } else {
          CustomWidget.showSnackBar('Failed to remove Car', context);
        }
      } catch (e) {
        CustomWidget.showSnackBar('Error removing Car: $e', context);
      }
    }
  }

  Future<void> fetchCarNumbers() async {
    final token = await AdminTokenStorage.getToken();
    try {
      final response = await http.post(Uri.parse('$apiBaseUrl/get-cars'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'token':token}),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data == {}) {
          debugPrint("$data");
          return;
        }
        final numbers = data;

        setState(() {
          Cars = numbers.keys.toList();
        });
        fetch = true;
      } else {
        debugPrint("Failed to fetch data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching data: $e");
    }
  }

  Future<void> getCarLocation(String CarNumber) async {
    final token = await AdminTokenStorage.getToken();
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/get-location-of-all-cars'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token':token}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey(CarNumber)) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminCarMapPage(carNumber: CarNumber),
            ),
          );
        } else {
          CustomWidget.showSnackBar('Car Not Started', context);
        }
      } else {
        debugPrint('Failed to retrieve Car location. ${response.body}');
      }
    } catch (e) {
      debugPrint('Error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(150),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange, Color.fromARGB(255, 255, 119, 110)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 15),
              child: AppBar(
                title: Text(
                    LocalizationHelper.of(context).translate('admindashboard'),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                    textScaler: const TextScaler.linear(1)),
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
                actions: [
                  IconButton(
                    icon: const Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () {
                      Navigator.push(context,MaterialPageRoute(builder: (context)=>const AllCarMapPage()));
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: fetch== false? const Center(child: CircularProgressIndicator(color: Colors.orange,)) : Cars.isEmpty
          ? const Center(
        child: Text(
          "No Cars Are There",
          textScaler: TextScaler.linear(1),
          style: TextStyle(
            fontSize: 18,
            color: Colors.orangeAccent,
          ),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: Cars.length,
          itemBuilder: (context, index) {
            final CarNumber = Cars[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CarManageStopsScreen(car: CarNumber),
                  ),
                );
              },
              child: Card(
                color: isDarkMode ? Colors.black87 : null,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                      color: Color.fromARGB(195, 233, 169, 74)),
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                shadowColor:
                isDarkMode ? Colors.orange : Colors.black,
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
                    'Car Number : $CarNumber',
                    textScaler: isDarkMode
                        ? const TextScaler.linear(0.9)
                        : const TextScaler.linear(1),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color:
                      isDarkMode ? Colors.white : Colors.black87,
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
                          getCarLocation(CarNumber);
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.blueGrey,
                        ),
                        onPressed: () {
                          _deleteCar(CarNumber);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton:  GestureDetector(
        onTap: () {
        TextEditingController CarController = TextEditingController();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(LocalizationHelper.of(context).translate('car'),
                  textScaler: const TextScaler.linear(1)),
              content: TextField(
                controller: CarController,
                decoration: InputDecoration(
                  hintText: LocalizationHelper.of(context).translate('Car Number'),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(LocalizationHelper.of(context).translate('cancel'),
                      textScaler: const TextScaler.linear(1)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text(LocalizationHelper.of(context).translate('ok'),
                      textScaler: const TextScaler.linear(1)),
                  onPressed: () {
                    String CarNumber = CarController.text.trim();
                    if (CarNumber.isNotEmpty) {
                      print(CarNumber);
                      _addCar(CarNumber);
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
        child:  Container(
          height: 50,
          width: 70,
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.white : Colors.black54,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          child: Center(
              child: Icon(Icons.add,
                  color: isDarkMode ? Colors.orange : Colors.white)),
        ),
      )
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
    final response = await http.post(Uri.parse(
        '$apiBaseUrl/get-location-of-all-cars'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'token':token})); // Replace with your API URL

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
                          padding: const EdgeInsets.only(left:2,right: 2),
                          color: Colors.white,
                          child: Text(entry.key,style: const TextStyle(fontSize: 8),textScaler: const TextScaler.linear(1),),
                        ),
                        const Icon(Icons.directions_car, color: Colors.blue),
                      ],
                    ),
                    // Container(
                    //   height: 18,
                    //   width: 18,
                    //   decoration: const BoxDecoration(
                    //       color: Colors.red,
                    //       borderRadius: BorderRadius.all(Radius.circular(100))),
                    //   child: Center(
                    //       child: Text(
                    //         entry.key,
                    //         style:
                    //         const TextStyle(fontSize: 7, color: Colors.white),
                    //       )),
                    // ),
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
        title: const Text('Car Locations on Map'),
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