import 'dart:convert';
import 'package:car_tracking/Constants/urls.dart';
import 'package:car_tracking/Screens/CarDisplay.dart';
import 'package:car_tracking/Screens/nonrunningCarspage.dart';
import 'package:car_tracking/Screens/runningCarspage.dart';
import 'package:car_tracking/Services/authState.dart';
import 'package:car_tracking/Services/localization_helper.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Admindashboard extends StatefulWidget {
  const Admindashboard({super.key});

  @override
  State<Admindashboard> createState() => _AdmindashboardState();
}

class _AdmindashboardState extends State<Admindashboard> {
  void initState() {
    super.initState();
    _fetchNo();
    _fetchBusLocations();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Map<String, dynamic> carlist = {};
  List<dynamic> cars = [];
  bool is_loading = false;
  bool is_loading1 = false;
  final int runningCars = 60; // Example: 60 running cars
  final int nonRunningCars = 40;
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
        cars = carlist.keys.toList();
        print(carlist);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('connected success.')),
        );
        // Get the keys of the routes
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No Cars found or an error occurred.')),
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

  var _cars = [];

  // Function to fetch bus locations from the API
  Future<void> _fetchBusLocations() async {
    setState(() {
      is_loading1 = true;
    });
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
        _cars = data.keys.toList();
      });
    } else {
      // Handle API error here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load car data')),
      );
    }
    setState(() {
      is_loading1 = false;
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
                  ? [Colors.orange, Color.fromARGB(255, 255, 119, 110)]
                  : [Color.fromRGBO(83, 215, 238, 1), Colors.black],
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
                actions: [],
              ),
            ),
          ),
        ),
      ),
      body: (is_loading || is_loading1)
          ? Center(
              child: CircularProgressIndicator(color:  isDarkMode ? Colors.lightBlue : Colors.orange),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Pie Chart on the Left
                        Expanded(
                          flex: 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 250,
                                width: double.infinity,
                                child: PieChart(
                                  PieChartData(
                                    sections: [
                                      PieChartSectionData(
                                        color: Colors.green,
                                        value: _cars.length.toDouble(),
                                        title: '${(_cars.length).toString()}',
                                        titleStyle: const TextStyle(
                                            color: Colors.white, fontSize: 14),
                                      ),
                                      PieChartSectionData(
                                        color: Colors.red,
                                        value: (cars.length - _cars.length)
                                            .toDouble(),
                                        title:
                                            '${(cars.length - _cars.length).toString()}',
                                        titleStyle: const TextStyle(
                                            color: Colors.white, fontSize: 14),
                                      ),
                                    ],
                                    sectionsSpace: 1,
                                    centerSpaceRadius: 40,
                                    borderData: FlBorderData(show: true),
                                  ),
                                ),
                              ),
                              const Text(
                                "Car Status",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),

                        // Indicators on the Right
                        Expanded(
                          flex: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Indicator(
                                  color: Colors.green, text: "Running Cars"),
                              const SizedBox(
                                  height: 10), // Space between indicators
                              const Indicator(
                                  color: Colors.red, text: "Non-Running Cars"),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    buildMenuButton(
                      context,
                      LocalizationHelper.of(context).translate('All Cars'),
                      Icons.admin_panel_settings_outlined,
                      const PlaceListPage(),
                      cars.length,
                      1,
                      0,
                    ),
                    const SizedBox(height: 20),
                    buildMenuButton(
                      context,
                      LocalizationHelper.of(context).translate('Running Cars'),
                      Icons.directions_bus_sharp,
                      const Runningcarspage(),
                      _cars.length,
                      _cars.length / cars.length,
                      0,
                    ),
                    const SizedBox(height: 20),
                    buildMenuButton(
                      context,
                      LocalizationHelper.of(context)
                          .translate('Non-Running Cars'),
                      Icons.directions_bus_sharp,
                      NonRunningcarspage(AllCars: carlist.keys.toList()),
                      cars.length - _cars.length,
                      (cars.length - _cars.length) / cars.length,
                      1,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class Indicator extends StatelessWidget {
  final Color color;
  final String text;

  const Indicator({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6), // Space between circle and text
        SizedBox(
          width: 80,
          child: Text(
            text,
            style: const TextStyle(fontSize: 12),
            textScaler: TextScaler.linear(1),
            overflow: TextOverflow.clip,
          ),
        ),
      ],
    );
  }
}

Widget buildMenuButton(BuildContext context, String title, IconData icon,
    Widget page, int val, double r, int c) {
  final brightness = Theme.of(context).brightness;
  final isDarkMode = brightness == Brightness.dark;
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => page),
      );
    },
    child: Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
            side: BorderSide(
                color: isDarkMode
                    ? Color.fromRGBO(83, 215, 238, 1)
                    : Color.fromARGB(91, 0, 0, 0)),
            borderRadius: BorderRadius.circular(20)),
        child: Container(
          height: 80,
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.transparent
                : Color.fromARGB(255, 235, 236, 237),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color:
                    isDarkMode ? Colors.black : Colors.black.withOpacity(0.2),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
          margin: const EdgeInsets.symmetric(vertical: 1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Profile icon
                  SizedBox(
                    width: 45,
                    height: 45,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: (r).toDouble(), // Progress value
                          strokeWidth: 5,
                          backgroundColor: c == 0
                              ? Colors.red
                              : Colors.green, // Non-running cars color
                          valueColor: AlwaysStoppedAnimation<Color>((c == 0)
                              ? Colors.green
                              : Colors.red), // Running cars color
                        ),
                        Center(
                          child: Text(
                            '${(val).toString()}', // Show percentage
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  // Title text
                  Text(
                    title,
                    textScaler: TextScaler.linear(1),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
              // Forward icon
              Icon(
                Icons.arrow_forward_ios,
                color: isDarkMode ? Colors.white : Colors.black,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
