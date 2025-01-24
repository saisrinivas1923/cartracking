import 'dart:async';
import 'dart:convert';
import 'package:car_tracking/Providers/CommonProvider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

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
  Map<String, dynamic> all_list = {};
  List<dynamic> cars = [];
  final List<String> images = [
    'assets/innova.jpg', // Replace with your actual asset paths
    'assets/mahindra bolero.jpg',
    'assets/ambulance.jpg',
    'assets/mahindra Marazzo.jpg'
  ];

  bool _isSharingcar = false;
  bool is_loading = false;
  bool isSelect = false;
  List<String> Cars = [];
  bool fetch = false;

  Future<void> Fetchdata() async {
    setState(() {
      fetch = true;
    });
    final token = await AdminTokenStorage.getToken();
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/get-location-of-all-cars'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Cars = data.keys.toList();
        debugPrint('$Cars');
      } else {
        debugPrint('Failed to retrieve Car location. ${response.body}');
      }
    } catch (e) {
      debugPrint('Error occurred: $e');
    }
    setState(() {
      fetch = false;
    });
  }

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
        all_list = data['details'];
        print(all_list);
        cars = all_list.keys.toList();
        print(carlist);
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
    Fetchdata();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;
    final currentIndexProvider = Provider.of<CurrentIndexProvider>(context);
    return Scaffold(
      backgroundColor: isDarkMode == false ? Colors.white : Colors.black,
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 100),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDarkMode == false
                  ? [Colors.orange, Color.fromARGB(255, 255, 119, 110)]
                  : [Color.fromRGBO(83, 215, 238, 1), Colors.black],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 15),
              child: AppBar(
                backgroundColor: Colors.transparent,
                centerTitle: true,
                title: Text(
                  "Car Driver",
                  style: TextStyle(color: Colors.white, fontSize: 22),
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
                actions: [
                  Container(
                    height: 50,
                    width: 50,
                    margin: EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                        //color: Colors.transparent,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: Colors.white,
                          width: 1.5,
                        ),
                        image: DecorationImage(
                            image: AssetImage("assets/driver.jpg"),
                            fit: BoxFit.cover)),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: is_loading
          ? Center(
              child: CircularProgressIndicator(
                color: Color.fromRGBO(83, 215, 238, 1),
              ),
            )
          : SingleChildScrollView(
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 20, left: 10, right: 10),
                      child: Container(
                        height: 230,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: CarouselSlider.builder(
                            itemCount: images.length,
                            itemBuilder: (context, index, realIndex) {
                              return Image.asset(
                                images[index],
                                fit: BoxFit
                                    .fill, // Ensures the image covers the container
                                width: double.infinity,
                              );
                            },
                            options: CarouselOptions(
                              height: 230,
                              autoPlay: true,
                              autoPlayInterval: const Duration(seconds: 10),
                              onPageChanged: (index, reason) {
                                currentIndexProvider.setCurrentIndex(index);
                              },
                              viewportFraction: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: AnimatedSmoothIndicator(
                        activeIndex: currentIndexProvider.currentIndex,
                        count: images.length,
                        effect: const ExpandingDotsEffect(
                          dotHeight: 8,
                          dotWidth: 8,
                          activeDotColor: Color.fromRGBO(83, 215, 238, 1),
                          dotColor: Color.fromARGB(255, 193, 186, 186),
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Text(
                          "Select Your Car",
                          style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                              fontSize: 20),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 330,
                      width: double.infinity,
                      child: ListView.separated(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return Container(
                            //margin: EdgeInsets.only(left: 10, right: 10),
                            width: MediaQuery.of(context).size.width * 0.6,
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.transparent
                                  : const Color.fromARGB(255, 249, 245, 245),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDarkMode
                                    ? Color.fromRGBO(83, 215, 238, 1)
                                    : Colors.black,
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  all_list[cars[index]][0].length == 0
                                      ? "Not Added"
                                      : "${(all_list[cars[index]][0]).toString().toUpperCase()}",
                                  style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 18),
                                  textScaler: TextScaler.linear(1),
                                  overflow: TextOverflow.clip,
                                ),
                                Divider(
                                  color: isDarkMode
                                      ? Color.fromRGBO(83, 215, 238, 1)
                                      : Colors.black,
                                  thickness: 1.5,
                                ),
                                Spacer(),
                                Container(
                                  width: 160,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isDarkMode
                                        ? Colors.transparent
                                        : Colors.black,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: isDarkMode
                                            ? Color.fromRGBO(83, 215, 238, 1)
                                            : Colors.black,
                                        width: 1.5),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "${(cars[index]).toString().toUpperCase()}",
                                      style: TextStyle(
                                          color: isDarkMode
                                              ? Colors.white
                                              : Colors.white,
                                          fontWeight: FontWeight.w200),
                                      textScaler: TextScaler.linear(1),
                                    ),
                                  ),
                                ),
                                Spacer(),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      'Emp ID :',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: isDarkMode
                                              ? Colors.white
                                              : Colors.black),
                                      textScaler: TextScaler.linear(1),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      all_list[cars[index]][1].length == 0
                                          ? "Not Added"
                                          : "${(all_list[cars[index]][1]).toString().toUpperCase()}",
                                      style: TextStyle(
                                          color: isDarkMode
                                              ? Colors.white
                                              : Colors.black),
                                      textScaler: TextScaler.linear(1),
                                    ),
                                  ],
                                ),
                                Spacer(),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      'Name :',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: isDarkMode
                                              ? Colors.white
                                              : Colors.black),
                                      textScaler: TextScaler.linear(1),
                                      overflow: TextOverflow.clip,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    SizedBox(
                                      width: MediaQuery.sizeOf(context).width *
                                          0.4,
                                      child: Text(
                                        all_list[cars[index]][2].length == 0
                                            ? "Not Added"
                                            : "${(all_list[cars[index]][2]).toString().toUpperCase()}",
                                        style: TextStyle(
                                            color: isDarkMode
                                                ? Colors.white
                                                : Colors.black),
                                        textScaler: TextScaler.linear(1),
                                        overflow: TextOverflow.clip,
                                      ),
                                    ),
                                  ],
                                ),
                                Spacer(),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      'Mobile No :',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: isDarkMode
                                              ? Colors.white
                                              : Colors.black),
                                      textScaler: TextScaler.linear(1),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      all_list[cars[index]][3].length == 0
                                          ? "Not Added"
                                          : "${(all_list[cars[index]][3]).toString().toUpperCase()}",
                                      style: TextStyle(
                                          color: isDarkMode
                                              ? Colors.white
                                              : Colors.black),
                                      textScaler: TextScaler.linear(1),
                                    ),
                                  ],
                                ),
                                Spacer(),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 12, right: 12, bottom: 20),
                                  child: GestureDetector(
                                    onTap: Cars.contains(cars[index].toString())?(){
                                      showDialog(context: context, builder: (context){
                                        return AlertDialog(
                                          title: Text(
                                            'Alert',
                                            textScaler: const TextScaler.linear(1),
                                          ),
                                          content: Text(
                                            'Car is already Running',
                                            textScaler: const TextScaler.linear(1),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              child: Text(
                                                LocalizationHelper.of(context).translate('ok'),
                                                textScaler: const TextScaler.linear(1),
                                              ),
                                              onPressed: () {
                                                Navigator.of(context).pop(false);
                                              },
                                            ),
                                          ],
                                        );
                                      });
                                    } : () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => CarMapPage(
                                                  carNumber: cars[index])));
                                    },
                                    child: Container(
                                      height: 50,
                                      margin:
                                          EdgeInsets.only(left: 20, right: 20),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: isDarkMode == false
                                              ? [
                                                  Colors.orange,
                                                  Color.fromARGB(
                                                      255, 255, 119, 110)
                                                ]
                                              : [
                                                  Color.fromRGBO(
                                                      83, 215, 238, 1),
                                                  Color.fromRGBO(
                                                      83, 215, 238, 1)
                                                ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        //color: Color.fromRGBO(83, 215, 238, 1),
                                        // boxShadow: [
                                        //   BoxShadow(
                                        //     spreadRadius: 2,
                                        //     blurRadius: 10,
                                        //     //offset: Offset(-1, 1),
                                        //     color: Color.fromRGBO(
                                        //         83, 215, 238, 1),
                                        //   ),
                                        // ],
                                        // border: Border.all(
                                        //     color: Color.fromRGBO(
                                        //         83, 215, 238, 1)),
                                        //
                                        // color: isDarkMode
                                        //     ? Colors.white
                                        //     : Colors.orange,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Start the Car",
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: isDarkMode == false
                                                    ? Colors.white
                                                    : Colors.black,
                                                fontWeight: FontWeight.w600),
                                            textScaler: TextScaler.linear(1),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Icon(
                                            Icons.arrow_forward,
                                            color: isDarkMode
                                                ? Colors.black
                                                : Colors.white,
                                            size: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        itemCount: cars.length,
                        separatorBuilder: (context, index) => SizedBox(
                          width: 20,
                        ),
                      ),
                    ),
                  ],
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
  double _currentSpeed = 0.0;
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
    _provider = Provider.of<CarLocationProvider>(context, listen: false);
    await BusnoTokenStorage.removeToken(_provider.carNumber);
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
                    child: Text(
                        LocalizationHelper.of(context).translate('stopsl')),
                  ),
                ),
              ],
            );
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(top: 80),
          child: CircleAvatar(
            child: IconButton(
              icon: Icon(Icons.layers),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  shape: RoundedRectangleBorder(
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
                          Text(
                            "Select Map Style",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          ...mapProviders.map((provider) {
                            return ListTile(
                              leading: Icon(Icons.map),
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
